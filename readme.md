## Pre-Setup on AWS

Before running Terraform, ensure the following resources and configurations are set up in AWS:

1. **CodeStar Connection for GitHub (Both CI/CD Pipelines)**
   - Go to the AWS Console → Developer Tools → Connections.
   - Create a new CodeStar Connection to your GitHub account.
   - Approve the connection in GitHub if prompted.
   - Copy the Connection ARN and add it as the `connection_arn` workspace variable in Terraform Cloud.

2. **AWS Secrets (for application environment variables)**
   - Store the following secrets in AWS Secrets Manager or as environment variables, as required by the backend application:
     - `NODE_ENV`
     - `PORT`
     - `MONGO_URI`
     - `JWT_SECRET`
     - `PAYPAL_CLIENT_ID`
     - `PAYPAL_APP_SECRET`
     - `PAYPAL_API_URL`
     - `CLOUDINARY_CLOUD_NAME`
     - `CLOUDINARY_API_KEY`
     - `CLOUDINARY_API_SECRET`

---

## Setup Variables in Terraform Cloud

Set the following workspace variables in Terraform Cloud before running Terraform:

1. **S3 Bucket Names**
   - Store under the "terraform" category.
   - Variables `ecomm-api-s3-for-cp` and `ecomm-frontend-s3-for-cb-and-cf`, declared in `variables.tf`.

2. **CodeStar Connection ARN**
   - Store under the "terraform" category.
   - Variable `connection_arn`, declared in `variables.tf`.

3. **AWS_ACCESS_KEY_ID**
   - Store under the "env" category as a sensitive value.
   - Automatically used by Terraform Cloud during runtime.

4. **AWS_SECRET_ACCESS_KEY**
   - Store under the "env" category as a sensitive value.
   - Automatically used by Terraform Cloud during runtime.

5. **AWS_DEFAULT_REGION**
   - Store under the "env" category as a sensitive value.
   - Automatically used by Terraform Cloud during runtime.

---

Full details on the system implementation and architecturing process can be found in Project Documentation.pdf.

**After completing these steps, you can run `terraform apply` to provision the infrastructure.**