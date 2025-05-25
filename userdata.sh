#!/bin/bash
yum update -y # Update packages in the package manager
yum install -y ruby wget aws-cli jq amazon-cloudwatch-agent # Install necessary packages
wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install # Download the CodeDeploy agent installer
chmod +x ./install # Make the installer executable
./install auto # Install the CodeDeploy agent
service codedeploy-agent start # Start the CodeDeploy agent

### THESE HAVE BEEN MOVED TO APPSPEC.YML ON THE APP SOURCE CODE
# # Retrieve secrets from Secrets Manager
# MONGO_URI=$(aws secretsmanager get-secret-value --secret-id MONGO_URI --query SecretString --output text | jq -r .MONGO_URI)
# JWT_SECRET=$(aws secretsmanager get-secret-value --secret-id JWT_SECRET --query SecretString --output text | jq -r .JWT_SECRET)
# PAYPAL_CLIENT_ID=$(aws secretsmanager get-secret-value --secret-id PAYPAL_CLIENT_ID --query SecretString --output text | jq -r .PAYPAL_CLIENT_ID)
# PAYPAL_APP_SECRET=$(aws secretsmanager get-secret-value --secret-id PAYPAL_APP_SECRET --query SecretString --output text | jq -r .PAYPAL_APP_SECRET)

# # Set environmental variables
# export NODE_ENV=production
# export PORT=80
# export PAYPAL_API_URL=https://api-m.sandbox.paypal.com
# export MONGO_URI
# export JWT_SECRET
# export PAYPAL_CLIENT_ID
# export PAYPAL_APP_SECRET

# # fetch, install and run the application
# # yum install -y nodejs unzip wget aws-cli jq
# # wget https://github.com/hswg94/ecomm-express-api/archive/refs/heads/main.zip
# # unzip main.zip
# # cd ecomm-express-api-main
# # npm i
# # npm run server -- --port 80 --host 0.0.0.0