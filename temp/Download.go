package api

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"log"
)

// DownloadRequest - структура запроса для инициализации загрузки с информацией о файле в формате json
type DownloadRequest struct {
	FilePath string `json:"filePath"`
}

// downloadHandler обрабатывает запросы на скачивание файла
func downloadHandler(w http.ResponseWriter, r *http.Request) {
	// Закрываем тело запроса после всех действий с ним
	defer r.Body.Close()

	// Декодируем JSON-запрос для получения пути к файлу
	var req DownloadRequest
	err := json.NewDecoder(r.Body).Decode(&req)
	if err != nil {
		log.Printf("Failed to decode JSON request: %v\n", err)
		http.Error(w, "Unable to decode request", http.StatusBadRequest)
		return
	}

	// Валидация пути файла
	if req.FilePath == "" {
		log.Println("File path is empty")
		http.Error(w, "File path cannot be empty", http.StatusBadRequest)
		return
	}

	// Получаем корневую директорию для скачивания
	homeDir, err := GetHomeDirHandle()
	if err != nil {
		log.Printf("Error getting home directory: %v\n", err)
		http.Error(w, "Unable to get home directory", http.StatusInternalServerError)
		return
	}

	// Проверка на корректность пути
	downloadFilePath, err := validateFilePath(req.FilePath, homeDir)
	if err != nil {
		log.Println("Invalid file path:", err)
		http.Error(w, "Invalid file path", http.StatusBadRequest)
		return
	}
	
	// Проверка существования файла перед открытием
	fileInfo, err := os.Stat(downloadFilePath)
	if os.IsNotExist(err) {
		log.Printf("File does not exist: %s\n", downloadFilePath)
		http.Error(w, "File not found", http.StatusNotFound)
		return
	} else if err != nil {
		log.Printf("Error retrieving file info: %v\n", err)
		http.Error(w, "Unable to access file", http.StatusInternalServerError)
		return
	}

	// открываем файл для отправки
	downloadFile, err := os.Open(downloadFilePath)
	if err != nil {
		log.Printf("Failed to create file: %v\n", err)
		http.Error(w, "Unable to create file", http.StatusInternalServerError)
		return
	}
	defer downloadFile.Close()

	// Устанавливаем заголовки для скачивания файла
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", filepath.Base(downloadFilePath)))
	w.Header().Set("Content-Length", fmt.Sprintf("%d", fileInfo.Size()))

	// Передаем содержимое файла клиенту
	if _, err := io.Copy(w, downloadFile); err != nil {
		log.Printf("Failed to send file: %v\n", err)
		http.Error(w, "Unable to send file", http.StatusInternalServerError)
		return
	}

	log.Printf("File downloaded successfully from %s\n", downloadFilePath)
}
