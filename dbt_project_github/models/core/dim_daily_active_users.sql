{{ config(
    materialized = 'incremental',
) }}

WITH push_event_data AS (
    SELECT actor.id AS actor_id, 
        actor.url AS actor_url, 
        actor.login AS actor_login, 
        created_at 
    FROM {{ ref('fact_github_events_by_human') }}
    WHERE type = 'PushEvent'
)
SELECT DATE_TRUNC(created_at, DAY) as day,
    actor_id, 
    actor_url, 
    actor_login, 
    COUNT(1) AS num_of_events
FROM push_event_data
GROUP BY 1,2,3, 4
ORDER BY num_of_events DESC