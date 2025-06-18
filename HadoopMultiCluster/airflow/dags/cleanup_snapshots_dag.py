from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.dates import days_ago
from datetime import timedelta
from airflow import DAG

default_args = {
    'owner': 'DainyNguyen',
    'depends_on_past': False,
    'start_date': days_ago(0),
    'email': ['dain55788@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': True,
    'retries': 1,
    'retry_delay': timedelta(seconds=10),
    'catchup_by_default': False
}

with DAG(
        'Yellow_Tripdata_Cleanup_Snapshot',
        description='Cleanup Yellow Trip Data Snapshot For Effective Storage Capability',
        default_args=default_args,
        schedule_interval='0 */2 * * *',
        tags=['yellow_tripdata_distcp_backup'],
        catchup=False, ) as dag:

    start_cleaning_up = EmptyOperator(
        task_id="start_cleaning_up"
    )

    cluster_backup = BashOperator(
        task_id = "cleanup_snapshot",
        bash_command="/scripts/cleanup_snapshots.sh "
    )

    end_cleaning_up = EmptyOperator(
        task_id="end_cleaning_up"
    )

    start_cleaning_up >> cluster_backup >> end_cleaning_up
