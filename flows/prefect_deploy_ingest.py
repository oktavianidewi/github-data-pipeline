from ingest import etl_web_to_gcs
from prefect.deployments import Deployment, run_deployment
from dotenv import load_dotenv
import os

load_dotenv()

CHUNK_SIZE = int(os.getenv("CHUNK_SIZE"))
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")
GCS_BUCKET_ID = os.getenv("GCS_BUCKET_ID")
GCS_PATH = os.getenv("GCS_PATH")

deployment = Deployment.build_from_flow(
    flow=etl_web_to_gcs,
    name="historical-ingest", 
    work_queue_name="default",
    parameters={"year": 2023, "months":[1], "days":["current"], "kwargs" : {"CHUNK_SIZE": CHUNK_SIZE, "GCP_PROJECT_ID": GCP_PROJECT_ID, "GCS_BUCKET_ID": GCS_BUCKET_ID, "GCS_PATH": GCS_PATH } }
)
deployment.apply()

run_flow = run_deployment(name="etl-web-to-gcs/historical-ingest", timeout=10)

