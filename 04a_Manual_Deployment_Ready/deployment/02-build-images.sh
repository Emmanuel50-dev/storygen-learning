#!/bin/bash
set -e

source deployment/load-env.sh

# Build and push backend image
docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/storygen/backend:latest" backend
docker push "$REGION-docker.pkg.dev/$PROJECT_ID/storygen/backend:latest"

# Build and push frontend image
docker build -t "$REGION-docker.pkg.dev/$PROJECT_ID/storygen/frontend:latest" frontend
docker push "$REGION-docker.pkg.dev/$PROJECT_ID/storygen/frontend:latest"
