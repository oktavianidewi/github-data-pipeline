{{ config(
    materialized = 'incremental',
) }}

SELECT DATE_TRUNC(created_at, HOUR) AS hour,
    type, 
    COUNT(1) as num_of_events
FROM {{ ref('fact_github_events_by_human') }}
GROUP BY 1, 2