package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

var postedData []map[string]interface{}

func ReceiveData(c *gin.Context) {
	// Get the raw data from the request body
	rawData, err := c.GetRawData()
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Unable to read raw data", "details": err.Error()})
		return
	}

	// Log the raw data to the console for debugging
	fmt.Println("Raw Data:", string(rawData))

	// Attempt to parse the raw data as JSON
	var jsonData map[string]interface{}
	if err := json.Unmarshal(rawData, &jsonData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON", "details": err.Error()})
		return
	}

	// Store the parsed JSON data in the slice
	postedData = append(postedData, jsonData)

	// Respond with the stored data for confirmation
	c.JSON(http.StatusOK, gin.H{"status": "data stored", "rawData": string(rawData)})
}
