#!/bin/bash

# Define the Kafka Connect REST API endpoint as connect url
CONNECT_URL="http://localhost:8083"

# Create a directory to store the connector configurations
CONFIG_DIR="connector_configs"
mkdir -p $CONFIG_DIR

# Get the list of connectors to iterate
CONNECTORS=$(curl -s "$CONNECT_URL/connectors" | jq -r '.[]')

# Iterate over each connector
for CONNECTOR in $CONNECTORS; do
  # Get the connector configuration
  CONFIG=$(curl -s "$CONNECT_URL/connectors/$CONNECTOR" | jq 'del(.tasks, .type)')
  
  # Write the configuration to a file
  echo "$CONFIG" > "$CONFIG_DIR/$CONNECTOR.json"
  
  echo "Configuration for $CONNECTOR written to $CONFIG_DIR/$CONNECTOR.json"
done

echo "All connector configurations have been written to the $CONFIG_DIR directory."
