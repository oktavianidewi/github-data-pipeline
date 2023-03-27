{{ config(
    materialized = 'incremental',
) }}

WITH forked_event_data AS (
    SELECT 
        repo.id AS repo_id,
        repo.name AS repo_name,
        repo.url AS repo_url,
        created_at
    FROM {{ ref('fact_github_events_by_human') }}
    WHERE type = 'ForkEvent'
)
SELECT DATE_TRUNC(created_at, DAY) AS day,
    repo_id, 
    repo_name, 
    repo_url, 
    COUNT(1) as num_of_events
FROM forked_event_data
GROUP BY 1,2,3, 4
ORDER BY num_of_events DESC