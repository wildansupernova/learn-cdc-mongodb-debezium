# Learning CDC with Debezium, MongoDB, and Kafka

This project sets up a local environment for exploring Change Data Capture (CDC) using Debezium with MongoDB 7 and Kafka. This setup enables you to monitor changes to your MongoDB collections in real-time and see those changes streamed to Kafka topics.

## Components

- **MongoDB 7**: Source database (configured as a replica set, which is required for CDC)
- **Kafka & Zookeeper**: Messaging platform where CDC events are published
- **Debezium Connect**: The service that monitors MongoDB and publishes changes to Kafka
- **Kafka UI**: Web interface to monitor Kafka topics and messages

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed on your machine

### Start the Environment

1. Start all services using Docker Compose:

```bash
docker-compose up -d
```

2. Wait 1-2 minutes for all services to start properly. The first startup takes longer as MongoDB needs to initialize the replica set.

### Register the Debezium Connector

Run the connector registration script to set up CDC for the approval collection:

```bash
./register-mongodb-connector.sh
```

This script will:
- Wait for the Kafka Connect service to be available
- Create a connector configuration that monitors the `approval` collection in `mydatabase`
- Show the connector status when complete

### Insert Test Data

To see CDC in action, insert some test data:

```bash
./insert-test-data.sh
```

This will insert sample documents into the `approval` collection in MongoDB.

### Monitor Changes Using Kafka UI

1. Open Kafka UI in your browser:
   http://localhost:8080

2. Navigate to the "Topics" section

3. Look for topics with the prefix `mongodb.dbserver1.mydatabase.approval`
   - These topics contain the change events from MongoDB

4. Click on any topic to see the messages (events) that have been published

## Testing the CDC Pipeline

After the initial setup, you can:

1. **Insert more data**: Add new documents to the `approval` collection
2. **Update existing data**: Modify documents in the collection
3. **Delete data**: Remove documents from the collection

All these changes will be captured by Debezium and published to Kafka.

## Example MongoDB Operations

Connect to MongoDB and try these operations:

```javascript
// Connect to MongoDB
mongosh --host localhost:27017

// Use the database
use mydatabase

// Insert a new document
db.approval.insertOne({
  "requestId": "REQ003",
  "status": "PENDING",
  "requestedBy": "user3",
  "requestedAt": new Date(),
  "description": "New approval request"
})

// Update an existing document
db.approval.updateOne(
  { requestId: "REQ001" },
  { $set: { status: "APPROVED", approvedBy: "admin", approvedAt: new Date() }}
)

// Delete a document
db.approval.deleteOne({ requestId: "REQ002" })
```

After each operation, check the Kafka UI to see the corresponding change events.

## Architecture

```
┌─────────────┐    ┌───────────────┐    ┌───────────────┐    ┌─────────────┐
│  MongoDB 7  │◄───┤ Debezium      │◄───┤ Kafka         │◄───┤ Kafka UI    │
│ (Replica Set)│    │ Connect       │    │               │    │             │
└─────────────┘    └───────────────┘    └───────────────┘    └─────────────┘
    │                     │                    │                    │
    └─────────────────────┴────────────────────┴────────────────────┘
                             Docker Network
```

## Notes

- This setup is for testing/learning only and doesn't use persistent volumes
- MongoDB is configured without authentication for simplicity
- The Debezium connector is configured to monitor only the `approval` collection
- in order to debezium to include before you must use capture mode "*pre_images" and activate in collection
```
db.runCommand({
  collMod: "approval",
  changeStreamPreAndPostImages: { enabled: true }
});
```