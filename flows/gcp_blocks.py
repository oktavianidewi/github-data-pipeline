from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket
from dotenv import load_dotenv
import os

# alternative to creating GCP blocks in the UI
# insert your own service_account_file path or service_account_info dictionary from the json file
# IMPORTANT - do not store credentials in a publicly available repository!

basedir=os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '../.env'))

load_dotenv("../.env")
# create gcp credentials block
credentials_block = GcpCredentials(
    service_account_file="sa-project-batch.json"  # enter your credentials info or use the file method.
)

credentials_block.save(os.getenv("PREFECT_GCP_CREDENTIAL_BLOCK"), overwrite=True)
# credentials_block.save("test-create-gcp-creds1", overwrite=True) # 

# create bucket block
bucket_block = GcsBucket(
    gcp_credentials=GcpCredentials.load(os.getenv("PREFECT_GCP_CREDENTIAL_BLOCK")),
    bucket=os.getenv("GCS_BUCKET_ID"), # "tf_datalake_bucket_dtc-de-zoomcamp-2023-376219"
    # gcp_credentials=GcpCredentials.load("test-create-gcp-creds1"),
    # bucket="tf_datalake_bucket_dtc-de-zoomcamp-2023-376219"
)

bucket_block.save(os.getenv("PREFECT_GCS_BUCKET_BLOCK"), overwrite=True) # "project-batch"
# bucket_block.save("project-batch1", overwrite=True) # 
