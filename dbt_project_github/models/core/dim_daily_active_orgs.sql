{{ config(
    materialized = 'incremental',
) }}

WITH pr_event_data AS (
    SELECT 
        org.id AS org_id,
        org.login AS org_login,
        org.url AS org_url,
        created_at
    FROM {{ ref('fact_github_events_by_human') }}
    WHERE type = 'PullRequestEvent'
    AND org.id IS NOT NULL
)
SELECT date_trunc(created_at, DAY) AS day,
    org_id, 
    org_login, 
    org_url, 
    count(1) AS num_of_events
FROM pr_event_data
GROUP BY 1, 2, 3, 4
ORDER BY num_of_events DESC
