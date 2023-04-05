FROM prefecthq/prefect:2.8.7-python3.11

RUN pip3 install prefect-gcp prefect-dbt dbt-core dbt-bigquery gcsfs python-dotenv pandas pyarrow
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y

# COPY sa-project-batch.json .
# RUN gcloud auth activate-service-account --key-file=sa-project-batch.json
# RUN gcloud config set project "dtc-de-zoomcamp-2023-376219"
RUN ls

EXPOSE 4200

ENTRYPOINT [ "bash" ]