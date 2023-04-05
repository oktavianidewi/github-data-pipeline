from ingest import etl_web_to_gcs
from prefect.deployments import Deployment, run_deployment
from dotenv import load_dotenv
import os
import json
import argparse
from prefect.server.schemas.schedules import CronSchedule



basedir=os.path.abspath(os.path.dirname(__file__))
load_dotenv(os.path.join(basedir, '../.env'))

CHUNK_SIZE = int(os.getenv("CHUNK_SIZE"))
GCP_PROJECT_ID = os.getenv("GCP_PROJECT_ID")
GCS_BUCKET_ID = os.getenv("GCS_BUCKET_ID")
GCS_PATH = os.getenv("GCS_PATH")

def deploy(name: str, params: dict, **kwargs):
    cron_value = kwargs.get("cron", None)

    # {"year": 2023, "months":[1], "days":["current"], "kwargs" : {"CHUNK_SIZE": CHUNK_SIZE, "GCP_PROJECT_ID": GCP_PROJECT_ID, "GCS_BUCKET_ID": GCS_BUCKET_ID, "GCS_PATH": GCS_PATH } }

    if cron_value == None:
        subflow_name = name
        deployment = Deployment.build_from_flow(
            flow=etl_web_to_gcs,
            name=subflow_name, 
            work_queue_name="default",
            parameters=params
        )
    else: 
        subflow_name = f"schedule-{name}"
        deployment = Deployment.build_from_flow(
            flow=etl_web_to_gcs,
            name=subflow_name, 
            work_queue_name="default",
            schedule=(CronSchedule(cron=f"{cron_value}")),
            parameters=params
        )
    deployment.apply()

    if cron_value == None:
        run_deployment(name=f"etl-web-to-gcs/{subflow_name}", timeout=10)

def main(args):
    name = args.name
    params = json.loads(args.params)
    cron = args.cron

    deploy(name, params, cron=cron)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    parser.add_argument('--name', required=True, help='dbt sub-flow name')
    parser.add_argument('--params', required=True, help='flow parameters')
    parser.add_argument('--cron', required=False, help='set repeating interval to run the command')

    args = parser.parse_args()
    main(args)
