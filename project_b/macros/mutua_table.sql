{% materialization mutua_table, default %}
    /* Dago was here */
  {%- set identifier = model['alias'] -%}
  {%- set tmp_identifier = model['name'] + '__dbt_tmp' -%}
  {%- set backup_identifier = model['name'] + '__dbt_backup' -%}

  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set target_relation = api.Relation.create(identifier=identifier,
                                                schema=schema,
                                                database=database,
                                                type='table') -%}

    /*  
      See ../view/view.sql for more information about this relation.
    */


  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- build model
  {% call statement('main') -%}
    {%if old_relation is not none %}
        {% set rel_columns = adapter.get_columns_in_relation(target_relation) %}
        {{ get_delete_insert_sql(target_relation, sql, rel_columns) }}
    {% else %}
        {{ get_create_table_as_sql(False, target_relation, sql) }}
    {% endif %}
  {%- endcall %}

  -- cleanup

  {% do create_indexes(target_relation) %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  {% do persist_docs(target_relation, model) %}

  -- `COMMIT` happens here
  {{ adapter.commit() }}


  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
{% endmaterialization %}