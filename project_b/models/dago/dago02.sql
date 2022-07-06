{{ config(
    materialized = 'mutua_incremental',
    unique_key = "row_names",
    on_schema_change = 'fail',
    incremental_strategy = 'delete+insert',
    merge_update_columns = ['mpg', 'cyl']

) }}

    SELECT *
    FROM {{ ref('dago01')}}
