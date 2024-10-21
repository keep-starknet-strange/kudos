package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/keep-starknet-strange/kudos/api/internal/config"
	"github.com/keep-starknet-strange/kudos/api/internal/handlers"
)

var postedData []map[string]interface{}

func main() {
	config.Init()

	router := gin.Default()

	router.POST("/api/google/login", handlers.LoginGoogle)

	router.POST("/api/indexer", handlers.ReceiveData)

	// GET route to retrieve the posted data
	router.GET("/api/indexer", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"stored_data": postedData,
		})
	})

	router.Run("localhost:8080")
}
