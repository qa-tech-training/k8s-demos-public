#!/bin/bash
kubectl create deploy web-one --image=nginx:1.23-alpine --replicas=3
kubectl create deploy web-two --image=httpd:2.4-alpine --replicas=3
kubectl expose deploy web-one --port=80 
kubectl expose deploy web-two --port=80