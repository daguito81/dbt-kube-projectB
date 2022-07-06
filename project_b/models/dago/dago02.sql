{{ config(
    materialized = 'table'
) }}

    SELECT *
    FROM {{ ref('dago01')}}
