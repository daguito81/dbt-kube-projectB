{{ config(
    materialized = 'mutua_incremental',
    query_tag = 'dago02',
    transient = false,
    unique_key = "row_names",
    on_schema_change = 'fail',
    incremental_strategy = 'merge',
    merge_update_columns = ['mpg', 'cyl']
) }}

    SELECT *
    FROM {{ ref('dago01')}}
