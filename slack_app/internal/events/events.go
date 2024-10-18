package events

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/keep-starknet-strange/kudos/slack_app/internal/config"
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

func GetEvents(fromBlock, toBlock, fromAddress string, eventNameKeys []string, cfg *config.Config) (*EventResponse, error) {
	apiURL := fmt.Sprintf("%s/%s/builder/getEvents?fromBlock=%s&toBlock=%s&fromAddress=%s",
		cfg.StarkNetRPCURL, fromBlock, toBlock, cfg.ContractAddress)

	req, err := http.NewRequest("GET", apiURL, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var eventResponse EventResponse
	if err := json.Unmarshal(body, &eventResponse); err != nil {
		return nil, err
	}

	return &eventResponse, nil
}
