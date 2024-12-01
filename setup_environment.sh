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
    echo "Checking if docker-compose.yml exists..."
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo "Error: docker-compose.yml not found!"
        exit 1
    fi

    echo "Starting Airflow environment using Docker Compose..."
    docker-compose up -d
}

# Initialize the Airflow database
init_airflow_db() {
    echo "Checking if docker-compose.yml exists..."
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo "Error: docker-compose.yml not found!"
        exit 1
    fi

    echo "Initializing the Airflow database..."
    docker-compose exec airflow-webserver airflow db init
}

# Handle deprecation warning by modifying the Airflow config
configure_airflow() {
    echo "Configuring Airflow to resolve deprecation warning..."

    # Ensure the correct section for sql_alchemy_conn in the [database] section
    AIRFLOW_CONFIG_PATH="/opt/airflow/airflow.cfg"

    # Add the sql_alchemy_conn option under [database] if not present
    if ! grep -q "sql_alchemy_conn" "$AIRFLOW_CONFIG_PATH"; then
        echo "sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres:5432/airflow" >> "$AIRFLOW_CONFIG_PATH"
        echo "Configured sql_alchemy_conn under the [database] section in airflow.cfg."
    fi
}

# Main setup process
ensure_directories
start_docker_containers
configure_airflow
init_airflow_db

echo "Airflow environment setup complete!"
