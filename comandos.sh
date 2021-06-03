#!/bin/bash

# Pré-requisitos:
#       Utilizar um usuário sudoer
#	Instalação do Docker: https://docs.docker.com/engine/install/centos/
#	Manage Docker as a non-root user: https://docs.docker.com/engine/install/linux-postinstall/

# Instalando minikube v1.20.0 on Centos 7.9.2009 , Kubernetes v1.20.2
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start

# Instalando Helm v3 - https://helm.sh/docs/intro/install/
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -f ./get_helm.sh

# "Instalando" o kubectl (a preguiça falou mais alto :P)
alias kubectl="minikube kubectl --"

# Criando os namespaces
kubectl apply -f kube-yaml/ns.yaml

# Criando configmap
kubectl apply -f kube-yaml/simpleapp-cm.yaml

# Criando deployment
kubectl apply -f kube-yaml/simpleapp.yaml

# Criando service
kubectl apply -f kube-yaml/simpleapp-svc.yaml

# Criando ingress
kubectl apply -f kube-yaml/challenge-ingress.yaml

# Adicionando helm repo elastic
helm repo add elastic https://helm.elastic.co

# Instalando Elasticsearch 7.13.1 - https://artifacthub.io/packages/helm/elastic/elasticsearch
helm install elasticsearch --version 7.13.1 elastic/elasticsearch --namespace logging -f helm-values/elasticsearch.yaml

# Instalando Kibana 7.13.1 - https://artifacthub.io/packages/helm/elastic/kibana
helm install kibana --version 7.13.1 elastic/kibana --namespace logging -f helm-values/kibana.yaml

# Instalando Fluentd 3.2.0 - https://artifacthub.io/packages/helm/kokuwa/fluentd-elasticsearch
helm repo add kokuwa https://kokuwaio.github.io/helm-charts
helm install fluentd --version 11.12.0 kokuwa/fluentd-elasticsearch --namespace logging -f helm-values/fluentd.yaml

# Instalando Prometheus 2.26.0 - https://artifacthub.io/packages/helm/prometheus-community/prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --version 14.1.1 --namespace monitoring -f helm-values/prometheus.yaml

sleep 5
kubectl get pod,service,deployment -A | grep -vP '^(default|kube)'

###
# CLEANUP - opção "nuclear" de limpeza, caso desejado
# for NS in monitoring logging prova kubernetes-dashboard; do kubectl delete namespace $NS; done; unset NS
###

