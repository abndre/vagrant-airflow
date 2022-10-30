#!/bin/bash

function create_docker_compose {
echo "Starting my script..."
OUT=/opt/airflow/docker-compose.yml
cat <<'EOF' >$OUT
version: '3'
services:
  postgres:
    image: postgres:13
    container_name: "postgres"
    hostname: "postgres"
    ports:
      - 5432:5432
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
      POSTGRES_DB: airflow
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
    restart: always

  redis:
    image: redis:latest
    container_name: "redis"
    ports:
      - 6379:6379
    restart: always

volumes:
  postgres-db-volume:
EOF
echo "END SCRIPT"
}

function start_docker {
    echo "===== START ====="
    echo "===== etapa docker ====="
    export AIRFLOW_HOME=/opt/airflow
    sudo docker-compose -f $AIRFLOW_HOME/docker-compose.yml stop -v
    sudo docker-compose -f $AIRFLOW_HOME/docker-compose.yml -v
    sudo docker rm -f $(sudo docker ps -a -q)
    sudo docker volume rm $(sudo docker volume ls -q)
    sudo docker-compose -f $AIRFLOW_HOME/docker-compose.yml up -d
    echo "===== END ====="  
}

create_docker_compose
start_docker