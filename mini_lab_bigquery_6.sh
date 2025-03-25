# Set project and region variables
export PROJECT_ID=$(gcloud config get-value project)
export REGION=$(gcloud config get-value compute/region)

# Enable required services
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com

# Run the backup query manually to verify
bq query --use_legacy_sql=false \
"CREATE OR REPLACE TABLE ecommerce.backup_orders AS 
 SELECT * FROM ecommerce.customer_orders;"

# Schedule the query to run on the 1st of every month at 2 AM UTC
gcloud scheduler jobs create bigquery backup-customer-orders \
    --schedule="0 2 1 * *" \
    --time-zone="UTC" \
    --location="$REGION" \
    --description="Backup customer_orders table on a monthly basis" \
    --message-body='{
        "query": "CREATE OR REPLACE TABLE ecommerce.backup_orders AS SELECT * FROM ecommerce.customer_orders;",
        "useLegacySql": false
    }' \
    --uri="https://cloudfunctions.net/bigquery-scheduler"

# Verify if the job is scheduled
gcloud scheduler jobs list

# Manually trigger the scheduled query to test
gcloud scheduler jobs run backup-customer-orders

# Check if the backup table contains data
bq query --use_legacy_sql=false \
"SELECT * FROM ecommerce.backup_orders LIMIT 10;"
