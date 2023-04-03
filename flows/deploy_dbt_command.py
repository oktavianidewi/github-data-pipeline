from dbt_commands import trigger_dbt_clean, trigger_dbt_debug, trigger_dbt_incremental_run
from prefect.deployments import Deployment, run_deployment
from prefect.server.schemas.schedules import CronSchedule

import argparse

def deploy(flow, name: str, target: str, **kwargs):
    cron_value = kwargs.get("cron", None)

    if cron_value == None:
        subflow_name = name
        deployment = Deployment.build_from_flow(
            flow=flow,
            name=subflow_name, 
            work_queue_name="default",
            parameters={"target":target}
        )
    else:
        subflow_name = f"schedule-{name}"
        deployment = Deployment.build_from_flow(
            flow=flow,
            name=subflow_name, 
            work_queue_name="default",
            schedule=(CronSchedule(cron=f"{cron_value}")),
            parameters={"target":target}
        )

    deployment.apply()

    if cron_value == None:
        flow_name = flow.__name__.replace("_","-")
        run_deployment(name=f"{flow_name}/{subflow_name}", timeout=10)
    

def main(params):
    type = params.type
    target = params.target
    cron = params.cron

    if type == "run":
        deploy(trigger_dbt_incremental_run, "dbt-run", target, cron=cron)
    elif type == "debug":
        deploy(trigger_dbt_debug, "dbt-debug", target)
    elif type == "clean":
        deploy(trigger_dbt_clean, "dbt-clean",target)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    parser.add_argument('--target', required=True, help='dbt target profile')
    parser.add_argument('--type', required=True, help='dbt command type: run, debug, clean')
    parser.add_argument('--cron', required=False, help='set repeating interval to run the command')

    args = parser.parse_args()
    main(args)
