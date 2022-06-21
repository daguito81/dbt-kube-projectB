{{ config(materialized='table') }}

    select *
    from "BR_TEC_ARQ_PROYECTO0"."ARQUITECTURA"."mtcars_native"
    where "mpg" > 15
