# Artemis

This repo is used for deploying artemis to EE for IQE testing via clowder.

Customized to run on port 5672.

Base image based on https://hub.docker.com/r/apache/activemq-artemis. 

## Test Utilities

- Send messages

utils/send_amqp_message.py --address umb-offering-service --content '{ "occurredOn" : "2025-03-29", "productCode" : "RH0180191", "productCategory": "Parent SKU", "eventType" : "Create" }'