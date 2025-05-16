#!/bin/bash

# Exit on any error (except for container removal)
set -e

# Configuration
CONTAINER_NAME="print-job-app"
IMAGE_NAME="docker.io/pettan93/print-job-app:latest"
CONTAINER_PORT="5000"

echo "Starting container update process..."

# Pull the latest image
echo "Pulling latest image..."
docker pull ${IMAGE_NAME}

# Check if the container is running and stop it
if docker ps -q -f name=${CONTAINER_NAME} >/dev/null; then
    echo "Stopping running container..."
    docker stop ${CONTAINER_NAME} || echo "Warning: Failed to stop container (it may not exist)"
fi

# Try to remove the container if it exists (don't exit on error)
echo "Attempting to remove existing container..."
docker rm ${CONTAINER_NAME} 2>/dev/null || echo "No existing container to remove"

# Run new container
echo "Starting new container..."
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${CONTAINER_PORT}:${CONTAINER_PORT} \
    ${IMAGE_NAME}

# Wait a moment for the container to start
sleep 2

# Verify the container is running
if docker ps -q -f name=${CONTAINER_NAME} >/dev/null; then
    echo "Container successfully started!"
    echo -e "\nContainer logs:"
    docker logs ${CONTAINER_NAME}
    
    echo -e "\nContainer Details:"
    docker ps -f name=${CONTAINER_NAME}
    
    echo -e "\nUpdate completed successfully!"
else
    echo "Error: Container failed to start!"
    echo "Checking container logs for errors:"
    docker logs ${CONTAINER_NAME} || echo "Could not retrieve logs"
    exit 1
fi 