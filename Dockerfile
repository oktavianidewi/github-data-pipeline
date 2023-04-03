FROM prefecthq/prefect:2.8.7-python3.11

RUN pip3 install prefect-gcp prefect-dbt dbt-core dbt-bigquery gcsfs python-dotenv pandas

EXPOSE 4200

ENTRYPOINT [ "bash" ]