{{ config(
    materialized = 'table',

) }}

    SELECT 
        "row_names" as ROW_NAMES,
        "mpg" * 1000 as MPG,
        "cyl" * 100 as CYL,
        "disp" as DISP,
        "hp" as HP,
        "drat" as DRAT,
        "wt" as WT,
        "qsec" as QSEC,
        "vs" as VS,
        "am" as AM,
        "gear" as GEAR,
        "carb" as CARB
    FROM "BR_TEC_ARQ_PROYECTO0"."ARQUITECTURA"."mtcars_native"
    WHERE "mpg" > 15
