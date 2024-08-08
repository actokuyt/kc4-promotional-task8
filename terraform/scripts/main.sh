#!/bin/bash

# Install docker using the convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Start Minikube using Docker driver
sudo minikube start