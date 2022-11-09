echo "====== START ======"
sudo su
sudo systemctl stop webserver.service
sudo systemctl stop scheduler.service
sudo systemctl stop worker.service
AIRFLOW_VERSION=2.4.2
PYTHON_VERSION="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
# For example: 3.7
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-no-providers-${PYTHON_VERSION}.txt"
# For example: https://raw.githubusercontent.com/apache/airflow/constraints-2.4.2/constraints-no-providers-3.7.txt
#pip install "apache-airflow==${AIRFLOW_VERSION}" --upgrade --constraint "${CONSTRAINT_URL}" --force-reinstall --ignore-installed
pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"#--upgrade --constraint "${CONSTRAINT_URL}" --force-reinstall --ignore-installed
echo "===== update airflow config ======"
su - airflow 
source /etc/profile.d/airflow.sh
echo $AIRFLOW_HOME
#rm -rf $AIRFLOW_HOME/airflow.cfg
airflow db upgrade
sudo systemctl start webserver.service
sudo systemctl start scheduler.service
sudo systemctl start worker.service
echo "====== END ======"