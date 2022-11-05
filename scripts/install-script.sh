#!/usr/bin/env bash
# run as root
echo "====== START ======"
sudo su

apt-get update

apt -y install postgresql postgresql-contrib

sudo systemctl start postgresql.service

# installing PostgreSQL and preparing the database / VERSION 9.5 (or higher)

echo "CREATE USER airflow PASSWORD 'airflow'; CREATE DATABASE airflow; GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO airflow;" | sudo -u postgres psql
sudo -u postgres sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|" /etc/postgresql/*/main/postgresql.conf
sudo -u postgres sed -i "s|127.0.0.1/32|0.0.0.0/0|" /etc/postgresql/*/main/pg_hba.conf
sudo -u postgres sed -i "s|::1/128|::/0|" /etc/postgresql/*/main/pg_hba.conf
#service postgresql restart


# installing Redis and setting up the configurations
apt-get -y install redis-server

sed -i "s|bind |#bind |" /etc/redis/redis.conf
sed -i "s|protected-mode yes|protected-mode no|" /etc/redis/redis.conf
sed -i "s|supervised no|supervised systemd|" /etc/redis/redis.conf
service redis restart

# installing python 3.x and dependencies
apt-get update
apt-get -y install python3 python3-dev python3-pip python3-wheel
pip install --upgrade pip
#pip install -r ../requirements.txt
pip install apache-airflow==2.4.2
#pip install boto3==1.18.33
#pip install cx-Oracle==8.2.1
#pip install fastparquet==0.7.1
#pip install numpy==1.21.2
#pip install pyarrow==5.0.0
#pip install pyodbc==4.0.32
#pip install flower==0.9.7
pip install celery==5.1.2
pip install psycopg2-binary==2.9.3
pip install redis==4.1.0
pip install click==8.1.3
pip install black==22.3.0
#pip install workalendar==16.3.0
#pip install pymysql==1.0.2
#pip install mysql-connector-python==8.0.29
#pip install jsonlines==3.1.0


# create airflow user with sudo capability
adduser airflow --gecos "airflow,,," --disabled-password
echo "airflow:airflow" | chpasswd
usermod -aG sudo airflow
echo "airflow ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

AIRFLOW_HOME=/opt/airflow

# airflow local
mkdir -p $AIRFLOW_HOME
mkdir -p /var/log/airflow $AIRFLOW_HOME/dags $AIRFLOW_HOME/plugins $AIRFLOW_HOME/logs
chmod -R 777 $AIRFLOW_HOME
chown -R airflow:airflow $AIRFLOW_HOME
chown airflow /var/log/airflow

# create a persistent varable for AIRFLOW across all users env
#echo export AIRFLOW_HOME=/opt/airflow > /etc/profile.d/airflow.sh
#echo export AIRFLOW__CORE__LOAD_EXAMPLES='false' >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CORE__DEFAULT_UI_TIMEZONE='America/Sao_Paulo' >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CORE__DEFAULT_TIMEZONE='America/Sao_Paulo' >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE='America/Sao_Paulo' >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__WEBSERVER__INSTANCE_NAME='SHELL_AIRFLOW' >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost:5432/airflow >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CORE__EXECUTOR=CeleryExecutor >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CELERY__BROKER_URL=redis://:@localhost:6379/0 >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CELERY__RESULT_BACKEND=db+postgresql://airflow:airflow@localhost:5432/airflow >> /etc/profile.d/airflow.sh
#echo export AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION='true' >> /etc/profile.d/airflow.sh

#sudo tee -a /tmp/airflow_environment<<EOL
#AIRFLOW_HOME=/opt/airflow
#AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION='true'
#AIRFLOW__CORE__LOAD_EXAMPLES='false'
#AIRFLOW__CORE__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'
#AIRFLOW__CORE__DEFAULT_TIMEZONE='America/Sao_Paulo'
#AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'
#AIRFLOW__WEBSERVER__INSTANCE_NAME='SHELL_AIRFLOW'
#AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost:5432/airflow
#AIRFLOW__CELERY__BROKER_URL=redis://:@localhost:6379/0
#AIRFLOW__CORE__EXECUTOR=CeleryExecutor
#AIRFLOW__CELERY__RESULT_BACKEND=db+postgresql://airflow:airflow@localhost:5432/airflow
#EOL

declare -a arr=(
"AIRFLOW_HOME=/opt/airflow" 
"AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION='true'" 
"AIRFLOW__CORE__LOAD_EXAMPLES='false'" 
"AIRFLOW__CORE__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'" 
"AIRFLOW__CORE__DEFAULT_TIMEZONE='America/Sao_Paulo'" 
"AIRFLOW__WEBSERVER__DEFAULT_UI_TIMEZONE='America/Sao_Paulo'" 
"AIRFLOW__WEBSERVER__INSTANCE_NAME='SHELL_AIRFLOW'" 
"AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost:5432/airflow" 
"AIRFLOW__CELERY__BROKER_URL=redis://:@localhost:6379/0" 
"AIRFLOW__CORE__EXECUTOR=CeleryExecutor" 
"AIRFLOW__CELERY__RESULT_BACKEND=db+postgresql://airflow:airflow@localhost:5432/airflow"
)
## clean file
truncate -s 0 /etc/profile.d/airflow.sh
## now loop through the above array
for i in "${arr[@]}"
do
   echo export "$i" >> /etc/profile.d/airflow.sh
done

truncate -s 0 /tmp/airflow_environment
for i in "${arr[@]}"
do
   echo "$i" >> /tmp/airflow_environment
done


cat /tmp/airflow_environment | sudo tee -a /etc/default/airflow

# following commands should be run under airflow user
echo "===== install airflow ======"
su - airflow 
source /etc/profile.d/airflow.sh
echo $AIRFLOW_HOME
airflow db init

airflow users create \
--username admin \
--firstname Peter \
--password admin \
--lastname Parker \
--role Admin \
--email spiderman@superhero.org

# create symbol link to vagrant local
ln -s /vagrant/dags/* /opt/airflow/dags

echo "====== airflow service ====="
# # setting up Airflow 
sudo su
sudo tee -a /usr/bin/airflow-webserver <<EOL
#!/usr/bin/env bash
airflow webserver
EOL

sudo tee -a /usr/bin/airflow-scheduler <<EOL
#!/usr/bin/env bash
airflow scheduler
EOL

sudo tee -a /usr/bin/airflow-worker <<EOL
#!/usr/bin/env bash
airflow celery worker
EOL

chmod 755 /usr/bin/airflow-webserver
chmod 755 /usr/bin/airflow-scheduler
chmod 755 /usr/bin/airflow-worker

echo "
[Unit]
Description=Airflow daemon
After=network.target

[Service]
EnvironmentFile=/etc/default/airflow
User=airflow
Group=airflow
Type=simple
Restart=always
ExecStart=/usr/bin/airflow-webserver
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
    " >> /tmp/webserver.service

echo "
[Unit]
Description=Airflow daemon
After=network.target

[Service]
EnvironmentFile=/etc/default/airflow
User=airflow
Group=airflow
Type=simple
Restart=always
ExecStart=/usr/bin/airflow-scheduler
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
    " >> /tmp/scheduler.service

echo "
[Unit]
Description=Airflow daemon
After=network.target

[Service]
EnvironmentFile=/etc/default/airflow
User=airflow
Group=airflow
Type=simple
Restart=always
ExecStart=/usr/bin/airflow-worker
RestartSec=5s
PrivateTmp=true

[Install]
WantedBy=multi-user.target
    " >> /tmp/worker.service

sudo cat /tmp/webserver.service >> /etc/systemd/system/webserver.service
sudo cat /tmp/scheduler.service >> /etc/systemd/system/scheduler.service
sudo cat /tmp/worker.service >> /etc/systemd/system/worker.service

sudo systemctl enable webserver.service
sudo systemctl start webserver.service
#sudo systemctl status webserver.service
#journalctl -u webserver.service -b
sudo systemctl enable scheduler.service
sudo systemctl start scheduler.service
#sudo systemctl restart scheduler.service
#sudo systemctl status scheduler.service
#journalctl -u scheduler.service -b
sudo systemctl enable worker.service
sudo systemctl start worker.service
#sudo systemctl status worker.service
#journalctl -u worker.service -b
apt-get purge --auto-remove -yqqq
apt-get autoremove -yqq --purge
apt-get clean

chmod -R 777 $AIRFLOW_HOME
chown -R airflow:airflow $AIRFLOW_HOME
echo "====== END ======="