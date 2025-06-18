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
        'Yellow_Tripdata_Snapshot_Backup',
        description='Snapshot Backup Yellow Trip Data Periodically',
        default_args=default_args,
        schedule_interval='*/15 * * * *',
        tags=['yellow_tripdata_snapshot_backup'],
        catchup=False, ) as dag:

    start_backup_pipeline = EmptyOperator(
        task_id="start_backup_pipeline"
    )

    snapshot_backup = BashOperator(
        task_id = "cluster_snapshot_backup",
        bash_command="/scripts/snapshot_backup.sh "
    )

    end_backup_pipeline = EmptyOperator(
        task_id="end_backup_pipeline"
    )

    start_backup_pipeline >> snapshot_backup >> end_backup_pipeline
