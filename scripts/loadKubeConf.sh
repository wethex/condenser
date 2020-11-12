#!/bin/sh
echo $KUBERNETES_CA | base64 -d > .kbca
cat .kbca
kubectl config set-cluster default --server=https://$KUBERNETES_SERVICE_HOST --certificate-authority=.kbca
kubectl config set-credentials default --token=$KUBERNETES_TOKEN
kubectl config set-context default --cluster=default --user=default --namespace=$KUBERNETES_NAMESPACE
kubectl config use-context default
kubectl config view