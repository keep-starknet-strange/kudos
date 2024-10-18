package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	StarkNetRPCURL  string
	ContractAddress string
	SlackToken      string
	SlackWebhookURL string
	BlastProjectId  string
}

func LoadConfig() (*Config, error) {
	err := godotenv.Load()
	if err != nil {
		log.Printf("Error loading .env file")
	}

	return &Config{
		SlackToken:      os.Getenv("SLACK_TOKEN"),
		StarkNetRPCURL:  os.Getenv("STARKNET_RPC_URL"),
		ContractAddress: os.Getenv("CONTRACT_ADDRESS"),
		SlackWebhookURL: os.Getenv("SLACK_WEBHOOK_URL"),
		BlastProjectId:  os.Getenv("BLAST_PROJECT_ID"),
	}, nil
}
