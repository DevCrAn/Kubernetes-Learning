#!/bib/bash

set -e

echo "Inicializando Minikube..."
minikube start --driver=docker --kubernetes-version=v1.33.0

kubectl cluster-info

echo "Esperando a que el API Server esté disponible..."
kubectl wait --for=condition=Available --timeout=90s deployment/kube-apiserver -n kube-system


echo 'alias k=kubectl' >> ~/.bashrc
source ~/.bashrc

c

echo "Minikube iniciado correctamente con Kubernetes v.1.33.0"

