from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket
from dotenv import load_dotenv
import os

# alternative to creating GCP blocks in the UI
# insert your own service_account_file path or service_account_info dictionary from the json file
# IMPORTANT - do not store credentials in a publicly available repository!

load_dotenv(".env")
# create gcp credentials block
credentials_block = GcpCredentials(
    service_account_file="./sa-project-batch.json"  # enter your credentials info or use the file method.
)
credentials_block.save(os.getenv("PRFECT_GCP_CREDENTIAL_BLOCK"), overwrite=True) # test-create-gcp-creds

# create bucket block
bucket_block = GcsBucket(
    gcp_credentials=GcpCredentials.load(os.getenv("PRFECT_GCP_CREDENTIAL_BLOCK")), # "test-create-gcp-creds"
    bucket=os.getenv("GCS_BUCKET_ID"), # "tf_datalake_bucket_dtc-de-zoomcamp-2023-376219",  # insert your GCS bucket name
)

bucket_block.save(os.getenv("PREFECT_GCS_BUCKET_BLOCK"), overwrite=True) # "project-batch"
