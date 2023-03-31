from prefect import flow
from prefect_dbt.cli.commands import DbtCoreOperation

@flow
def trigger_dbt_flow(target: str) -> str:
    result = DbtCoreOperation(
        commands=[f"dbt debug --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir="."
    ).run()
    return result

@flow
def trigger_dbt_build(target: str) -> str:
    result = DbtCoreOperation(
        commands=["dbt build --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir="."
    ).run()
    return result

@flow
def trigger_dbt_incremental_run(target: str) -> str:
    result = DbtCoreOperation(
        commands=["dbt run --target {target}"],
        project_dir="dbt_project_github",
        profiles_dir="."
    ).run()
    return result