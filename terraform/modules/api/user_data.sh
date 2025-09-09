#!/bin/bash

# Log all output for debugging
exec > >(tee /var/log/user-data.log) 2>&1

# Update system
yum update -y

# Install required packages
yum install -y \
    git \
    gcc \
    zlib-devel \
    bzip2 \
    bzip2-devel \
    readline-devel \
    sqlite \
    sqlite-devel \
    openssl-devel \
    tk-devel \
    libffi-devel \
    xz-devel \
    wget \
    awscli

# Switch to ec2-user for pyenv installation
sudo -u ec2-user bash << 'PYENV_EOF'

# Install pyenv
curl -fsSL https://pyenv.run | bash

# Add pyenv to PATH and initialize
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Add pyenv configuration to .bashrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init - bash)"' >> ~/.bashrc

# Install Python 3.12.1
pyenv install 3.12.1
pyenv global 3.12.1

# Upgrade pip and install poetry
pip install --upgrade pip
pip install poetry

PYENV_EOF

# Create project directory
mkdir -p /home/ec2-user/data-projects/di-deploy-ml-model-in-aws

# Sync from S3
aws s3 sync s3://${ml_api_bucket_name} /home/ec2-user/data-projects/di-deploy-ml-model-in-aws

# Change ownership to ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/data-projects/di-deploy-ml-model-in-aws

# Switch to ec2-user and setup project
sudo -u ec2-user bash << 'PROJECT_EOF'

# Change to project directory
cd /home/ec2-user/data-projects/di-deploy-ml-model-in-aws

# Setup pyenv environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Configure poetry
poetry config virtualenvs.in-project true
poetry env use 3.12.1

# Install dependencies
poetry install --only main --no-root

# Start the FastAPI application
nohup poetry run uvicorn src.api.fastapi:app --host 0.0.0.0 --port 5000 --workers 4 > ./uvicorn.log 2>&1 &

PROJECT_EOF

echo "User data script completed successfully" >> /var/log/user-data.log
