from prefect import flow
from prefect_dbt.cli.commands import DbtCoreOperation
import argparse


@flow
def trigger_dbt_debug(target: str) -> str:
    result = DbtCoreOperation(
        commands=[f"dbt debug --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir="."
    ).run()
    return result

@flow
def trigger_dbt_clean(target: str) -> str:
    result = DbtCoreOperation(
        commands=[f"dbt clean --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir=".",
    ).run()
    return result

@flow
def trigger_dbt_incremental_run(target: str) -> str:
    dbt_run = DbtCoreOperation(
        commands=[f"dbt --no-partial-parse run --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir=".",
    ).trigger()
    dbt_run.wait_for_completion()
    dbt_output = dbt_run.fetch_result()
    return dbt_output