from pathlib import Path
import pandas as pd
import os
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint
import json
from dotenv import load_dotenv

@task(retries=3)
def fetch_chunk_clean_write(dataset_url: str) -> None:
    """Read taxi data from web into pandas DataFrame"""
    header = {'User-Agent': 'pandas'}

    chunk_size = int(os.getenv("CHUNK_SIZE"))
    with pd.read_json(dataset_url, lines=True, storage_options=header, chunksize=chunk_size, compression="gzip") as reader: 
        reader
        for chunk in reader:
            # df = df.append(chunk, ignore_index=True)
            df = pd.DataFrame(chunk)
            df_clean = clean(df)
            write_to_gcs(df_clean)

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


def write_to_gcs(df: pd.DataFrame) -> None:
    """Write DataFrame out locally as parquet file"""
    path = os.getenv("GCS_PATH") # f"gs://tf_datalake_bucket_dtc-de-zoomcamp-2023-376219/data"
    df.to_parquet(path, engine="pyarrow", compression="gzip", partition_cols=["year", "month", "day"])


@task()
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    gcp_block = GcsBucket.load(os.getenv("PREFECT_GCS_BUCKET_BLOCK")) # "project-batch"
    gcp_block.upload_from_path(from_path=path, to_path=path)
    return


@flow()
def etl_web_to_gcs(year: int, months: list, days: list) -> None:
    """The main ETL function"""
    # TODO: every 10 min run job to ingest hourly data
    for month in months:
        print(f"months {month:02}")
        for day in days:
            print(f"days {day:02}")
            for hour in range (1, 24):
                dataset_file = f"{year}-{month:02}-{day:02}-{hour}"
                print(f"hour-{hour}-{dataset_file}")
                dataset_url = f"https://data.gharchive.org/{year}-{month:02}-{day:02}-{hour}.json.gz"
                fetch_chunk_clean_write(dataset_url)

if __name__ == "__main__":
    load_dotenv()
    
    # parameterized
    year = 2023
    months = [1] # 1, 2, 3
    days = [4] # 01..31
    etl_web_to_gcs(year, months, days)
