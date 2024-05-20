#!/bin/bash

# Directory containing the JSON files
DIRECTORY="/home/hp/connector_configs"

# URL for creating connectors (adjust as necessary for your environment)
CONNECTOR_API_URL="http://localhost:8083/connectors"

# Function to create a connector
create_connector() {
    local json_file=$1
    local connector_name=$(basename "$json_file" .json)
    
    echo "Creating connector from $json_file..."
    
    # Create the connector
    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" --data @"$json_file" "$CONNECTOR_API_URL")

    if [ "$response" -ne 201 ]; then
        echo "Failed to create connector $connector_name. HTTP response code: $response"
        return 1
    fi

    echo "Connector $connector_name created successfully."
    return 0
}

# Function to check the status of a connector
check_connector_status() {
    local connector_name=$1

    status=$(curl -s "$CONNECTOR_API_URL/$connector_name/status" | jq -r '.connector.state')

    if [ "$status" == "RUNNING" ]; then
        echo "Connector $connector_name is running."
        return 0
    else
        echo "Connector $connector_name is not running. Current status: $status"
        return 1
    fi
}

# Iterate over JSON files in the specified directory
for json_file in "$DIRECTORY"/*.json; do
    connector_name=$(basename "$json_file" .json)

    create_connector "$json_file"
    
    if [ $? -ne 0 ]; then
        echo "Exiting script due to creation failure of connector $connector_name."
        exit 1
    fi

    # Sleep for 10 seconds before checking the status
    echo "Sleeping for 2 seconds..."
    sleep 2

    check_connector_status "$connector_name"

    if [ $? -ne 0 ]; then
        echo "Exiting script because connector $connector_name failed to start."
        exit 1
    fi
done

echo "All connectors created and verified successfully."
