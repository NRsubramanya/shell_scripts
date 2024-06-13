#!/bin/bash

# Kafka details
KAFKA_BROKERS="localhost:9092"
BROKER_LIST="1,2,3"
TEMP_DIR="/root"
NEW_REASSIGN_FILE="$TEMP_DIR/new_reassign.json"


# Get the list of topics with a replication factor of 1 or 2
topics=$(kafka-topics --describe --bootstrap-server $KAFKA_BROKERS | grep -E 'ReplicationFactor: (1|2)' | awk '{print $2}')

if [ -z "$topics" ]; then
    echo "No eligible topics found for replication factor change."
    exit 0
fi

echo "Topics to modify:"
echo "$topics"

# Initialize the reassignment JSON
reassignment_json=$(jq -n '{version: 1, partitions: []}')

# Iterate over each topic to construct the reassignment JSON
while IFS= read -r topic; do
  echo "Processing topic: $topic"
  partition=$(kafka-topics --describe --bootstrap-server $KAFKA_BROKERS --topic "$topic" | grep 'Partition:' | awk '{print $4}')

  while IFS= read -r partition; do
    echo "  Processing partition: $partition of topic: $topic"
    if ! [[ "$partition" =~ ^[0-9]+$ ]]; then
        echo "Error: Partition '$partition' is not a valid number."
        continue
    fi
    reassignment_json=$(echo "$reassignment_json" | jq \
      --arg topic "$topic" \
      --argjson partition "$partition" \
      '.partitions += [{"topic": $topic, "partition": $partition, "replicas": [1,2,3]}]')
  done <<< "$partition"
done <<< "$topics"

echo "Reassignment JSON:"
echo "$reassignment_json" | jq .

# Verify that the reassignment JSON is valid
if ! echo "$reassignment_json" | jq . > /dev/null 2>&1; then
    echo "Error: The reassignment JSON is not valid."
    exit 1
fi

# Check if the reassignment JSON has partitions to reassign
if [ $(echo "$reassignment_json" | jq '.partitions | length') -eq 0 ]; then
    echo "Error: Partition reassignment list cannot be empty"
    exit 1
fi

# Write the reassignment JSON to a file
echo "$reassignment_json" > $NEW_REASSIGN_FILE

# Execute the reassignment
kafka-reassign-partitions --bootstrap-server $KAFKA_BROKERS --reassignment-json-file $NEW_REASSIGN_FILE --execute

echo "Replication factor change initiated. Check Kafka logs for progress."
