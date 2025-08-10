#!/usr/bin/env bash

kind create cluster --name monitoring-cluster --config kind-config.yaml

kubectl create ns monitoring
helm upgrade --install prom ./prometheus -n monitoring
helm upgrade --install gfn  ./grafana    -n monitoring

kubectl create ns app-dev
helm upgrade --install bl ./basic-login -n app-dev
