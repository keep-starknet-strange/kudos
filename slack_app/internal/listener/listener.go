package listener

import (
	"log"
	"time"

	"github.com/keep-starknet-strange/kudos/slack_app/internal/config"
	"github.com/keep-starknet-strange/kudos/slack_app/internal/slack"
)

func StartStarkNetListener(cfg *config.Config) {
	log.Println("Starting StarkNet listener...")

	// Simulate polling StarkNet events via the JSON-RPC API
	for {
		time.Sleep(10 * time.Second) // Poll every 10 seconds

		// Simulate receiving a StarkNet event
		event := "New credential registered on StarkNet!"
		log.Printf("Received event: %s", event)

		// Send the event to Slack
		err := slack.PostToSlack(cfg.SlackWebhookURL, event)
		if err != nil {
			log.Printf("Failed to post event to Slack: %v", err)
		}
	}
}
