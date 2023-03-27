{{ config(
    materialized = 'incremental',
    partition_by={
      "field": "created_at",
      "data_type": "timestamp",
      "granularity": "day"
    },
    cluster_by=['created_at', 'type']
) }}

WITH bot_removal AS (
    SELECT id, 
        type, 
        actor, 
        repo,
        payload,
        public, 
        created_at, 
        org
    FROM {{ ref('stg_github_data') }}
    WHERE actor.login NOT LIKE '%bot%'
    AND actor.login NOT LIKE '%Bot%'
    AND actor.login NOT LIKE '%BOT%'

  {% if is_incremental() %}
    AND created_at > 
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
FROM bot_removal