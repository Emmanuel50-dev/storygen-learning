#!/bin/bash

# Exit on error
set -e

# Usage: ./deploy-frontend.sh [staging|production]

# Get the environment from the first argument
ENV=$1

if [ -z "$ENV" ]; then
  echo "Usage: ./deploy-frontend.sh [staging|production]"
  exit 1
fi

# Set environment-specific variables
if [ "$ENV" == "staging" ]; then
  BACKEND_URL="http://storygen-backend-staging-url.com"

elif [ "$ENV" == "production" ]; then
  BACKEND_URL="http://storygen-backend-production-url.com"
else
  echo "Invalid environment. Use 'staging' or 'production'."
  exit 1
fi

# Submit the build to Google Cloud Build
gcloud builds submit --config cloudbuild.yaml --substitutions=_BACKEND_URL=$BACKEND_URL