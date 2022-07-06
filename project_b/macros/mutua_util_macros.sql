{% macro dbt_snowflake_validate_get_incremental_strategy(config) %}
  {#-- Find and validate the incremental strategy #}
  {%- set strategy = config.get("incremental_strategy", default="merge") -%}

  {% set invalid_strategy_msg -%}
    Invalid incremental strategy provided: {{ strategy }}
    Expected one of: 'merge', 'delete+insert'
  {%- endset %}
  {% if strategy not in ['merge', 'delete+insert'] %}
    {% do exceptions.raise_compiler_error(invalid_strategy_msg) %}
  {% endif %}

  {% do return(strategy) %}
{% endmacro %}

{% macro dbt_snowflake_get_incremental_sql(strategy, tmp_relation, target_relation, unique_key, dest_columns) %}
  {% if strategy == 'merge' %}
    {% do return(get_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% elif strategy == 'delete+insert' %}
    {% do return(get_delete_insert_merge_sql(target_relation, tmp_relation, unique_key, dest_columns)) %}
  {% else %}
    {% do exceptions.raise_compiler_error('invalid strategy: ' ~ strategy) %}
  {% endif %}
{% endmacro %}

{% macro get_truncate_insert_sql(target_relation, sql, dest_columns) -%}
  {#
    -- Get the SQL for truncating and inserting the results of a select statement into a target relation with known
    -- columns.
    --
    -- Args:
    --   target_relation: The relation to insert into.
    --   sql (str): The SQL of the select statement in question, where columns match dest_columns.
    --   dest_columns (list of dict):
    --     List of column details for the relation, in the form returned by adapter.get_columns_in_relation().
  #}
  truncate table {{ target_relation }};
  {%- set dest_cols_csv = get_quoted_csv(dest_columns | map(attribute="name")) -%}
  insert into {{ target_relation }} ({{ dest_cols_csv }})
  (
    {{ sql }}
  );
{%- endmacro %}