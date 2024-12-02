#!/bin/bash

# Define paths for dags and logs
PROJECT_DIR=$(pwd)
DAGS_DIR="${PROJECT_DIR}/dags"
LOGS_DIR="${PROJECT_DIR}/logs"
DOCKER_COMPOSE_FILE="${PROJECT_DIR}/docker-compose.yml"

# Airflow default username and password
AIRFLOW_USER="airflow"
AIRFLOW_PASSWORD="airflow"

# Ensure the dags and logs directories exist
ensure_directories() {
    echo "Ensuring required directories exist..."
    mkdir -p "$DAGS_DIR" "$LOGS_DIR"
}

# Start the PostgreSQL container first
start_postgres() {
    echo "Starting PostgreSQL container..."
    docker-compose up -d postgres
}

# Wait for PostgreSQL to be ready
wait_for_postgres() {
    echo "Waiting for PostgreSQL to be ready..."
    until docker-compose exec postgres pg_isready -U airflow > /dev/null 2>&1; do
        echo "Waiting for PostgreSQL..."
        sleep 5
    done
    echo "PostgreSQL is ready!"
}

# Start the Airflow webserver container to ensure airflow.cfg is generated
start_airflow_webserver() {
    echo "Starting Airflow webserver container..."
    docker-compose up -d airflow-webserver
}

# Run airflow db init in the airflow-webserver container
init_airflow_db() {
    echo "Initializing the Airflow database..."
    docker-compose exec airflow-webserver airflow db init
}

# Handle deprecation warning by modifying the Airflow config
configure_airflow() {
    echo "Configuring Airflow to resolve deprecation warning..."

    AIRFLOW_CONFIG_PATH="/opt/airflow/airflow.cfg"

    # Remove sql_alchemy_conn from the [core] section if present
    sed -i '/^\[core\]/,/^\[database\]/s/^sql_alchemy_conn.*/# Removed from [core] section/;' "$AIRFLOW_CONFIG_PATH"

    # Add the sql_alchemy_conn option under [database] if not present
    if ! grep -q "sql_alchemy_conn" "$AIRFLOW_CONFIG_PATH"; then
        echo "sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@postgres:5432/airflow" >> "$AIRFLOW_CONFIG_PATH"
        echo "Configured sql_alchemy_conn under the [database] section in airflow.cfg."
    fi
}

# Create a default Airflow user
create_airflow_user() {
    echo "Creating Airflow user with username '$AIRFLOW_USER' and password '$AIRFLOW_PASSWORD'..."

    # Run the airflow CLI to create the user
    docker-compose run --rm airflow-webserver airflow users create \
        --username "$AIRFLOW_USER" \
        --firstname "Airflow" \
        --lastname "Admin" \
        --role Admin \
        --email "airflow@example.com" \
        --password "$AIRFLOW_PASSWORD"

    echo "Airflow user created successfully."
}

# Start the Airflow webserver and scheduler containers
start_airflow_services() {
    echo "Starting Airflow webserver and scheduler..."
    docker-compose up -d airflow-webserver airflow-scheduler
}

# Main setup process
ensure_directories
start_postgres
wait_for_postgres
start_airflow_webserver
init_airflow_db
configure_airflow
create_airflow_user
start_airflow_services

echo "Airflow environment setup complete!"
