#!/bin/bash

# Stop on any error
set -e

# Define variables
IMAGE_NAME="print-job-app"
IMAGE_TAG="latest"

# Build the Docker image
echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "Build completed successfully!"
echo "To run the container, use:"
echo "docker run -p 5000:5000 ${IMAGE_NAME}:${IMAGE_TAG}" 