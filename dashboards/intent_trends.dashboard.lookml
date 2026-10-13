- dashboard: intent_trends
  title: "Intent trends"
  description: "Intent volume, share, and period comparison. The intent filter changes the trend, not the mix table."
  layout: newspaper
  preferred_viewer: dashboards-next
  crossfilter_enabled: false
  filters:
  - name: date
    title: "Conversation date"
    type: field_filter
    default_value: "3 years"
    allow_multiple_values: true
    required: false
    ui_config:
      type: relative_timeframes
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.conversation_date
  - name: any_intent
    title: "Any intent"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: voc
    explore: conversation_insights
    field: conversation_insights.any_intent
  - name: value_chain
    title: "Value chain"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.value_chain_tag
  - name: any_product
    title: "Any product"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: voc
    explore: conversation_insights
    field: conversation_insights.any_product
  - name: confidence_tier
    title: "Confidence tier"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.confidence_tier
  - name: sentiment
    title: "Sentiment"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.sentiment_overall

  elements:
  - name: how_to_read
    type: text
    title_text: "How to read this page"
    body_text: "The monthly table compares each month with the previous month and the same month last year. Empty comparison cells mean the enriched table has no rows in that earlier period. The intent filter applies to the scorecards and trend, not to the intent mix, so the mix stays a share of all enriched conversations in the other filters. Subcategory exists for the primary intent only."
    row: 0
    col: 0
    width: 24
    height: 5

  - name: conversations
    title: "Enriched conversations"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.count]
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 5
    col: 0
    width: 6
    height: 4

  - name: multi_intent_rate
    title: "Multi-intent rate"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.multi_intent_rate]
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 5
    col: 6
    width: 6
    height: 4

  - name: average_confidence
    title: "Average categorization confidence"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.average_confidence_score]
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 5
    col: 12
    width: 6
    height: 4

  - name: failure_demand_rate
    title: "Failure-demand rate"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.failure_demand_rate]
    note_text: "Unresolved, escalated, or frustration score at or above 0.6."
    note_display: hover
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 5
    col: 18
    width: 6
    height: 4

  - name: monthly_comparison
    title: "Monthly comparison"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.conversation_month
    - conversation_insights.count
    - conversation_insights.count_previous_month
    - conversation_insights.count_change_vs_previous_month
    - conversation_insights.count_previous_year
    - conversation_insights.count_change_vs_previous_year
    sorts: [conversation_insights.conversation_month desc]
    limit: 36
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 9
    col: 0
    width: 24
    height: 8

  - name: weekly_trend
    title: "Conversations by week"
    model: voc
    explore: conversation_insights
    type: looker_line
    fields: [conversation_insights.conversation_week, conversation_insights.count]
    sorts: [conversation_insights.conversation_week]
    limit: 500
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 17
    col: 0
    width: 24
    height: 7

  - name: intent_mix
    title: "Intent mix"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.primary_intent
    - conversation_insights.count
    - conversation_insights.percent_of_conversations
    - conversation_insights.multi_intent_rate
    - conversation_insights.failure_demand_rate
    - conversation_insights.repeat_contact_rate
    - conversation_insights.average_frustration_score
    - conversation_insights.average_confidence_score
    sorts: [conversation_insights.count desc]
    limit: 25
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 24
    col: 0
    width: 14
    height: 10

  - name: subcategories
    title: "Primary intent subcategory"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.primary_intent_subcategory
    - conversation_insights.count
    - conversation_insights.percent_of_conversations
    sorts: [conversation_insights.count desc]
    limit: 20
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      any_intent: conversation_insights.any_intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 24
    col: 14
    width: 10
    height: 10

  - name: intent_mentions
    title: "Intent mentions, primary and secondary"
    model: voc
    explore: intent_mentions
    type: looker_bar
    fields: [intent_mentions.intent, intent_mentions.intent_role, intent_mentions.mention_count]
    pivots: [intent_mentions.intent_role]
    sorts: [intent_mentions.mention_count desc]
    limit: 15
    stacking: normal
    listen:
      date: conversation_insights.conversation_date
      any_intent: intent_mentions.intent
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      confidence_tier: conversation_insights.confidence_tier
      sentiment: conversation_insights.sentiment_overall
    row: 34
    col: 0
    width: 24
    height: 8
