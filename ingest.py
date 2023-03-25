from pathlib import Path
import pandas as pd
import os
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint
import json


@task(retries=3)
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read taxi data from web into pandas DataFrame"""
    # if randint(0, 1) > 0:
    #     raise Exception

    header = {'User-Agent': 'pandas'}
    df = pd.read_json(dataset_url, lines=True, storage_options=header, compression="gzip")
    return df


@task(retries=3, log_prints=True)
def clean(df: pd.DataFrame) -> pd.DataFrame:
    """Fix dtype issues"""
    df["id"] = df["id"].astype("Int64")
    df["payload"] = df["payload"].apply(lambda x: json.dumps(x)).astype("string")
    df["type"] = df["type"].astype("string")
    df["created_at"] = pd.to_datetime(df["created_at"])


    # additional column for partition
    df["year"], df["month"], df["day"] = df["created_at"].apply(lambda x: x.year), df["created_at"].apply(lambda x: x.month), df["created_at"].apply(lambda x: x.day)

    print(f"rows: {len(df)}")
    print(f"columns: {df.dtypes}")
    return df


@task(retries=3)
def write_to_gcs(df: pd.DataFrame, dataset_file: str) -> Path:
    """Write DataFrame out locally as parquet file"""
    
    # create directory if not exist
    dir = f"data/"
    if not os.path.isdir(dir):
        os.makedirs(dir)

    path = f"gs://tf_datalake_bucket_dtc-de-zoomcamp-2023-376219/data"
    df.to_parquet(path, engine="pyarrow", compression="gzip", partition_cols=["year", "month", "day"])
    return path


@task()
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    # gcs_block = GcsBucket.load("zoom-gcs")
    gcp_block = GcsBucket.load("project-batch")
    gcp_block.upload_from_path(from_path=path, to_path=path)
    return


@flow()
def etl_web_to_gcs() -> None:
    # TODO: parameterized
    """The main ETL function"""
    year = 2023
    month = "01" # 01..12
    day = "01" # 01..31
    # TODO: every 10 min run job to ingest hourly data
    for hour in range (1,24):
        print(f"Write hour-{hour}")
        dataset_file = f"{year}-{month}-{day}-{hour}"
        dataset_url = f"https://data.gharchive.org/{year}-{month}-{day}-{hour}.json.gz"
        df = fetch(dataset_url)
        df_clean = clean(df)
        write_to_gcs(df_clean, dataset_file)


if __name__ == "__main__":
    etl_web_to_gcs()
