from prefect_gcp import GcpCredentials
from prefect_gcp.cloud_storage import GcsBucket
from dotenv import load_dotenv
import os

# alternative to creating GCP blocks in the UI
# insert your own service_account_file path or service_account_info dictionary from the json file
# IMPORTANT - do not store credentials in a publicly available repository!

load_dotenv()
# create gcp credentials block
# credentials_block = GcpCredentials(
#     service_account_file="sa-project-batch.json"  # enter your credentials info or use the file method.
# )

credentials_block = GcpCredentials(
    service_account_info={
        "type": "service_account",
        "project_id": "dtc-de-zoomcamp-2023-376219",
        "private_key_id": "21b439fa9c8cdf515472d563f74949b0da3c91ae",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDG++0+31wsiYS/\nuVDB8J3hIVuxV+dzH0Qg16VLYc6NEsiFkoy5Nn3IhzoG3z5A3nLEF4wwo+Pejwm7\n8fGliWE65uTb1k5Qk+9EKaMseba2V87/jHjhbUoAsdfwIUQZ41c44O5qBUVJAdrJ\n4aTyHhum0xIfATHlUXt6tNIbiiB+l53RXNr1JqCOEy7XFfbP6APWrBrHpVei3VZO\nE7loDNDS4UB49vl1t/rKOkLG5F9If9/fwMbmSIO0le/D3cvmSZqGrg3TBDELPTcY\nN5SR1Asmg4/a1xBHBQgczxcVR0k2PH83EgndV3vg3QB0xPkpOCLEVj3BsCkbGrmi\nIGFXXiJJAgMBAAECggEAHvlyXy9ycAsMG115K7y35tFELmFU9FUGoZIlTIxcvxW7\nGcfL7hIvFvsDK7Sul8xzfat+CshISAm+EH/uB2r7iVQN21wLHtHtvzo4CKFTBs65\nDeCg+dOttFlQGDTQHrOGjU0TmnStlLAcOFbOpVMjJ3SDGp5wqkC6gZ8KIc1Tl5Yz\nRuPYaFsjhlFxPkCdoG3tzlRCQFT1OI8lTSFBAe+32gb6HHa7HuKtNPbhKEqG1bud\nSXh41HW5bMkyibuxKUtGabo+T8LExNVGZsmI2m70kmtklGAaGjB+dAVPwxizZN9K\nS2hdq/nK20f56QaYoRKbUrKOpUHAKjMaquFve4TarQKBgQDxZa6wXOKiaQ3/LnRQ\n6MofE8NKkXvZJ8eWsEWFyT9UzdOkHbuqhpnq/s42kvFvR6208q4uqqDRY2tA96QS\nP5ij9BypN5orXf9zfUoAPFhMSGRAmsm0TdtC/lSYUoZ1izfvZDXA7OMp86bE5RXa\njgnbJFG6ow0g79/lWDzHHKaubwKBgQDTBW2GebIiDy5Voi1uxTFLLhNdz2n0c39U\noCzrYOLWGuF9/XFfAPkBBfbMIB2voXguKTqWPE9xrdKyAM7pS+g8WbBIXAzI7y29\nae33AQwNZNgcFuf3NryyE5ocULtCqS9+TIhk1c0j2i+8pPniEBRDoKO9yR14rLMM\nndWGJaEWxwKBgQDZ3EYjX0EfCKccNcW+O8om8AQhqVlX6+HiqqWkD7O7iqNGi5sS\nVLZW8q4TbNy+7LbmBtuSvGW1c/+ZO6Z03baZybeQNOFL4GKqzVlbCxs5hWANOmVt\n95I6TST18AzvyryprgwhWOnPs9k/++yUOfrFL2sfgQZZQoQUDWWU4dPAuwKBgHnq\n4OSY2voimzqOgIFHHLu62yWP+D9rm11hTZKQX34j+bO5Ag9JmJOmxngY9g3K1IyW\n9WpnXd7n9psxLFpNqNd1Wgv0Ys6UoXCWCw5yZGw4n0NbWJnT3iFkgd1qJ0bUSMRH\no2XewK6+GGZ9SoH5mDuaTAASehyGaswXRI5En1VxAoGAGzPSeQyT4egl8S+nDhQo\nDSlxDXrQFLn8xerO3uJQ4qwxRPaxpx/TYLnGJ7AAvHkznbhL8hVHHqesuWM9nNOe\nNU1OTjF0B2llE2PcpzqN2UKAtLHyQF8OWXBDmRgbvMeON1a2v6Juhq2re9szd8Nu\npYxEmk9zQp/8KTXkVCCIm9Q=\n-----END PRIVATE KEY-----\n",
        "client_email": "sa-via-tf@dtc-de-zoomcamp-2023-376219.iam.gserviceaccount.com",
        "client_id": "115950767009933289156",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/sa-via-tf%40dtc-de-zoomcamp-2023-376219.iam.gserviceaccount.com"
    }
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
