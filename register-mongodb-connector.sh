#!/bin/bash

echo "Waiting for Kafka Connect to start listening on localhost:8083..."
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -ne 200 ]; do
  echo "Kafka Connect not ready yet. Waiting 10 seconds..."
  sleep 10
done
echo "Kafka Connect is ready!"

echo "Creating Debezium MongoDB source connector..."
curl -X POST \
  -H "Content-Type: application/json" \
  --data '{
    "name": "mongodb-connector",
    "config": {
      "connector.class": "io.debezium.connector.mongodb.MongoDbConnector",
      "mongodb.connection.string": "mongodb://mongodb:27017",
      "mongodb.name": "dbserver1",
      "collection.include.list": "mydatabase.approval",
      "database.include.list": "mydatabase",
      "topic.prefix": "mongodb",
      "tasks.max": "1",
      "tombstones.on.delete": "true",
      "provide.transaction.metadata": "true",
      "capture.mode": "change_streams_update_full_with_pre_image"
    }
  }' \
  http://localhost:8083/connectors

echo ""
echo "Connector status:"
curl -s http://localhost:8083/connectors/mongodb-connector/status | jq