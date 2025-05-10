#!/bin/bash

echo "Inserting test data into MongoDB approval collection..."
mongosh --host localhost:27017 <<EOF
  use mydatabase;
  db.approval.insertOne({
    "requestId": "REQ001",
    "status": "PENDING",
    "requestedBy": "user1",
    "requestedAt": new Date(),
    "description": "Sample approval request"
  });
  db.approval.insertOne({
    "requestId": "REQ002",
    "status": "APPROVED",
    "requestedBy": "user2",
    "requestedAt": new Date(),
    "approvedBy": "admin",
    "approvedAt": new Date(),
    "description": "Another sample approval request"
  });
  db.approval.find();
EOF

echo "Test data inserted!"
echo "You should now be able to see the CDC events in Kafka UI at http://localhost:8080"