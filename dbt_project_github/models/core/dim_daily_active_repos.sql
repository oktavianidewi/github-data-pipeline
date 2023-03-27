{{ config(
    materialized = 'incremental',
) }}

WITH issue_events AS (
    SELECT id, 
        repo.id AS repo_id, 
        repo.name AS repo_name, 
        repo.url AS repo_url, 
        created_at 
    FROM {{ ref('fact_github_events_by_human') }}
    WHERE type = 'IssuesEvent'
)
SELECT DATE_TRUNC(created_at, DAY) AS day,
    repo_id,
    repo_url,
    SUM(1) as num_of_events
FROM issue_events
group by 1, 2, 3