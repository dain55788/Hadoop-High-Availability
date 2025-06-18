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
        'Yellow_Tripdata_Distcp_Backup',
        description='DistCp Backup Yellow Trip Data Periodically for Cluster',
        default_args=default_args,
        schedule_interval='*/30 * * * *',
        tags=['yellow_tripdata_distcp_backup'],
        catchup=False, ) as dag:

    start_backup_pipeline = EmptyOperator(
        task_id="start_backup_pipeline"
    )

    cluster_backup = BashOperator(
        task_id = "cluster_distcp_backup",
        bash_command="/scripts/distcp_cluster_backup.sh "
    )

    end_backup_pipeline = EmptyOperator(
        task_id="end_backup_pipeline"
    )

    start_backup_pipeline >> cluster_backup >> end_backup_pipeline
