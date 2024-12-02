from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

# Define the default_args dictionary to be used by the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 12, 2),
    'retries': 1,
}

# Define the DAG
dag = DAG(
    'bash_operator_example',
    default_args=default_args,
    description='A simple BashOperator example',
    schedule_interval=None,  # This can be set to a schedule if you need it
)

# Define the BashOperator task
bash_task = BashOperator(
    task_id='run_bash_command',
    bash_command='echo "Hello from BashOperator!"',  # This is the bash command you want to run
    dag=dag,
)

# Set task dependencies (if you have multiple tasks)
bash_task
