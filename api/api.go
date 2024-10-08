package main

import (
	"github.com/gin-gonic/gin"
	"github.com/keep-starknet-strange/kudos/api/internal/config"
	"github.com/keep-starknet-strange/kudos/api/internal/handlers"
)

func main() {
	config.Init()

	router := gin.Default()

	router.POST("/api/google/login", handlers.LoginGoogle)

	router.Run("localhost:8080")
}
