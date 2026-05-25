from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import sys

sys.path.insert(0, '/opt/airflow')

default_args = {
    'owner': 'vlado',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='lol_ranked_pipeline',
    description='Solo/Duo Ranked personal performance pipeline for Osiris#1011',
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    schedule_interval='0 10 * * *',  # Daily at 10 AM
    catchup=False,
    tags=['lol', 'ranked', 'soloq', 'pipeline'],
) as dag:

    # Extract Solo/Duo Ranked matches
    def run_extraction():
        from extraction.riot_extractor import extract_matches_for_player
        extract_matches_for_player("Osiris", "1011", match_count=20)

    extract_task = PythonOperator(
        task_id='extract_matches',
        python_callable=run_extraction,
    )

    # Load raw JSON files into PostgreSQL
    def run_loading():
        from loading.load_to_postgres import load_all_matches
        load_all_matches()

    load_task = PythonOperator(
        task_id='load_to_postgres',
        python_callable=run_loading,
    )

    # Run dbt transformations
    dbt_task = BashOperator(
        task_id='run_dbt',
        bash_command='cd /opt/airflow/dbt/lol_ranked_dbt && dbt run --profiles-dir /opt/airflow/dbt/lol_ranked_dbt',
    )

    # Execution order
    extract_task >> load_task >> dbt_task