{{ config(
    materialized = 'incremental',
) }}

SELECT DATE_TRUNC(created_at, DAY) AS day,
    type, 
    COUNT(1) AS num_of_events
FROM {{ ref('fact_github_events_by_human') }}
GROUP BY 1, 2