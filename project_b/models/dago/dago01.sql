{{ config(materialized='table') }}

with source_data as (

    select *
    from "BR_TEC_ARQ_PROYECTO0"."ARQUITECTURA"."mtcars_native"

)

select *
from source_data
where mpg > 15.0