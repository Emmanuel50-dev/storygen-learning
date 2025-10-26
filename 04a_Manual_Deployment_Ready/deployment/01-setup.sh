#!/bin/bash
set -e

source deployment/load-env.sh

# Authenticate with Google Cloud
gcloud auth application-default login
gcloud config set project "$PROJECT_ID"

# Enable necessary services
gcloud services enable run.googleapis.com artifactregistry.googleapis.comiam.googleapis.com 
