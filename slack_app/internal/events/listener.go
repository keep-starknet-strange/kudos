package listener

import (
	"log"
	"time"

	"github.com/keep-starknet-strange/kudos/slack_app/internal/config"
	"github.com/keep-starknet-strange/kudos/slack_app/internal/slack"
)

type EventResponse struct {
	Count       int     `json:"count"`
	NextPageKey string  `json:"nextPageKey"`
	Events      []Event `json:"events"`
}

type Event struct {
	BlockNumber     int      `json:"blockNumber"`
	BlockHash       string   `json:"blockHash"`
	BlockTimestamp  string   `json:"blockTimestamp"`
	TransactionHash string   `json:"transactionHash"`
	FromAddress     string   `json:"fromAddress"`
	Keys            []string `json:"keys"`
	Data            []string `json:"data"`
}

func StartStarkNetListener(cfg *config.Config) {
	log.Println("Starting StarkNet listener...")

	// Simulate polling StarkNet events via the JSON-RPC API
	for {
		time.Sleep(10 * time.Second) // Poll every 10 seconds

		// Send the event to Slack
		err := slack.PostToSlack(cfg.SlackWebhookURL, event)
		if err != nil {
			log.Printf("Failed to post event to Slack: %v", err)
		}
	}
}
