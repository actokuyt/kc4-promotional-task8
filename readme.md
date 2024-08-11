### Promotional Task 8(Final Task)

The Objective for this task is to set up a complete CI/CD pipeline for a simple python app using github actions, kubernetes, terraform for AWS, and docker.

## Notes:
In a production environment, the terraform state file is stored on the cloud, using services such as AWS S3, from where it is accessed to facilitate the provision and maintainance of the infrastructure for the app, this is to ensure persistence and coherence of the terraform provisioned infrastructure. I'll be ommiting that for simplicity sake and to focus on the actual flow of the applicationn code from the developer to the hosting server, from where it can be served to the user.

[Docker Image](https://hub.docker.com/repository/docker/actokuyt/kc4-cicd-app/general)

## Step 1 (Prepare the Code Repository)

Head to github and create a new repo. Clone the repo to your local machine and create the following files as structured in the image below.

![folder structure](images/Screenshot%202024-08-11%20at%201.04.38%20PM.png)

* The `.github/workflows` directory contains all github actions workflow configurations.
* The `k8s` directory contains kubernetes manifests.
* The `terraform` directory contains all terraform modules.
* `.dockerignore` file describes contents of the repo that should be ignored by docker when copying the application code to be packaged and containerized.
* `.gitignore` file describes contents of the repo that should be ignored by git when tracking the application code for version control.
* `app.py` in this case is the actual application.
* `requirements.txt` (optional) in this case holds some info which docker will use to prepare the app during containerization.

## Step 2 (Set Up GitHub Actions)

In the `.github/workflow` dir, create a new file `deploy.yml` and add the following as it's contents. 

```
name: CI/CD

on:
  push:
    branches:
      - master

jobs:
  docker-containerize:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1

      - name: Login to Docker Hub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASS }}

      - name: Build and push Docker image
        run: |
          docker build -t actokuyt/certified-devops-app .
          docker push actokuyt/certified-devops-app

  minikube-deploy:
    runs-on: ubuntu-latest
    steps:
    - name: SSH into EC2 and deploy to Minikube
      uses: appleboy/ssh-action@v0.1.1
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_KEY }}
        script: |
          kubectl apply -f ~/path/to/k8s/deployment.yaml
          kubectl apply -f ~/path/to/k8s/service.yaml
```

## Step 3 (Set Up Terraform for EC2 and Minikube)

In the `terraform` directory, create separate directories for each module. For each module, there should be a main.tf file where the actual configuration for each instance being provisioned, a variable.tf file where the variables required for the instance provision is described, and finally and output.tf file where the expected outputs from the instance provisioning can be captured. I'll show samples with the ec2 module, the rest can be reviewed from the repo code.

```
main.tf

resource "aws_instance" "minikube_instance" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = var.public_subnet_id
  key_name        = var.key_name
  security_groups = [var.public_sg_id]

  associate_public_ip_address = true

  user_data = file("${path.module}/../scripts/main.sh")

  provisioner "file" {
    source      = "${path.module}/../../k8s"
    destination = "/home/ubuntu/app"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }



  tags = {
    Name = "minikube instance"
  }
}
```

```
variable.tf

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type = string
}

variable "key_name" {
  description = "ssh key pair name"
  type = string
}

variable "public_subnet_id" {
  description = "Subnet ID for the public subnet"
  type = string
}

variable "public_sg_id" {
  description = "value of public security group"
  type = string
}

variable "private_key_path" {
  description = "path to private key"
  type = string
}
```

```
output.tf

output "ec2_public_ip" {
  value = aws_instance.minikube_instance.public_ip
}
```

I have also used a provisioning script to install docker and minikube on the provisioned ec2 instance and boot them up. Also I used a provisioner block to copy the kubernetes manifests unto the ec2 instance. Here's a review of the provisioning script.

```
main.sh

#!/bin/bash

# Install docker using the convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

# install kubectl
sudo snap install kubectl --classic

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Start Minikube using Docker driver
sudo usermod -aG docker ubuntu && newgrp docker
minikube start

```

At this point we can run `$terraform init` and `terraform apply` to plan and execute the terraform configurations, there by provisioning our cloud infrastructure on AWS.

![terraform apply](images/Screenshot%202024-08-11%20at%201.51.23%20PM.png)
![ec2](images/Screenshot%202024-08-11%20at%201.53.02%20PM.png)

## Step 4 (Access the Minikube Cluster)

Now, using the ec2 public ip output we got from the terraform provisioning, we can access the ec2 instance from our local machine, to make sure it's properly configured and can host our application code. We can verify minikube is ready by runing the command `$minikube status` or `kubectl get nodes`.

![minikube](images/Screenshot%202024-08-11%20at%202.10.44%20PM.png)

## Step 4 (Automate Deployment with GitHub Actions)

At this point we have our app ready to be deployed, we can go ahead and push our changes to github, ensuring our workflow configurations has been set to trigger on push to our master branch, and our github secrets all well configured.

![minikube deploy](images/Screenshot%202024-08-11%20at%202.30.23%20PM.png)

We have successfully deployed our app to the minikube cluster on our ec2 instance.