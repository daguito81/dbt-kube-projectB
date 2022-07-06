{{ config(
    materialized = 'mutua_incremental',
    unique_key = 'row_names',
    on_schema_change = 'fail',
    incremental_strategy = 'delete+insert',
    merge_update_columns = ['mpg', 'cyl']

) }}

    SELECT *
    FROM "BR_TEC_ARQ_PROYECTO0"."ARQUITECTURA"."mtcars_native"
    WHERE "mpg" > 15
