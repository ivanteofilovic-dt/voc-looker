# One row. All-time table sizes. This explore does not follow a conversation-date filter.

view: enrichment_coverage {
  derived_table: {
    datagroup_trigger: voc_daily
    sql:
      SELECT
        1 AS coverage_row_key,
        enriched.enriched_conversations,
        dump.dump_conversations,
        enriched.earliest_conversation_date,
        enriched.latest_conversation_date,
        enriched.latest_processing_timestamp,
        enriched.model_versions
      FROM (
        SELECT
          COUNT(*) AS enriched_conversations,
          MIN(conversation_date) AS earliest_conversation_date,
          MAX(conversation_date) AS latest_conversation_date,
          MAX(processing_timestamp) AS latest_processing_timestamp,
          COUNT(DISTINCT NULLIF(TRIM(model_version), '')) AS model_versions
        FROM ${conversation_insights.SQL_TABLE_NAME}
      ) AS enriched
      CROSS JOIN (
        SELECT COUNT(*) AS dump_conversations
        FROM @{DUMP_TABLE}
      ) AS dump ;;
  }

  label: "Enrichment coverage"

  dimension: coverage_row_key {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.coverage_row_key ;;
  }

  measure: enriched_conversations {
    type: max
    sql: ${TABLE}.enriched_conversations ;;
    label: "Enriched conversations"
    group_label: "Quality and lineage"
    description: "Row count of the enriched table. Ignores dashboard date filters."
    value_format_name: decimal_0
  }

  measure: dump_conversations {
    type: max
    sql: ${TABLE}.dump_conversations ;;
    label: "Dump conversations"
    group_label: "Quality and lineage"
    description: "Row count of the conversation dump. Ignores dashboard date filters."
    value_format_name: decimal_0
  }

  measure: enrichment_coverage_rate {
    type: number
    sql: MAX(${TABLE}.enriched_conversations) / NULLIF(MAX(${TABLE}.dump_conversations), 0) ;;
    label: "Enrichment coverage rate"
    group_label: "Quality and lineage"
    description: "Enriched rows divided by dump rows, all time. This is not coverage for the selected date filter."
    value_format_name: percent_1
  }

  measure: earliest_conversation_date {
    type: string
    sql: FORMAT_DATE('%Y-%m-%d', MAX(${TABLE}.earliest_conversation_date)) ;;
    label: "Earliest enriched conversation"
    group_label: "Time"
    description: "Earliest conversation date in the enriched table."
  }

  measure: latest_conversation_date {
    type: string
    sql: FORMAT_DATE('%Y-%m-%d', MAX(${TABLE}.latest_conversation_date)) ;;
    label: "Latest enriched conversation"
    group_label: "Time"
    description: "Latest conversation date in the enriched table."
  }

  measure: latest_enrichment_time {
    type: string
    sql: FORMAT_TIMESTAMP('%Y-%m-%d %H:%M UTC', MAX(${TABLE}.latest_processing_timestamp)) ;;
    label: "Latest enrichment time"
    group_label: "Quality and lineage"
    description: "Latest enrichment timestamp in the enriched table, shown in UTC."
  }

  measure: model_version_count {
    type: max
    sql: ${TABLE}.model_versions ;;
    label: "Distinct model versions in the enriched table"
    group_label: "Quality and lineage"
    description: "Distinct model versions present in the enriched table."
    value_format_name: decimal_0
  }
}
