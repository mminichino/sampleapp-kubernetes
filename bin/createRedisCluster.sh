#!/bin/sh
#
NAMESPACE=default

while getopts "n:" opt
do
  case $opt in
    n)
      NAMESPACE=$OPTARG
      ;;
    \?)
      echo "Usage: $0 [ -n namespace ]"
      exit 1
      ;;
  esac
done

kubectl exec -n ${NAMESPACE} -it sampleapp-redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 $(kubectl get pods -n ${NAMESPACE} -l app=sampleapp-redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')
