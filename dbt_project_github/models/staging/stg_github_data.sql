-- remove duplicates 

{{ config(
    materialized = 'incremental',
    partition_by={
      "field": "created_at",
      "data_type": "timestamp",
      "granularity": "day"
    },
    cluster_by=['created_at', 'type']
) }}

WITH ranked AS (
    SELECT id, 
        type, 
        actor, 
        repo,
        payload,
        public, 
        created_at, 
        org,
        ROW_NUMBER() OVER (
        PARTITION BY id
        ORDER BY created_at DESC NULLS LAST
        ) AS __rank
    FROM {{ source('staging', 'github_events') }}

  {% if is_incremental() %}
    WHERE created_at > 
      (
        SELECT MAX(created_at)
        FROM {{ this }}
      )
  {% endif %}
)
SELECT id, 
    type, 
    actor, 
    repo,
    payload,
    public, 
    created_at, 
    org
FROM ranked
WHERE __rank = 1
