connection: "@{BQ_CONNECTION}"

label: "Voice of the Customer"

include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

week_start_day: monday

datagroup: voc_daily {
  sql_trigger: SELECT MAX(processing_timestamp) FROM @{INSIGHTS_TABLE} ;;
  max_cache_age: "24 hours"
  label: "VoC daily refresh"
  description: "Rebuilds caches when the latest enrichment timestamp changes, and at least every 24 hours."
}

persist_with: voc_daily

access_grant: can_view_conversation_summaries {
  user_attribute: voc_can_view_summaries
  allowed_values: ["yes"]
}

explore: conversation_insights {
  label: "Conversations"
  description: "One row per enriched conversation. Counts are conversations in the enriched table, not unique customers and not the full conversation dump."
  sql_always_where:
    (${conversation_insights.passes_optional_intent_filter})
    AND (${conversation_insights.passes_optional_product_filter}) ;;
}

explore: intent_mentions {
  from: conversation_intent_bridge
  label: "Intent mentions"
  description: "One row per primary intent and each distinct secondary intent on a conversation. Use Conversations to count a conversation once. Use Intent mentions to count every time an intent appears. Subcategory is populated for the primary intent only."
  sql_always_where:
    (${conversation_insights.passes_optional_intent_filter})
    AND (${conversation_insights.passes_optional_product_filter}) ;;

  join: conversation_insights {
    type: left_outer
    relationship: many_to_one
    sql_on: ${intent_mentions.data_id} = ${conversation_insights.data_id} ;;
  }
}

explore: product_mentions {
  from: conversation_product_bridge
  label: "Product mentions"
  description: "One row per primary product and each distinct other product mentioned. Use Conversations to count a conversation once."
  sql_always_where:
    (${conversation_insights.passes_optional_intent_filter})
    AND (${conversation_insights.passes_optional_product_filter}) ;;

  join: conversation_insights {
    type: left_outer
    relationship: many_to_one
    sql_on: ${product_mentions.data_id} = ${conversation_insights.data_id} ;;
  }
}

explore: enrichment_coverage {
  label: "Enrichment coverage"
  description: "One row covering both tables. Compares the enriched table with the conversation dump. Not affected by conversation date filters."
}

test: conversation_keys_are_unique {
  explore_source: conversation_insights {
    column: duplicate_conversation_keys {
      field: conversation_insights.duplicate_conversation_keys
    }
  }
  assert: no_duplicate_keys {
    expression: ${conversation_insights.duplicate_conversation_keys} = 0 ;;
  }
}

test: sentiment_scores_match_schema {
  explore_source: conversation_insights {
    column: sentiment_score_out_of_range {
      field: conversation_insights.sentiment_score_out_of_range
    }
  }
  assert: sentiment_scores_within_range {
    expression: ${conversation_insights.sentiment_score_out_of_range} = 0 ;;
  }
}

test: frustration_scores_match_schema {
  explore_source: conversation_insights {
    column: frustration_score_out_of_range {
      field: conversation_insights.frustration_score_out_of_range
    }
  }
  assert: frustration_scores_within_range {
    expression: ${conversation_insights.frustration_score_out_of_range} = 0 ;;
  }
}

test: confidence_scores_match_schema {
  explore_source: conversation_insights {
    column: confidence_score_out_of_range {
      field: conversation_insights.confidence_score_out_of_range
    }
  }
  assert: confidence_scores_within_range {
    expression: ${conversation_insights.confidence_score_out_of_range} = 0 ;;
  }
}

test: word_counts_are_non_negative {
  explore_source: conversation_insights {
    column: word_count_negative_rows {
      field: conversation_insights.word_count_negative_rows
    }
  }
  assert: no_negative_word_counts {
    expression: ${conversation_insights.word_count_negative_rows} = 0 ;;
  }
}
