{{ config(materialized='table') }}

    SELECT *
    FROM "BR_TEC_ARQ_PROYECTO0"."ARQUITECTURA"."mtcars_native"
    WHERE "MPG" > 15
