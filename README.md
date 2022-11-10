# Vagrant + Airflow

Projeto utilizo vagrant para iniciar um projeto com airflow.
A proposta de se utilizar vagrant e não docker somente para utilizar o airflow, 
consiste em se ter mair flexibilidade e desenvolvimento.

# Vagrant + Airflow

Utilizando somente [install-script.sh](./scripts/install-script.sh)
teremos uma vm com o airflow + postgresql + redis, e os serviços
webserver, scheduler e worker subindo como serviços.

```
# inicia a vm instalando
vagrant up

# acessar a vm
vagrant ssh

# destruir vm
vagrant destroy -f

# atualizar vm com shell
vagrant provision
```

## Vagrant com serviços Docker
é possivel tambem instalar o airflow na VM, e subir os serviços do
postgresql e redis com o docker, este modo eu gosto particularmente pela facilidade.

## Dags

Na pasta [dags](./dags/) temos as dags a serem utilizadas no airflow.