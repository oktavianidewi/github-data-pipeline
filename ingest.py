from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint


@task(retries=3)
def fetch(dataset_url: str) -> pd.DataFrame:
    """Read taxi data from web into pandas DataFrame"""
    # if randint(0, 1) > 0:
    #     raise Exception

    df = pd.read_csv(dataset_url)
    return df


@task(log_prints=True)
def clean(df: pd.DataFrame) -> pd.DataFrame:
    """Fix dtype issues"""
    df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"])
    df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])
    print(df.head(2))
    print(f"columns: {df.dtypes}")
    print(f"rows: {len(df)}")
    return df


@task()
def write_local(df: pd.DataFrame, year: str, dataset_file: str) -> Path:
    """Write DataFrame out locally as parquet file"""
    path = Path(f"data/{year}/{dataset_file}.parquet")
    df.to_parquet(path, compression="gzip")
    return path


@task()
def write_gcs(path: Path) -> None:
    """Upload local parquet file to GCS"""
    # gcs_block = GcsBucket.load("zoom-gcs")
    gcp_block = GcsBucket.load("prefect-de-zoomcamp-gcs")
    gcp_block.upload_from_path(from_path=path, to_path=path)
    return


@flow()
def etl_web_to_gcs() -> None:
    """The main ETL function"""
    year = 2021
    month = 1
    day = "01" # 01..31
    hour = "1" # 0..23
    dataset_file = f"{year}-{month}-{day}-{hour}"
    dataset_url = f"https://data.gharchive.org/{year}-{month}-{day}-{hour}.json.gz"

    df = fetch(dataset_url)
    df_clean = clean(df)
    write_local(df_clean, year, dataset_file)
    # path = write_local(df_clean, year, dataset_file)
    # write_gcs(path)


if __name__ == "__main__":
    etl_web_to_gcs()
