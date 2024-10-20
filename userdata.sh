#!/bin/bash
yum update -y
yum install -y nodejs unzip wget aws-cli jq
wget https://github.com/hswg94/ecomm-express-api/archive/refs/heads/main.zip
unzip main.zip
cd ecomm-express-api-main

# Retrieve secrets from Secrets Manager
MONGO_URI=$(aws secretsmanager get-secret-value --secret-id MONGO_URI --query SecretString --output text | jq -r .MONGO_URI)
JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id JWT_SECRET --query SecretString --output text | jq -r .JWT_SECRET)
PAYPAL_CLIENT_ID=$(aws secretsmanager get-secret-value --secret-id PAYPAL_CLIENT_ID --query SecretString --output text | jq -r .PAYPAL_CLIENT_ID)
PAYPAL_APP_SECRET=$(aws secretsmanager get-secret-value --secret-id PAYPAL_APP_SECRET --query SecretString --output text | jq -r .PAYPAL_APP_SECRET)

# Set environmental variables
export NODE_ENV=production
export PORT=80
export PAYPAL_API_URL=https://api-m.sandbox.paypal.com
export MONGO_URI
export JWT_SECRET
export PAYPAL_CLIENT_ID
export PAYPAL_APP_SECRET

npm i
npm run server -- --port 5000 --host 0.0.0.0