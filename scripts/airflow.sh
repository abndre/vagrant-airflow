#!/bin/bash
# https://docs.vagrantup.com/v2/provisioning/shell.html

#source "/vagrant"

function docker_airflow {
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


echo "setup airflow"
variaveis
docker_airflow