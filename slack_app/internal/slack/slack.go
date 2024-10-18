package slack

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
)

type SlackMessage struct {
	Text string `json:"text"`
}

func PostToSlack(webhookURL, message string) error {
	slackMessage := SlackMessage{Text: message}
	msgBytes, err := json.Marshal(slackMessage)
	if err != nil {
		log.Printf("Error marshaling Slack message: %v", err)
		return err
	}

	req, err := http.NewRequest("POST", webhookURL, bytes.NewBuffer(msgBytes))
	if err != nil {
		log.Printf("Error creating Slack request: %v", err)
		return err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Error sending request to Slack: %v", err)
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		log.Printf("Received non-200 response from Slack: %d", resp.StatusCode)
		return err
	}

	log.Println("Message posted to Slack successfully")
	return nil
}
