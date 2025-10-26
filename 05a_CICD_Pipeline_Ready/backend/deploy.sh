
#!/bin/bash

# Exit on error
set -e

# Usage: ./deploy.sh [staging|production]

# Get the environment from the first argument
ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./deploy.sh [staging|production]"
  exit 1
fi

# Set environment-specific variables
if [ "$ENV" == "staging" ]; then
  FRONTEND_URL="http://staging.example.com"
  GOOGLE_API_KEY=$STAGING_GOOGLE_API_KEY
  GOOGLE_CLOUD_PROJECT_ID=$STAGING_GOOGLE_CLOUD_PROJECT_ID
elif [ "$ENV" == "production" ]; then
  FRONTEND_URL="http://production.example.com"
  GOOGLE_API_KEY=$PROD_GOOGLE_API_KEY
  GOOGLE_CLOUD_PROJECT_ID=$PROD_GOOGLE_CLOUD_PROJECT_ID
else
  echo "Invalid environment. Use 'staging' or 'production'."
  exit 1
fi

# Submit the build to Google Cloud Build
gcloud builds submit --config cloudbuild.yaml --substitutions=_FRONTEND_URL=$FRONTEND_URL,_GOOGLE_API_KEY=$GOOGLE_API_KEY,_GOOGLE_CLOUD_PROJECT_ID=$GOOGLE_CLOUD_PROJECT_ID
