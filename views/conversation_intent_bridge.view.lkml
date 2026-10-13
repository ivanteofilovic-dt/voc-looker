# Grain: one primary intent, plus one row per distinct secondary intent
# that is not a blank or a case-insensitive copy of the primary intent.

view: conversation_intent_bridge {
  derived_table: {
    datagroup_trigger: voc_daily
    cluster_keys: ["data_id"]
    sql:
      SELECT
        data_id,
        intent,
        intent_subcategory,
        is_primary,
        intent_row_key
      FROM (
        SELECT
          data_id,
          TRIM(primary_intent) AS intent,
          NULLIF(TRIM(primary_intent_subcategory), '') AS intent_subcategory,
          TRUE AS is_primary,
          CONCAT(data_id, '::primary::', TRIM(primary_intent)) AS intent_row_key,
          1 AS dedupe_row
        FROM ${conversation_insights.SQL_TABLE_NAME}
        WHERE NULLIF(TRIM(primary_intent), '') IS NOT NULL

        UNION ALL

        SELECT
          data_id,
          intent,
          CAST(NULL AS STRING) AS intent_subcategory,
          FALSE AS is_primary,
          CONCAT(data_id, '::secondary::', intent) AS intent_row_key,
          ROW_NUMBER() OVER (
            PARTITION BY data_id, LOWER(intent)
            ORDER BY intent
          ) AS dedupe_row
        FROM (
          SELECT
            insights.data_id,
            TRIM(secondary_intent) AS intent
          FROM ${conversation_insights.SQL_TABLE_NAME} AS insights
          CROSS JOIN UNNEST(IFNULL(insights.secondary_intents, [])) AS secondary_intent
          WHERE NULLIF(TRIM(secondary_intent), '') IS NOT NULL
            AND LOWER(TRIM(secondary_intent)) != LOWER(TRIM(IFNULL(insights.primary_intent, '')))
        ) AS secondary_rows
      ) AS intent_rows
      WHERE intent_rows.dedupe_row = 1 ;;
  }

  label: "Intent mentions"

  dimension: intent_row_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.intent_row_key ;;
  }

  dimension: data_id {
    hidden: yes
    type: string
    sql: ${TABLE}.data_id ;;
  }

  dimension: intent {
    type: string
    sql: ${TABLE}.intent ;;
    label: "Intent"
    group_label: "Intent"
    case_sensitive: no
  }

  dimension: intent_subcategory {
    type: string
    sql: COALESCE(${TABLE}.intent_subcategory, 'Unknown') ;;
    label: "Intent subcategory"
    group_label: "Intent"
    description: "Populated for the primary intent only. The source table has no subcategory for secondary intents."
    case_sensitive: no
  }

  dimension: intent_role {
    type: string
    sql: IF(${TABLE}.is_primary, 'Primary', 'Secondary') ;;
    label: "Intent role"
    group_label: "Intent"
    description: "Primary or Secondary. Secondary rows are intents other than the primary intent."
    order_by_field: intent_role_sort
  }

  dimension: intent_role_sort {
    hidden: yes
    type: number
    sql: IF(${TABLE}.is_primary, 1, 2) ;;
  }

  measure: mention_count {
    type: count
    label: "Intent mentions"
    group_label: "Volume"
    description: "One for the primary intent and one for each distinct secondary intent. A conversation with two intents counts as two mentions."
    value_format_name: decimal_0
    drill_fields: [intent, intent_role, intent_subcategory, conversation_insights.conversation_detail*]
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
