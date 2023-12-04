package main

import (
	"encoding/json"
	"fmt"
	"os"
)

// MatchData represents the structure of each object in the JSON array
type MatchData struct {
	Id      int `json:id`
	Matches int `json:"matches"`
	Count   int `json:"count"`
}

func main() {
	// Read the JSON file
	fileContent, err := os.ReadFile("day4_part2.json")
	if err != nil {
		fmt.Println("Error reading the file:", err)
		return
	}

	// Create a slice to hold the data
	var matchDataArray []MatchData

	// Unmarshal the JSON data into the slice
	err = json.Unmarshal(fileContent, &matchDataArray)
	if err != nil {
		fmt.Println("Error unmarshalling JSON:", err)
		return
	}

	// // Print the data
	for i, data := range matchDataArray {
		for j := 1; j <= data.Matches && i+j < len(matchDataArray); j++ {
			matchDataArray[i+j].Count += matchDataArray[i].Count
		}
	}
	var sum int
	for _, data := range matchDataArray {
		sum += data.Count
	}
	fmt.Println(sum)
}
