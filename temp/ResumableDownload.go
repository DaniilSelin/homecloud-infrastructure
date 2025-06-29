/*
Возобновляемое скачивание (без метаданых пока)
*/
package api

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
	"regexp"
	"os"
	"path/filepath"

	"github.com/gorilla/mux"
)

// parseDownloadRange - функция для извлечения начального и конечного байтов из заголовка Content-Range
// Ожидаемый формат заголовка:  bytes {start}-{end}/{total}
func parseDownloadRange(rangeHeader string, session session) (start, end uint64, err error) {
	matches := rangeDownloadRegex.FindStringSubmatch(rangeHeader)

	log.Printf("Regex match result: %v", matches)
    // Проверяем, что получили нужное количество частей
    if len(matches) < 2 {
        return 0, 0, fmt.Errorf("invalid Range header format")
    }

	// Парсим начальное значение
    start, err = strconv.ParseUint(matches[1], 10, 64)
    if err != nil {
        return 0, 0, fmt.Errorf("invalid start value: %v", err)
    }

	// Если конечное значение присутствует, парсим его
    if matches[2] != "" {
        end, err = strconv.ParseUint(matches[2], 10, 64)
        if err != nil {
            return 0, 0, fmt.Errorf("invalid end value: %v", err)
        }
    } else {
        // Если конечное значение отсутствует
        end = session.CountByte - 1 // конец файла
    }

	return start, end, nil
}

// Регулярное выражение для парсинга заголовка content-range
var rangeDownloadRegex = regexp.MustCompile(`bytes=(\d+)-(\d*)`)

// ResumableDownloadRequest - структура запроса для инициализации скачивания файла
type ResumableDownloadRequest struct {
    FilePath string `json:"filePath"`
}

// создаетконтрольную сумму для файла
func createControlSum(filePath string) (string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return "", fmt.Errorf("error opening file: %v", err)
	}
	defer file.Close()

	hasher := sha256.New()
	if _, err := io.Copy(hasher, file); err != nil {
		return "", fmt.Errorf("error calculating SHA-256: %v", err)
	}

	return fmt.Sprintf("%x", hasher.Sum(nil)), nil
}

// ResumableDownloadInitHandler - инициализация сессии возобновляемой загрузки
func ResumableDownloadInitHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Handling resumable download initialization")

	var req ResumableDownloadRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Unable to decode request", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	// Создаем уникальный идентификатор сессии
	sessionID := generateUniqueID()
	log.Printf("Generated session ID: %s", sessionID)

	// Получаем корневую директорию для скачивания
	homeDir, err := GetHomeDirHandle()
	if err != nil {
		log.Printf("Error getting home directory: %v\n", err)
		http.Error(w, "Unable to get HomeDir", http.StatusInternalServerError)
		return
	}

	// Проверка на корректность пути
	req.FilePath, err = validateFilePath(req.FilePath, homeDir)
	if err != nil {
		log.Println("Invalid file path:", err)
		http.Error(w, "Invalid file path", http.StatusBadRequest)
		return
	}

	// Проверка файла
	fileInfo, err := os.Stat(req.FilePath)
	if err != nil || fileInfo.IsDir() {
		log.Printf("Invalid file path: %v\n", err)
		http.Error(w, "File not found", http.StatusBadRequest)
		return
	}

	// Создание контрольной суммы
	sha256, err := createControlSum(req.FilePath)
	if err != nil {
		log.Printf("Error creating checksum: %v\n", err)
		http.Error(w, "Failed to calculate checksum", http.StatusInternalServerError)
		return
	}

	// Сохраняем сессию
	saveUploadSession(sessionID, req.FilePath, sha256, uint64(fileInfo.Size()))

	// Формируем ответ
	response := map[string]interface{}{
		"download_url": fmt.Sprintf("/download/resumable/%s", sessionID),
		"sessionID":    sessionID,
		"file_size":    fileInfo.Size(),
		"checksum":     sha256,
	}

	// Отправляем JSON-ответ с кодом 201
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	if err := json.NewEncoder(w).Encode(response); err != nil {
		log.Printf("Error encoding JSON response: %v", err)
		http.Error(w, "Failed to send response", http.StatusInternalServerError)
	}
}

// ResumableDownloadHandler - обработка части файла при возобновляемой загрузке
func ResumableDownloadHandler(w http.ResponseWriter, r *http.Request) {
	// Логирование начала обработки чанк-скачивания
	log.Println("Handling chunk download")

	// Извлекаем sessionID из параметров URL
	vars := mux.Vars(r)
	sessionID := vars["sessionID"]
	log.Printf("Received session ID: %s", sessionID)

	// Получаем данные сессии из хеш-таблицы
	session, err := getUploadSession(sessionID)
	if err != nil {
		log.Printf("Error fetching session: %v", err)
		http.Error(w, "Session not found", http.StatusNotFound)
		return
	}

	// Чтение заголовка Range
	rangeHeader := r.Header.Get("Range")

	log.Printf("Received Range header: %s", rangeHeader)

	start, end, err := parseDownloadRange(rangeHeader, session)
	if err != nil {
		http.Error(w, "Invalid Range header", http.StatusRequestedRangeNotSatisfiable)
		return
	}

	// Проверка флага окончания скачивания
	flagFinish := end+1 >= session.CountByte
	log.Printf("Is download complete: %v for session %s", flagFinish, sessionID)

	// Открываем файл для чтения и отправки
	downloadFile, err := os.Open(session.filePath)
	if err != nil {
		log.Printf("File not found: %v\n", err)
		http.Error(w, "Unable to get file", http.StatusInternalServerError)
		return
	}
	defer downloadFile.Close()

	// Устанавливаем заголовки для скачивания файла
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", filepath.Base(session.filePath)))
	w.Header().Set("Content-Length", strconv.FormatUint(end-start+1, 10))
	w.Header().Set("Content-Range", fmt.Sprintf("bytes %d-%d/%d", start, end, session.CountByte))

	// Устанавливаем статус ответа
	if !flagFinish {
		w.WriteHeader(http.StatusPartialContent)
	}

	// Передаем содержимое файла клиенту
	fileReader := io.NewSectionReader(downloadFile, int64(start), int64(end-start+1))
	if _, err := io.Copy(w, fileReader); err != nil {
		log.Printf("Failed to send file chunk: %v\n", err)
		http.Error(w, "Unable to send file chunk", http.StatusInternalServerError)
		return
	}

	// Завершение сессии, если файл загружен полностью
	if flagFinish {
		deleteUploadSession(sessionID)
		log.Printf("Download complete for session %s", sessionID)
	}
}
