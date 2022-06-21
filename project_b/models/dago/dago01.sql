{{ config(materialized='table') }}

with source_data as (

    select *
    from mtcars_native

)

select *
from source_data
where mpg > 15.0