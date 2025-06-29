package api

import (
	"github.com/gorilla/mux"
)

func RegisterRoutes() *mux.Router {
	// Инициализация маршрутизатора
	router := mux.NewRouter()

	// Группируем все маршруты для загрузки
	uploadRouter := router.PathPrefix("/upload").Subrouter()
	uploadRouter.HandleFunc("/", uploadHandler).Methods("POST")
	uploadRouter.HandleFunc("/folder", uploadFolderHandler).Methods("POST")

	resumableUploadRouter := router.PathPrefix("/upload/resumable").Subrouter()
	resumableUploadRouter.HandleFunc("", ResumableUploadInitHandler).Methods("POST")
	resumableUploadRouter.HandleFunc("/{sessionID}", ResumableUploadHandler).Methods("POST")

	downloadRouter := router.PathPrefix("/download").Subrouter()
	downloadRouter.HandleFunc("/", downloadHandler).Methods("GET")
	downloadRouter.HandleFunc("/folder", downloadFolderHandler).Methods("GET")

	resumableDownloadRouter := router.PathPrefix("/download/resumable").Subrouter()
	resumableDownloadRouter.HandleFunc("", ResumableDownloadInitHandler).Methods("GET")
	resumableDownloadRouter.HandleFunc("/{sessionID}", ResumableDownloadHandler).Methods("GET")

	return router
}