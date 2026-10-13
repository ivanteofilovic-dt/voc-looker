# Grain: one enriched conversation. data_id joins back to the source dump.
# Counts from this view are conversations, not customers.

view: conversation_insights {
  sql_table_name: @{INSIGHTS_TABLE} ;;
  label: "Conversations"

  dimension: data_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.data_id ;;
    label: "Conversation key"
    group_label: "Identifiers"
    description: "Technical key back to the source conversation. Not a customer identifier."
    suggestable: no
  }

  dimension_group: conversation {
    type: time
    datatype: date
    convert_tz: no
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.conversation_date ;;
    label: "Conversation"
    group_label: "Time"
  }

  dimension: primary_intent {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.primary_intent), ''), 'Unknown') ;;
    label: "Primary intent"
    group_label: "Intent"
    case_sensitive: no
  }

  dimension: primary_intent_subcategory {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.primary_intent_subcategory), ''), 'Unknown') ;;
    label: "Primary intent subcategory"
    group_label: "Intent"
    case_sensitive: no
  }

  dimension: secondary_intents_list {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.secondary_intents, ' | ') ;;
    label: "Secondary intents"
    group_label: "Intent"
    description: "Secondary intents stored on the conversation, separated by a pipe."
    suggestable: no
  }

  dimension: secondary_intent_count {
    type: number
    sql:
      (
        SELECT COUNT(DISTINCT TRIM(secondary_intent))
        FROM UNNEST(IFNULL(${TABLE}.secondary_intents, [])) AS secondary_intent
        WHERE NULLIF(TRIM(secondary_intent), '') IS NOT NULL
          AND LOWER(TRIM(secondary_intent)) != LOWER(TRIM(IFNULL(${TABLE}.primary_intent, '')))
      ) ;;
    label: "Secondary intent count"
    group_label: "Intent"
    description: "Distinct secondary intents after removing blanks and a duplicate of the primary intent."
    value_format_name: decimal_0
  }

  dimension: is_multi_intent {
    type: yesno
    sql:
      EXISTS (
        SELECT 1
        FROM UNNEST(IFNULL(${TABLE}.secondary_intents, [])) AS secondary_intent
        WHERE NULLIF(TRIM(secondary_intent), '') IS NOT NULL
          AND LOWER(TRIM(secondary_intent)) != LOWER(TRIM(IFNULL(${TABLE}.primary_intent, '')))
      ) ;;
    label: "Multi-intent conversation"
    group_label: "Intent"
    description: "Yes when a secondary intent remains after removing blanks and a duplicate of the primary intent."
  }

  filter: any_intent {
    type: string
    label: "Any intent"
    group_label: "Intent"
    description: "Keeps conversations whose primary intent or any secondary intent matches. Does not double-count the conversation."
    suggest_explore: intent_mentions
    suggest_dimension: intent_mentions.intent
  }

  dimension: passes_optional_intent_filter {
    hidden: yes
    type: yesno
    sql:
      {% if any_intent._is_filtered %}
        (({% condition any_intent %} TRIM(${TABLE}.primary_intent) {% endcondition %})
        OR COALESCE((
          SELECT LOGICAL_OR({% condition any_intent %} TRIM(secondary_intent) {% endcondition %})
          FROM UNNEST(IFNULL(${TABLE}.secondary_intents, [])) AS secondary_intent
        ), FALSE))
      {% else %}
        TRUE
      {% endif %} ;;
  }

  dimension: categorization_confidence_score {
    type: number
    sql: ${TABLE}.categorization_confidence_score ;;
    label: "Categorization confidence"
    group_label: "Quality and lineage"
    value_format_name: decimal_2
  }

  dimension: confidence_tier {
    type: string
    sql:
      CASE
        WHEN ${TABLE}.categorization_confidence_score IS NULL THEN 'Unknown'
        WHEN ${TABLE}.categorization_confidence_score >= 0.8 THEN 'High (>=0.8)'
        WHEN ${TABLE}.categorization_confidence_score >= 0.5 THEN 'Medium (0.5-0.8)'
        ELSE 'Low (<0.5)'
      END ;;
    label: "Confidence tier"
    group_label: "Quality and lineage"
    description: "High is 0.8 or above, Medium is 0.5 to below 0.8, Low is below 0.5. Unknown means no score."
    order_by_field: confidence_tier_sort
  }

  dimension: confidence_tier_sort {
    hidden: yes
    type: number
    sql:
      CASE
        WHEN ${TABLE}.categorization_confidence_score IS NULL THEN 4
        WHEN ${TABLE}.categorization_confidence_score >= 0.8 THEN 1
        WHEN ${TABLE}.categorization_confidence_score >= 0.5 THEN 2
        ELSE 3
      END ;;
  }

  dimension: is_high_confidence {
    type: yesno
    sql: COALESCE(${TABLE}.categorization_confidence_score >= 0.8, FALSE) ;;
    label: "High confidence"
    group_label: "Quality and lineage"
    description: "Yes when categorization confidence is 0.8 or higher. Null scores are No."
  }

  dimension: sentiment_overall {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.sentiment_overall), ''), 'Unknown') ;;
    label: "Sentiment"
    group_label: "Sentiment and frustration"
    case_sensitive: no
    order_by_field: sentiment_sort
    html:
      {% if value == "negative" %}
        <span style="color:#9b1c1c;">{{ value }}</span>
      {% elsif value == "positive" %}
        <span style="color:#17663a;">{{ value }}</span>
      {% else %}
        {{ value }}
      {% endif %} ;;
  }

  dimension: sentiment_sort {
    hidden: yes
    type: number
    sql:
      CASE LOWER(TRIM(${TABLE}.sentiment_overall))
        WHEN 'negative' THEN 1
        WHEN 'neutral' THEN 2
        WHEN 'positive' THEN 3
        ELSE 4
      END ;;
  }

  dimension: sentiment_score {
    type: number
    sql: ${TABLE}.sentiment_score ;;
    label: "Sentiment score"
    group_label: "Sentiment and frustration"
    value_format_name: decimal_2
  }

  dimension: customer_frustration_score {
    type: number
    sql: ${TABLE}.customer_frustration_score ;;
    label: "Frustration score"
    group_label: "Sentiment and frustration"
    value_format_name: decimal_2
  }

  dimension: frustration_tier {
    type: string
    sql:
      CASE
        WHEN ${TABLE}.customer_frustration_score IS NULL THEN 'Unknown'
        WHEN ${TABLE}.customer_frustration_score >= 0.6 THEN 'High (>=0.6)'
        WHEN ${TABLE}.customer_frustration_score >= 0.3 THEN 'Medium (0.3-0.6)'
        ELSE 'Low (<0.3)'
      END ;;
    label: "Frustration tier"
    group_label: "Sentiment and frustration"
    order_by_field: frustration_tier_sort
  }

  dimension: frustration_tier_sort {
    hidden: yes
    type: number
    sql:
      CASE
        WHEN ${TABLE}.customer_frustration_score IS NULL THEN 4
        WHEN ${TABLE}.customer_frustration_score >= 0.6 THEN 1
        WHEN ${TABLE}.customer_frustration_score >= 0.3 THEN 2
        ELSE 3
      END ;;
  }

  dimension: driver_trigger {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.driver_trigger), ''), 'Unknown') ;;
    label: "Driver"
    group_label: "Driver and pre-contact"
    description: "What the model says prompted the contact."
    case_sensitive: no
  }

  dimension: pre_contact_action {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.pre_contact_action), ''), 'Unknown') ;;
    label: "Pre-contact action"
    group_label: "Driver and pre-contact"
    description: "Self-service or channel the model says the customer used before this conversation."
    case_sensitive: no
  }

  dimension: product_mentioned {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.product_mentioned), ''), 'Unknown') ;;
    label: "Primary product"
    group_label: "Product and value chain"
    case_sensitive: no
  }

  dimension: products_mentioned_list {
    type: string
    sql: ARRAY_TO_STRING(${TABLE}.products_mentioned, ' | ') ;;
    label: "All products mentioned"
    group_label: "Product and value chain"
    description: "All products stored in the repeated field, separated by a pipe."
    suggestable: no
  }

  filter: any_product {
    type: string
    label: "Any product"
    group_label: "Product and value chain"
    description: "Keeps conversations whose primary product or any other mentioned product matches. Does not double-count the conversation."
    suggest_explore: product_mentions
    suggest_dimension: product_mentions.product
  }

  dimension: passes_optional_product_filter {
    hidden: yes
    type: yesno
    sql:
      {% if any_product._is_filtered %}
        (({% condition any_product %} TRIM(${TABLE}.product_mentioned) {% endcondition %})
        OR COALESCE((
          SELECT LOGICAL_OR({% condition any_product %} TRIM(product) {% endcondition %})
          FROM UNNEST(IFNULL(${TABLE}.products_mentioned, [])) AS product
        ), FALSE))
      {% else %}
        TRUE
      {% endif %} ;;
  }

  dimension: process_dimension {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.process_dimension), ''), 'Unknown') ;;
    label: "Process"
    group_label: "Product and value chain"
    case_sensitive: no
  }

  dimension: value_chain_tag {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.value_chain_tag), ''), 'Unknown') ;;
    label: "Value chain"
    group_label: "Product and value chain"
    case_sensitive: no
  }

  dimension: channel_inferred {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.channel_inferred), ''), 'Unknown') ;;
    label: "Channel (inferred)"
    group_label: "Product and value chain"
    description: "Channel inferred by the enrichment model. Not the Genesys channel code."
    case_sensitive: no
  }

  dimension: agent_solution {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.agent_solution), ''), 'Unknown') ;;
    label: "Agent solution"
    group_label: "Resolution"
    description: "Action the model says the agent took. May be a category or free text."
    suggestable: no
  }

  dimension: outcome {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.outcome), ''), 'Unknown') ;;
    label: "Outcome"
    group_label: "Resolution"
    case_sensitive: no
    order_by_field: outcome_sort
  }

  dimension: outcome_sort {
    hidden: yes
    type: number
    sql:
      CASE LOWER(TRIM(${TABLE}.outcome))
        WHEN 'unresolved' THEN 1
        WHEN 'escalated' THEN 2
        WHEN 'resolved' THEN 3
        WHEN 'self-service' THEN 4
        WHEN 'self_service' THEN 4
        WHEN 'self service' THEN 4
        ELSE 5
      END ;;
  }

  dimension: conversation_summary {
    type: string
    sql: ${TABLE}.conversation_summary ;;
    label: "Conversation summary"
    group_label: "Resolution"
    description: "Short model summary of the conversation. Restricted because the text can contain personal data."
    suggestable: no
    required_access_grants: [can_view_conversation_summaries]
  }

  dimension: is_repeat_contact_candidate {
    type: yesno
    sql: ${TABLE}.is_repeat_contact_candidate ;;
    label: "Repeat-contact candidate"
    group_label: "Repeat and effort"
    description: "Model flag that the conversation looks like a repeat. Not a customer-level repeat rate."
  }

  dimension: word_count {
    type: number
    sql: ${TABLE}.word_count ;;
    label: "Word count"
    group_label: "Repeat and effort"
    description: "Transcript word count. Use as an effort proxy, not as handling time."
    value_format_name: decimal_0
  }

  dimension: word_count_tier {
    type: tier
    tiers: [50, 150, 400, 800]
    style: integer
    sql: ${word_count} ;;
    label: "Word count tier"
    group_label: "Repeat and effort"
    description: "Buckets of transcript length. This is not a handling-time band."
  }

  dimension: demand_class {
    type: string
    sql:
      CASE
        WHEN LOWER(TRIM(${TABLE}.outcome)) IN ('unresolved', 'escalated')
          OR ${TABLE}.customer_frustration_score >= 0.6
          THEN 'Failure demand'
        WHEN LOWER(TRIM(${TABLE}.outcome)) IN ('resolved', 'self-service', 'self_service', 'self service')
          THEN 'Value demand'
        ELSE 'Unclassified'
      END ;;
    label: "Demand class"
    group_label: "Demand"
    description: "Failure demand: unresolved, escalated, or frustration score at or above 0.6. Value demand: resolved or self-service and not failure demand. Otherwise Unclassified."
    order_by_field: demand_class_sort
    html:
      {% if value == "Failure demand" %}
        <span style="color:#9b1c1c;">{{ value }}</span>
      {% elsif value == "Value demand" %}
        <span style="color:#17663a;">{{ value }}</span>
      {% else %}
        {{ value }}
      {% endif %} ;;
  }

  dimension: demand_class_sort {
    hidden: yes
    type: number
    sql:
      CASE
        WHEN (${demand_class}) = 'Failure demand' THEN 1
        WHEN (${demand_class}) = 'Value demand' THEN 2
        ELSE 3
      END ;;
  }

  dimension: is_failure_demand {
    hidden: yes
    type: yesno
    sql: (${demand_class}) = 'Failure demand' ;;
  }

  dimension: is_value_demand {
    hidden: yes
    type: yesno
    sql: (${demand_class}) = 'Value demand' ;;
  }

  dimension_group: processing {
    type: time
    datatype: timestamp
    timeframes: [time, date, week, month]
    sql: ${TABLE}.processing_timestamp ;;
    label: "Enrichment"
    group_label: "Quality and lineage"
  }

  dimension: model_version {
    type: string
    sql: COALESCE(NULLIF(TRIM(${TABLE}.model_version), ''), 'Unknown') ;;
    label: "Model version"
    group_label: "Quality and lineage"
  }

  set: conversation_detail {
    fields: [
      data_id,
      conversation_date,
      primary_intent,
      primary_intent_subcategory,
      secondary_intents_list,
      is_multi_intent,
      sentiment_overall,
      sentiment_score,
      customer_frustration_score,
      demand_class,
      outcome,
      driver_trigger,
      pre_contact_action,
      product_mentioned,
      products_mentioned_list,
      process_dimension,
      value_chain_tag,
      channel_inferred,
      agent_solution,
      confidence_tier,
      categorization_confidence_score,
      is_repeat_contact_candidate,
      word_count,
      model_version
    ]
  }

  measure: count {
    type: count
    label: "Enriched conversations"
    group_label: "Volume"
    description: "Rows in the enriched conversation table after filters. Not unique customers and not the full dump."
    value_format_name: decimal_0
    drill_fields: [conversation_detail*]
  }

  measure: percent_of_conversations {
    type: percent_of_total
    sql: ${count} ;;
    label: "Share of enriched conversations"
    group_label: "Volume"
    description: "Share of enriched conversations in the current result. This is the mix after filters, not a share of the full dump."
    value_format_name: percent_1
  }

  measure: count_previous_month {
    type: period_over_period
    based_on: conversation_insights.count
    based_on_time: conversation_insights.conversation_date
    period: month
    kind: previous
    label: "Conversations previous month"
    group_label: "Volume"
    description: "Enriched conversation count for the previous month relative to each time bucket in the query."
    value_format_name: decimal_0
  }

  measure: count_change_vs_previous_month {
    type: period_over_period
    based_on: conversation_insights.count
    based_on_time: conversation_insights.conversation_date
    period: month
    kind: relative_change
    label: "Change vs previous month"
    group_label: "Volume"
    description: "Percent change versus the previous month. Place Conversation month, week, or date in the query. Empty when the previous period has no enriched rows."
    value_format_name: percent_1
  }

  measure: count_previous_year {
    type: period_over_period
    based_on: conversation_insights.count
    based_on_time: conversation_insights.conversation_date
    period: year
    kind: previous
    label: "Conversations previous year"
    group_label: "Volume"
    description: "Enriched conversation count for the same period last year, following the time bucket in the query."
    value_format_name: decimal_0
  }

  measure: count_change_vs_previous_year {
    type: period_over_period
    based_on: conversation_insights.count
    based_on_time: conversation_insights.conversation_date
    period: year
    kind: relative_change
    label: "Change vs previous year"
    group_label: "Volume"
    description: "Percent change versus the same period last year. Place a conversation time field in the query. Empty when the previous year has no enriched rows."
    value_format_name: percent_1
  }

  measure: repeat_conversations {
    type: sum
    sql: IF(${TABLE}.is_repeat_contact_candidate IS TRUE, 1, 0) ;;
    label: "Repeat-contact conversations"
    group_label: "Repeat and effort"
    description: "Conversations flagged as repeat-contact candidates."
    value_format_name: decimal_0
    drill_fields: [conversation_detail*]
  }

  measure: repeat_contact_rate {
    type: number
    sql: ${repeat_conversations} / NULLIF(${count}, 0) ;;
    label: "Repeat-contact rate"
    group_label: "Repeat and effort"
    description: "Share of enriched conversations flagged as repeat-contact candidates. Not a unique-customer repeat rate."
    value_format_name: percent_1
  }

  measure: average_sentiment_score {
    type: average
    sql: ${sentiment_score} ;;
    label: "Average sentiment score"
    group_label: "Sentiment and frustration"
    description: "Average of populated scores only. Conversations with no score are left out of the average."
    value_format_name: decimal_2
  }

  measure: average_frustration_score {
    type: average
    sql: ${customer_frustration_score} ;;
    label: "Average frustration score"
    group_label: "Sentiment and frustration"
    description: "Average of populated scores only. Conversations with no score are left out of the average."
    value_format_name: decimal_2
  }

  measure: average_confidence_score {
    type: average
    sql: ${categorization_confidence_score} ;;
    label: "Average categorization confidence"
    group_label: "Quality and lineage"
    description: "Average of populated scores only. Conversations with no score are left out of the average."
    value_format_name: decimal_2
  }

  measure: average_word_count {
    type: average
    sql: ${word_count} ;;
    label: "Average word count"
    group_label: "Repeat and effort"
    description: "Average transcript word count. Effort proxy, not Genesys handling time."
    value_format_name: decimal_0
  }

  measure: median_word_count {
    type: median
    sql: ${word_count} ;;
    label: "Median word count"
    group_label: "Repeat and effort"
    description: "Median transcript word count. Effort proxy, not Genesys handling time."
    value_format_name: decimal_0
  }

  measure: total_word_count {
    type: sum
    sql: ${word_count} ;;
    label: "Total word count"
    group_label: "Repeat and effort"
    description: "Sum of transcript word counts. Use to compare effort mass, not to report handling time."
    value_format_name: decimal_0
  }

  measure: failure_demand_conversations {
    type: sum
    sql: IF(${is_failure_demand}, 1, 0) ;;
    label: "Failure-demand conversations"
    group_label: "Demand"
    description: "Conversations classed as failure demand by the demand-class rule."
    value_format_name: decimal_0
    drill_fields: [conversation_detail*]
  }

  measure: value_demand_conversations {
    type: sum
    sql: IF(${is_value_demand}, 1, 0) ;;
    label: "Value-demand conversations"
    group_label: "Demand"
    description: "Conversations classed as value demand by the demand-class rule."
    value_format_name: decimal_0
    drill_fields: [conversation_detail*]
  }

  measure: failure_demand_rate {
    type: number
    sql: ${failure_demand_conversations} / NULLIF(${count}, 0) ;;
    label: "Failure-demand rate"
    group_label: "Demand"
    description: "Share of enriched conversations classed as failure demand."
    value_format_name: percent_1
  }

  measure: value_demand_rate {
    type: number
    sql: ${value_demand_conversations} / NULLIF(${count}, 0) ;;
    label: "Value-demand rate"
    group_label: "Demand"
    description: "Share of enriched conversations classed as value demand."
    value_format_name: percent_1
  }

  measure: unresolved_conversations {
    type: sum
    sql: IF(LOWER(TRIM(${TABLE}.outcome)) = 'unresolved', 1, 0) ;;
    label: "Unresolved conversations"
    group_label: "Resolution"
    description: "Conversations whose outcome is unresolved."
    value_format_name: decimal_0
  }

  measure: escalated_conversations {
    type: sum
    sql: IF(LOWER(TRIM(${TABLE}.outcome)) = 'escalated', 1, 0) ;;
    label: "Escalated conversations"
    group_label: "Resolution"
    description: "Conversations whose outcome is escalated."
    value_format_name: decimal_0
  }

  measure: unresolved_or_escalated_rate {
    type: number
    sql: (${unresolved_conversations} + ${escalated_conversations}) / NULLIF(${count}, 0) ;;
    label: "Unresolved or escalated rate"
    group_label: "Resolution"
    description: "Share of enriched conversations whose outcome is unresolved or escalated."
    value_format_name: percent_1
  }

  measure: multi_intent_conversations {
    type: sum
    sql: IF(${is_multi_intent}, 1, 0) ;;
    label: "Multi-intent conversations"
    group_label: "Intent"
    description: "Conversations that still have a secondary intent after removing blanks and a copy of the primary intent."
    value_format_name: decimal_0
    drill_fields: [conversation_detail*]
  }

  measure: multi_intent_rate {
    type: number
    sql: ${multi_intent_conversations} / NULLIF(${count}, 0) ;;
    label: "Multi-intent rate"
    group_label: "Intent"
    description: "Share of enriched conversations that still have a secondary intent after removing blanks and a copy of the primary intent."
    value_format_name: percent_1
  }

  measure: high_confidence_conversations {
    type: sum
    sql: IF(${TABLE}.categorization_confidence_score >= 0.8, 1, 0) ;;
    label: "High-confidence conversations"
    group_label: "Quality and lineage"
    description: "Conversations with categorization confidence of 0.8 or higher."
    value_format_name: decimal_0
  }

  measure: high_confidence_rate {
    type: number
    sql: ${high_confidence_conversations} / NULLIF(${count}, 0) ;;
    label: "High-confidence rate"
    group_label: "Quality and lineage"
    description: "Share of all enriched conversations with categorization confidence of 0.8 or higher. Missing scores count against the rate."
    value_format_name: percent_1
  }

  measure: days_with_conversations {
    type: count_distinct
    sql: ${TABLE}.conversation_date ;;
    label: "Days with conversations"
    group_label: "Time"
    description: "Distinct conversation dates in the result."
    value_format_name: decimal_0
  }

  measure: latest_processing_time {
    type: string
    sql: FORMAT_TIMESTAMP('%Y-%m-%d %H:%M UTC', MAX(${TABLE}.processing_timestamp)) ;;
    label: "Latest enrichment time"
    group_label: "Quality and lineage"
    description: "Latest enrichment timestamp in the result, shown in UTC."
  }

  measure: distinct_model_versions {
    type: count_distinct
    sql: NULLIF(TRIM(${TABLE}.model_version), '') ;;
    label: "Distinct model versions"
    group_label: "Quality and lineage"
    description: "Distinct enrichment model versions in the result."
    value_format_name: decimal_0
  }

  measure: distinct_primary_intents {
    type: count_distinct
    sql: NULLIF(TRIM(${TABLE}.primary_intent), '') ;;
    label: "Distinct primary intents"
    group_label: "Intent"
    description: "Distinct primary intent values in the result, excluding blank."
    value_format_name: decimal_0
  }

  measure: distinct_value_chains {
    type: count_distinct
    sql: NULLIF(TRIM(${TABLE}.value_chain_tag), '') ;;
    label: "Distinct value chains"
    group_label: "Product and value chain"
    description: "Distinct value chain values in the result, excluding blank."
    value_format_name: decimal_0
  }

  measure: primary_intent_coverage {
    type: number
    sql: 1 - (${missing_primary_intent} / NULLIF(${count}, 0)) ;;
    label: "Primary intent coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: value_chain_coverage {
    type: number
    sql: 1 - (${missing_value_chain} / NULLIF(${count}, 0)) ;;
    label: "Value chain coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: product_coverage {
    type: number
    sql: 1 - (${missing_product} / NULLIF(${count}, 0)) ;;
    label: "Product coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: driver_coverage {
    type: number
    sql: 1 - (${missing_driver} / NULLIF(${count}, 0)) ;;
    label: "Driver coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: channel_coverage {
    type: number
    sql: 1 - (${missing_channel} / NULLIF(${count}, 0)) ;;
    label: "Channel coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: outcome_coverage {
    type: number
    sql: 1 - (${missing_outcome} / NULLIF(${count}, 0)) ;;
    label: "Outcome coverage"
    group_label: "Quality and lineage"
    description: "Share of filtered conversations where this field is populated. Blank values count as missing."
    value_format_name: percent_1
  }

  measure: missing_primary_intent {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.primary_intent IS NULL OR TRIM(${TABLE}.primary_intent) = '', 1, 0) ;;
  }

  measure: missing_value_chain {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.value_chain_tag IS NULL OR TRIM(${TABLE}.value_chain_tag) = '', 1, 0) ;;
  }

  measure: missing_product {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.product_mentioned IS NULL OR TRIM(${TABLE}.product_mentioned) = '', 1, 0) ;;
  }

  measure: missing_driver {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.driver_trigger IS NULL OR TRIM(${TABLE}.driver_trigger) = '', 1, 0) ;;
  }

  measure: missing_channel {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.channel_inferred IS NULL OR TRIM(${TABLE}.channel_inferred) = '', 1, 0) ;;
  }

  measure: missing_outcome {
    hidden: yes
    type: sum
    sql: IF(${TABLE}.outcome IS NULL OR TRIM(${TABLE}.outcome) = '', 1, 0) ;;
  }

  measure: duplicate_conversation_keys {
    type: number
    sql: COUNT(1) - COUNT(DISTINCT ${TABLE}.data_id) ;;
    label: "Duplicate conversation keys"
    group_label: "Quality and lineage"
    description: "Rows in the filtered result that break this check. Expected value is 0."
    value_format_name: decimal_0
  }

  measure: sentiment_score_out_of_range {
    type: sum
    sql:
      IF(
        ${TABLE}.sentiment_score IS NOT NULL
        AND (${TABLE}.sentiment_score < -1 OR ${TABLE}.sentiment_score > 1),
        1,
        0
      ) ;;
    label: "Sentiment scores outside -1 to 1"
    group_label: "Quality and lineage"
    description: "Rows in the filtered result that break this check. Expected value is 0."
    value_format_name: decimal_0
  }

  measure: frustration_score_out_of_range {
    type: sum
    sql:
      IF(
        ${TABLE}.customer_frustration_score IS NOT NULL
        AND (${TABLE}.customer_frustration_score < 0 OR ${TABLE}.customer_frustration_score > 1),
        1,
        0
      ) ;;
    label: "Frustration scores outside 0 to 1"
    group_label: "Quality and lineage"
    description: "Rows in the filtered result that break this check. Expected value is 0."
    value_format_name: decimal_0
  }

  measure: confidence_score_out_of_range {
    type: sum
    sql:
      IF(
        ${TABLE}.categorization_confidence_score IS NOT NULL
        AND (${TABLE}.categorization_confidence_score < 0 OR ${TABLE}.categorization_confidence_score > 1),
        1,
        0
      ) ;;
    label: "Confidence scores outside 0 to 1"
    group_label: "Quality and lineage"
    description: "Rows in the filtered result that break this check. Expected value is 0."
    value_format_name: decimal_0
  }

  measure: word_count_negative_rows {
    type: sum
    sql: IF(${TABLE}.word_count < 0, 1, 0) ;;
    label: "Negative word counts"
    group_label: "Quality and lineage"
    description: "Rows in the filtered result that break this check. Expected value is 0."
    value_format_name: decimal_0
  }
}
