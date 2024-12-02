from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
import requests
import pandas as pd
import json
import os

# Define file paths
DATA_DIR = '/opt/airflow/dags/data'
EXTRACTED_DATA_PATH = os.path.join(DATA_DIR, 'raw_data.json')
TRANSFORMED_DATA_PATH = os.path.join(DATA_DIR, 'transformed_data.csv')

# Create DAG
with DAG(
    'dataset_etl_pipeline',
    description='A simple ETL pipeline for dataset processing',
    schedule_interval='@daily',  # Runs daily
    start_date=days_ago(1),
    catchup=False,
) as dag:

    # Step 1: Extract data (dummy example)
    def extract_data():
        print("Extracting data...")
        # Simulate extracting data (e.g., from an API or database)
        data = {
            "id": [1, 2, 3],
            "name": ["Alice", "Bob", "Charlie"],
            "age": [23, 35, 45],
        }
        # Simulate saving data as JSON
        with open(EXTRACTED_DATA_PATH, 'w') as f:
            json.dump(data, f)
        print(f"Data extracted and saved to {EXTRACTED_DATA_PATH}")

    # Step 2: Transform data
    def transform_data():
        print("Transforming data...")
        # Load the raw data from the JSON file
        with open(EXTRACTED_DATA_PATH, 'r') as f:
            raw_data = json.load(f)

        # Convert to DataFrame for transformation (e.g., calculation, filtering)
        df = pd.DataFrame(raw_data)
        
        # Example transformation: add a column for age group
        df['age_group'] = df['age'].apply(lambda x: 'Young' if x < 30 else 'Adult')
        
        # Save the transformed data to CSV
        df.to_csv(TRANSFORMED_DATA_PATH, index=False)
        print(f"Data transformed and saved to {TRANSFORMED_DATA_PATH}")

    # Step 3: Load data (simulated by saving data to a file or database)
    def load_data():
        print("Loading data...")
        # In a real scenario, this could involve loading into a database or cloud storage
        with open(TRANSFORMED_DATA_PATH, 'r') as f:
            transformed_data = pd.read_csv(f)
            print(f"Loaded data: {transformed_data.head()}")

    # Define tasks
    extract_task = PythonOperator(
        task_id='extract_data',
        python_callable=extract_data,
    )

    transform_task = PythonOperator(
        task_id='transform_data',
        python_callable=transform_data,
    )

    load_task = PythonOperator(
        task_id='load_data',
        python_callable=load_data,
    )

    # Set task dependencies
    extract_task >> transform_task >> load_task
