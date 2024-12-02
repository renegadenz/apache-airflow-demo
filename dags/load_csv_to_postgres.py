from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from datetime import datetime, timedelta
import pandas as pd
import psycopg2

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 12, 2),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'load_csv_to_postgresql',
    default_args=default_args,
    description='A simple DAG to load CSV data into PostgreSQL',
    schedule_interval=None,  # Adjust to your desired schedule
)

# Path to the CSV file
csv_file_path = '/tmp/sample_data.csv'

# Function to read and load CSV data to PostgreSQL
def load_csv_to_postgres():
    # Read the CSV file into a pandas DataFrame
    df = pd.read_csv(csv_file_path)

    # Database connection parameters
    conn = psycopg2.connect(
        dbname='airflow',
        user='airflow',
        password='airflow',
        host='postgres',  # This assumes PostgreSQL is running in a Docker container called "postgres"
        port='5432'
    )
    
    # Create a cursor object using the connection
    cursor = conn.cursor()

    # Create table if it doesn't exist
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INT PRIMARY KEY,
        name VARCHAR(50),
        age INT
    );
    """)
    
    # Insert Data into the table
    for index, row in df.iterrows():
        cursor.execute("""
        INSERT INTO users (id, name, age) VALUES (%s, %s, %s)
        """, (row['id'], row['name'], row['age']))
    
    # Commit the transaction and close the connection
    conn.commit()
    cursor.close()
    conn.close()

# PythonOperator to load the CSV data
load_csv_task = PythonOperator(
    task_id='load_csv_to_postgresql',
    python_callable=load_csv_to_postgres,
    dag=dag,
)

# BashOperator to simulate a command or notify (optional)
notify_task = PostgresOperator(
    task_id='notify_data_load',
    postgres_conn_id='postgres_default',  # Ensure you have a connection with this ID in Airflow's UI
    sql="SELECT COUNT(*) FROM users;",  # Query to verify the data count in the PostgreSQL table
    autocommit=True,
    dag=dag,
)

# Set the task dependencies
load_csv_task >> notify_task
