#!/bin/bash
# https://docs.vagrantup.com/v2/provisioning/shell.html

#source "/vagrant"
AIRFLOW_VERSION=2.4.2

function update {
	apt-get update
}

function python_pip {
    sudo apt-get install -y software-properties-common
    sudo apt-add-repository universe
    sudo apt-get update
    sudo apt-get install -y python-setuptools
    sudo apt install -y python3-pip
    sudo -H pip3python install --upgrade pip
    pip install psycopg2-binary==2.9.3
    pip3 install apache-airflow==$AIRFLOW_VERSION
    pip3 install redis==4.1.0
    pip3 install celery==5.2.3
    }

function airflow_path {
    mkdir -p /opt/airflow
    chmod -R 777 /opt/airflow
}

function docker {
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
    sudo apt-get update
    sudo apt install -y docker-ce
}

function docker_compose {
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

echo "setup ubuntu"

update
docker
docker_compose
python_pip
airflow_path

echo "end"