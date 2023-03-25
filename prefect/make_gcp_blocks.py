from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket

# alternative to creating GCP blocks in the UI
# insert your own service_account_file path or service_account_info dictionary from the json file
# IMPORTANT - do not store credentials in a publicly available repository!

# create gcp credentials block
credentials_block = GcpCredentials(
    service_account_file="./sa-project-batch.json"  # enter your credentials info or use the file method.
)
credentials_block.save("test-create-gcp-creds", overwrite=True)

# create bucket block
bucket_block = GcsBucket(
    gcp_credentials=GcpCredentials.load("test-create-gcp-creds"),
    bucket="tf_datalake_bucket_dtc-de-zoomcamp-2023-376219",  # insert your GCS bucket name # TODO env-y this
)

bucket_block.save("project-batch", overwrite=True)
