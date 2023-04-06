from pathlib import Path
import pandas as pd
import os
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from random import randint
import json
from calendar import monthrange
from datetime import date


# @task(retries=3, log_prints=True)
def fetch_chunk_clean_write(dataset_url: str, **kwargs) -> None:
    """Read taxi data from web into pandas DataFrame"""
    
    for key, value in kwargs.items():
        print("%s == %s" % (key, value))
    
    header = {'User-Agent': 'pandas'}

    chunk_size = int(kwargs["CHUNK_SIZE"])
    with pd.read_json(dataset_url, lines=True, storage_options=header, chunksize=chunk_size, compression="gzip") as reader: 
        reader
        for chunk in reader:
            # df = df.append(chunk, ignore_index=True)
            df = pd.DataFrame(chunk)
            df_clean = clean(df)
            write_to_gcs(df_clean, **kwargs)

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


def write_to_gcs(df: pd.DataFrame, **kwargs) -> None:
    """Write DataFrame out locally as parquet file"""
    path = kwargs["GCS_PATH"] # f"gs://tf_datalake_bucket_dtc-de-zoomcamp-2023-376219/data"
    df.to_parquet(path, engine="pyarrow", compression="gzip", partition_cols=["year", "month", "day"])

def gen_days(year: int, months: list, days: list) -> list: 
    gen_days = []
    if len(days) == 1 and days[0] == "current":
        today = date.today()
        cur_month = today.strftime("%-m")
        cur_day = today.strftime("%d")

        for month in months:
            if int(month) == int(cur_month):
                gen_days.append(int(cur_day)-1)
            else:
                gen_days.append(monthrange(year, month)[1])
    return gen_days

# @flow(log_prints=True)
def etl_web_to_gcs(year: int, months: list, days: list, **kwargs) -> None:
    """The main ETL function"""
    custom_days = gen_days(year, months, days)
    for month in months:
        for day in range(0, custom_days[0]+1):
            print(f"days {day:02}")
            for hour in range (1, 24):
                dataset_file = f"{year}-{month:02}-{day:02}-{hour}"
                print(f"hour:{hour}, file:{dataset_file}")
                dataset_url = f"https://data.gharchive.org/{year}-{month:02}-{day:02}-{hour}.json.gz"
                fetch_chunk_clean_write(dataset_url, **kwargs)

if __name__ == "__main__":
    # parameterized
    year = 2023
    months = [4] # 1, 2, 3
    days = ["current"] # 01..31

    etl_web_to_gcs(year, months, days)
