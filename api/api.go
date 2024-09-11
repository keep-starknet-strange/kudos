package main

import (
	"fmt"
	
	"github.com/keep-starknet-strange/kudos/api/internal/config"
)

func main() {
	config.Init()
	fmt.Println("NOICE")
}