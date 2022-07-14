FROM arqdatos/arq_datos_dbt_trf_base_image

COPY project_b/models/ /src/dbt/project/models
COPY project_b/macros/ /src/dbt/project/macros

WORKDIR /src/dbt/project
