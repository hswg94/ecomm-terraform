#!/bin/bash
set -x  #enables debug mode, which causes each command (and its arguments) to be printed to the terminal (and to the log) before it is executed.

echo "[USERDATA.SH] Updating packages..."
yum update -y

echo "[USERDATA.SH] Installing ruby..."
yum install -y ruby

echo "[USERDATA.SH] Installing wget..."
yum install -y wget

echo "[USERDATA.SH] Installing aws-cli..."
yum install -y aws-cli

echo "[USERDATA.SH] Installing jq..."
yum install -y jq

echo "[USERDATA.SH] Installing amazon-cloudwatch-agent..."
yum install -y amazon-cloudwatch-agent

echo "[USERDATA.SH] Downloading CodeDeploy agent installer..."
wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install

echo "[USERDATA.SH] Making CodeDeploy installer executable..."
chmod +x ./install

echo "[USERDATA.SH] Installing CodeDeploy agent..."
./install auto

echo "[USERDATA.SH] Starting CodeDeploy agent..."
service codedeploy-agent start

echo "[USERDATA.SH] User data script completed."