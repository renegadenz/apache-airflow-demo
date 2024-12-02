from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta

# Default arguments for the tasks
default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': datetime(2024, 12, 1),
}

# Create the DAG object
dag = DAG(
    'simple_python_dag',
    default_args=default_args,
    description='A simple DAG with PythonOperator',
    schedule_interval=timedelta(days=1),  # Run once a day
)

# Python function to be used in the PythonOperator
def print_hello():
    print("Hello, this is a test of the PythonOperator!")

# Create the task
python_task = PythonOperator(
    task_id='python_task',
    python_callable=print_hello,
    dag=dag,
)

# Task dependencies (in this case, no dependencies)
python_task
