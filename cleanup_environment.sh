#!/bin/bash

# Define the Docker Compose file location
DOCKER_COMPOSE_FILE="./docker-compose.yml"

# Check if docker-compose.yml exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Error: docker-compose.yml not found in the current directory!"
    exit 1
fi

# Stop and remove all containers, networks, and volumes
cleanup_docker() {
    echo "Stopping and removing Docker containers, networks, and volumes..."
    docker-compose down -v
}

# Clean up any additional orphaned containers, volumes, or networks
cleanup_orphaned() {
    echo "Cleaning up orphaned containers, volumes, and networks..."
    docker system prune -af
}

# Run cleanup functions
cleanup_docker
cleanup_orphaned

echo "Docker environment cleaned up successfully!"
