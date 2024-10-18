package main

import (
	"log"
	"net/http"

	"github.com/keep-starknet-strange/kudos/slack_app/internal/config"
	"github.com/keep-starknet-strange/kudos/slack_app/internal/listener"
)

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}

func main() {
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// Start listening to StarkNet events
	go listener.StartStarkNetListener(cfg)

	// Optional: HTTP server for health checks
	http.HandleFunc("/health", healthCheckHandler)
	log.Println("Health check running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
