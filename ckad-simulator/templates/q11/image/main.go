package main

import (
	"fmt"
	"os"
	"time"
)

func main() {
	id := os.Getenv("SUN_CIPHER_ID")
	if id == "" {
		id = "not-set"
	}
	for {
		fmt.Printf("%s | Sun Cipher running | ID: %s\n", time.Now().Format(time.RFC3339), id)
		time.Sleep(5 * time.Second)
	}
}
