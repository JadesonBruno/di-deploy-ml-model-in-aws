# Use the official Ubuntu image as base
FROM ubuntu:latest

# Image maintainer (optional)
LABEL maintainer="jadesonb@sjagro.com.br"

# Update system packages and install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
        wget \
        unzip \
        curl \
        git \
        openssh-client \
        iputils-ping \
        && rm -rf /var/lib/apt/lists/*

# Set Terraform version (adjust as needed)
ENV TERRAFORM_VERSION=1.13.0

# Download and install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Create Downloads folder and install AWS CLI (to access AWS)
RUN mkdir downloads && \
    cd downloads && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    rm -rf awscliv2.zip && \
    ./aws/install && \
    cd /

# Set the working directory
WORKDIR /data-projects/di-deploy-ml-model-in-aws
