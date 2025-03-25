export PROJECT_ID=$(gcloud config get-value project)
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Enable required services
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com

# Run the backup query manually
bq query --use_legacy_sql=false "CREATE OR REPLACE TABLE ecommerce.backup_orders AS SELECT * FROM ecommerce.customer_orders;"

# Schedule the query to run on the 1st of every month at midnight UTC
gcloud scheduler jobs create bigquery backup-customer-orders \
    --schedule="0 0 1 * *" \
    --time-zone="UTC" \
    --location="$REGION" \
    --description="Backup customer_orders table monthly" \
    --message-body='{
        "query": "CREATE OR REPLACE TABLE ecommerce.backup_orders AS SELECT * FROM ecommerce.customer_orders;",
        "useLegacySql": false
    }' \
    --uri="https://cloudfunctions.net/bigquery-scheduler"

# Verify if the job is scheduled
gcloud scheduler jobs list

# Manually trigger the scheduled query (optional)
gcloud scheduler jobs run backup-customer-orders

# Check if the backup table contains data
bq query --use_legacy_sql=false "SELECT * FROM ecommerce.backup_orders LIMIT 10;"
