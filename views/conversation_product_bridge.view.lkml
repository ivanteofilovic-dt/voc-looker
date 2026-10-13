# Grain: one primary product, plus one row per distinct other product mentioned.

view: conversation_product_bridge {
  derived_table: {
    datagroup_trigger: voc_daily
    cluster_keys: ["data_id"]
    sql:
      SELECT
        data_id,
        product,
        is_primary,
        product_row_key
      FROM (
        SELECT
          data_id,
          TRIM(product_mentioned) AS product,
          TRUE AS is_primary,
          CONCAT(data_id, '::primary::', TRIM(product_mentioned)) AS product_row_key,
          1 AS dedupe_row
        FROM ${conversation_insights.SQL_TABLE_NAME}
        WHERE NULLIF(TRIM(product_mentioned), '') IS NOT NULL

        UNION ALL

        SELECT
          data_id,
          product,
          FALSE AS is_primary,
          CONCAT(data_id, '::secondary::', product) AS product_row_key,
          ROW_NUMBER() OVER (
            PARTITION BY data_id, LOWER(product)
            ORDER BY product
          ) AS dedupe_row
        FROM (
          SELECT
            insights.data_id,
            TRIM(product) AS product
          FROM ${conversation_insights.SQL_TABLE_NAME} AS insights
          CROSS JOIN UNNEST(IFNULL(insights.products_mentioned, [])) AS product
          WHERE NULLIF(TRIM(product), '') IS NOT NULL
            AND LOWER(TRIM(product)) != LOWER(TRIM(IFNULL(insights.product_mentioned, '')))
        ) AS secondary_rows
      ) AS product_rows
      WHERE product_rows.dedupe_row = 1 ;;
  }

  label: "Product mentions"

  dimension: product_row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.product_row_key ;;
  }

  dimension: data_id {
    hidden: yes
    type: string
    sql: ${TABLE}.data_id ;;
  }

  dimension: product {
    type: string
    sql: ${TABLE}.product ;;
    label: "Product"
    group_label: "Product and value chain"
    case_sensitive: no
  }

  dimension: product_role {
    type: string
    sql: IF(${TABLE}.is_primary, 'Primary', 'Secondary') ;;
    label: "Product role"
    group_label: "Product and value chain"
    description: "Primary or Secondary. Secondary rows are products other than the primary product."
    order_by_field: product_role_sort
  }

  dimension: product_role_sort {
    hidden: yes
    type: number
    sql: IF(${TABLE}.is_primary, 1, 2) ;;
  }

  measure: mention_count {
    type: count
    label: "Product mentions"
    group_label: "Volume"
    description: "One for the primary product and one for each other distinct product mentioned."
    value_format_name: decimal_0
    drill_fields: [product, product_role, conversation_insights.conversation_detail*]
  }

  measure: conversation_count {
    type: count_distinct
    sql: ${data_id} ;;
    label: "Conversations"
    group_label: "Volume"
    description: "Distinct enriched conversations in the mention rows. Use this when a conversation must count once."
    value_format_name: decimal_0
  }
}
