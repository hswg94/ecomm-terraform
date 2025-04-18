In this project, Workspace variables in terraform cloud should include the following:

1. Bucket names for the S3 buckets (currently there are 2)
- This should be stored under "terraform" category
- They are referenced in the s3-buckets.tf

2. Github Token for CodeBuild
- This should be stored under "terraform" category, with sensitive checked.
- The token is referenced in pipeline-frontend.tf

3. CodeStar Connection ARN
- This should be stored under "terraform" category
- They are referenced in the pipeline-backend.tf

4. AWS_ACCESS_KEY_ID
- This should be stored under "env" category  as a sensitive value
- Automatically used by terraform cloud during runtime

5. AWS_SECRET_ACCESS_KEY
- This should be stored under "env" category as a sensitive value
- Automatically used by terraform cloud during runtime

6. AWS_DEFAULT_REGION
- This should be stored under "env" category as a sensitive value
- Automatically used by terraform cloud during runtime
