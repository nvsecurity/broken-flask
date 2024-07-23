#!/bin/bash
set -ex

yum -y update
amazon-linux-extras install docker
systemctl status amazon-ssm-agent

# ---------------------------------------------------------------------------------------------------------------------
# Docker
# ---------------------------------------------------------------------------------------------------------------------
service docker start
usermod -a -G docker ec2-user

systemctl enable docker.service
systemctl enable containerd.service
systemctl restart docker

# Get the docker image
docker pull insecureapps/broken-flask:latest
docker image ls

# Install Docker compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
docker-compose version

# Write docker compose file
cat << 'EOF' > /home/ec2-user/docker-compose.yml
services:
  broken-flask:
    container_name: broken-flask
    image: insecureapps/broken-flask
    restart: always
    ports:
      - 4000:4000
    networks:
      - broken-net
  employees:
    container_name: broken-employees
    image: insecureapps/broken-flask-employees
    restart: always
    ports:
      - 4100:4100
    networks:
      - broken-net

networks:
  broken-net:
EOF

# Start docker compose
docker-compose -f /home/ec2-user/docker-compose.yml up -d
docker ps
