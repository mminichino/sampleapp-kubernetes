#!/bin/sh

kubectl delete pvc data-sampleapp-redis-cluster-0
kubectl delete pvc data-sampleapp-redis-cluster-1
kubectl delete pvc data-sampleapp-redis-cluster-2
kubectl delete pvc data-sampleapp-redis-cluster-3
kubectl delete pvc data-sampleapp-redis-cluster-4
kubectl delete pvc data-sampleapp-redis-cluster-5
