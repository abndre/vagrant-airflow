#!/bin/bash
echo "airflow"
export AIRFLOW_HOME=/opt/airflow
export AIRFLOW__CORE__LOAD_EXAMPLES='false'
export AIRFLOW__CORE__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'
export AIRFLOW__CORE__DEFAULT_TIMEZONE='America/Sao_Paulo'
export AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'
export AIRFLOW__WEBSERVER__INSTANCE_NAME='VAGRANT_AIRFLOW'
export AIRFLOW__CORE__EXECUTOR=CeleryExecutor
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost:5432/airflow
export AIRFLOW__CELERY__RESULT_BACKEND=db+postgresql://airflow:airflow@localhost:5432/airflow
export AIRFLOW__CELERY__BROKER_URL=redis://:@redis:6379/0
airflow db init
airflow users create \
--username admin \
--firstname Peter \
--password admin \
--lastname Parker \
--role Admin \
--email spiderman@superhero.org
airflow webserver -D
airflow scheduler -D
airflow celery worker -D