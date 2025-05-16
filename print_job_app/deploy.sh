#!/bin/bash

# Stop on any error
set -e

# Define variables
IMAGE_NAME="print-job-app"
IMAGE_TAG="latest"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"  # Default to Docker Hub
REPOSITORY_NAME="${REPOSITORY_NAME:-pettan93}"  # Replace with your repository name

# Check if Docker is logged in
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running or you don't have permission to use it"
    exit 1
fi

# Tag the image for the repository
FULL_IMAGE_NAME="${DOCKER_REGISTRY}/${REPOSITORY_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
echo "Tagging image as: ${FULL_IMAGE_NAME}"
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${FULL_IMAGE_NAME}"

# Push the image to the repository
echo "Pushing image to repository..."
docker push "${FULL_IMAGE_NAME}"

echo "Deploy completed successfully!"
echo "Your image is now available at: ${FULL_IMAGE_NAME}" 