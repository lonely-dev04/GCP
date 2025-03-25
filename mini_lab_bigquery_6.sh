#!/bin/bash

# Set project ID (replace if necessary)
PROJECT_ID=$(gcloud config get-value project)

# Ensure the project ID is set correctly
if [[ -z "$PROJECT_ID" ]]; then
    echo "Error: No GCP project set. Use 'gcloud config set project PROJECT_ID'"
    exit 1
fi

echo "Using project: $PROJECT_ID"

# Check if BigQuery service is enabled
if gcloud services list --enabled | grep -q 'bigquery.googleapis.com'; then
    echo "BigQuery is already enabled."
else
    echo "BigQuery is not enabled. Please ask an admin to enable it."
    exit 1
fi

# Check if Cloud Scheduler is enabled
if gcloud services list --enabled | grep -q 'cloudscheduler.googleapis.com'; then
    echo "Cloud Scheduler is already enabled."
else
    echo "Cloud Scheduler is not enabled. Please ask an admin to enable it."
    exit 1
fi

# Run a sample BigQuery query (Modify as needed)
bq query --use_legacy_sql=false 'SELECT * FROM `bigquery-public-data.samples.shakespeare` LIMIT 5;'

# Create a Cloud Scheduler job (Modify region as needed)
gcloud scheduler jobs create http my-job \
    --schedule="0 9 * * *" \
    --uri="https://example.com/task" \
    --http-method=POST \
    --location=us-central1  # Change location accordingly

echo "Script execution complete."
