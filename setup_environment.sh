#!/bin/bash

# Define paths for dags and logs
PROJECT_DIR=$(pwd)
DAGS_DIR="${PROJECT_DIR}/dags"
LOGS_DIR="${PROJECT_DIR}/logs"
DOCKER_COMPOSE_FILE="${PROJECT_DIR}/docker-compose.yml"

# Ensure the dags and logs directories exist
ensure_directories() {
    echo "Ensuring required directories exist..."
    mkdir -p "$DAGS_DIR" "$LOGS_DIR"
}

# Start up the Docker containers using docker-compose
start_docker_containers() {
    echo "Starting Airflow environment using Docker Compose..."
    docker-compose up -d
}

# Initialize the Airflow database
init_airflow_db() {
    echo "Initializing the Airflow database..."
    docker-compose exec airflow-webserver airflow db init
}

# Stop and remove Docker containers
stop_docker_containers() {
    echo "Stopping Airflow Docker containers..."
    docker-compose down
}

# Main setup process
ensure_directories
start_docker_containers
init_airflow_db

echo "Airflow environment setup complete!"
