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

{% materialization mutua_incremental, adapter='snowflake' -%}

  {% set original_query_tag = set_query_tag() %}

  {%- set unique_key = config.get('unique_key') -%}
  {%- set full_refresh_mode = (should_full_refresh()) -%}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  {% set tmp_relation = make_temp_relation(this) %}

  {#-- Validate early so we don't run SQL if the strategy is invalid --#}
  {% set strategy = dbt_snowflake_validate_get_incremental_strategy(config) -%}
  {% set on_schema_change = incremental_validate_on_schema_change(config.get('on_schema_change'), default='ignore') %}

  {{ run_hooks(pre_hooks) }}

  {% if existing_relation is none %}
    {% set build_sql = create_table_as(False, target_relation, sql) %}

  {% elif existing_relation.is_view %}
    {#-- Can't overwrite a view with a table - we must drop --#}
    {{ log("Dropping relation " ~ target_relation ~ " because it is a view and this model is a table.") }}
    {% do adapter.drop_relation(existing_relation) %}
    {% set build_sql = create_table_as(False, target_relation, sql) %}

  {% elif full_refresh_mode %}
    {% set rel_columns = adapter.get_columns_in_relation(existing_relation) %}
    {% set build_sql = get_truncate_insert_sql(existing_relation, sql, rel_columns) %}

  {% else %}
    {% do run_query(create_table_as(True, tmp_relation, sql)) %}
    {% do adapter.expand_target_column_types(
           from_relation=tmp_relation,
           to_relation=target_relation) %}
    {#-- Process schema changes. Returns dict of changes if successful. Use source columns for upserting/merging --#}
    {% set dest_columns = process_schema_changes(on_schema_change, tmp_relation, existing_relation) %}
    {% if not dest_columns %}
      {% set dest_columns = adapter.get_columns_in_relation(existing_relation) %}
    {% endif %}
    {% set build_sql = dbt_snowflake_get_incremental_sql(strategy, tmp_relation, target_relation, unique_key, dest_columns) %}

  {% endif %}

  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}

  {{ run_hooks(post_hooks) }}

  {% set target_relation = target_relation.incorporate(type='table') %}
  {% do persist_docs(target_relation, model) %}

  {% do unset_query_tag(original_query_tag) %}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}