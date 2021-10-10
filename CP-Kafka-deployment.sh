#!/bin/bash
set -e # if pipe fail exit script
set -u # if variable interpolation fail exit

# helm instalation
NAMESPACE=${1:-'kafka'}
REPLICA_COUNT=${2:-'3'}
IMAGE_TAG=${3:-'6.1.0'}

FILE=/usr/local/bin/helm
if [ ! -f "$FILE" ]; then
    curl https://get.helm.sh/helm-v3.7.0-darwin-amd64.tar.gz --output helm-v3.7.0-darwin-amd64.tar.gz
    tar -zxvf helm-v3.7.0-darwin-amd64.tar.gz
    mv darwin-amd64/helm /usr/local/bin/helm
fi

helm repo add confluentinc https://confluentinc.github.io/cp-helm-charts/ --force-update
helm repo update

kubectl create ns $NAMESPACE

helm install kafka confluentinc/cp-helm-charts \
--set cp-zookeeper.enabled=true,cp-kafka.enabled=true,cp-schema-registry.enabled=true \
--set cp-zookeeper.servers=$REPLICA_COUNT,cp-kafka.brokers=$REPLICA_COUNT \
--set cp-kafka-rest.enabled=false,cp-kafka-connect.enabled=false,cp-ksql-server.enabled=false,cp-control-center.enabled=false \
--set cp-kafka-rest.imageTag=$IMAGE_TAG,cp-zookeeper.imageTag=$IMAGE_TAG,cp-schema-registry.imageTag=$IMAGE_TAG \
-n $NAMESPACE

# helm uninstall kafka -n $NAMESPACE
# kubectl delete ns $NAMESPACE --force --grace-period=0