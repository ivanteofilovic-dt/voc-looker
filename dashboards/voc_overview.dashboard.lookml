- dashboard: voc_overview
  title: "VoC overview"
  description: "Start page for enriched conversation trends, mix, and data freshness."
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
  - name: channel
    title: "Channel (inferred)"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.channel_inferred
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

  elements:
  - name: how_to_read
    type: text
    title_text: "How to read this page"
    body_text: "Counts are enriched conversations, not unique customers and not the full conversation dump. Word count is an effort proxy until Genesys handling time is connected. Repeat contact is a model flag, not a stitched customer journey. Channel is inferred. Failure demand means unresolved, escalated, or a frustration score of 0.6 or higher. If this page is empty, widen Conversation date."
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
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 0
    width: 4
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
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 4
    width: 4
    height: 4

  - name: repeat_contact_rate
    title: "Repeat-contact rate"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.repeat_contact_rate]
    note_text: "Model flag on the conversation. Not a unique-customer repeat rate."
    note_display: hover
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 8
    width: 4
    height: 4

  - name: average_frustration
    title: "Average frustration score"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.average_frustration_score]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 12
    width: 4
    height: 4

  - name: average_sentiment
    title: "Average sentiment score"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.average_sentiment_score]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 16
    width: 4
    height: 4

  - name: average_word_count
    title: "Average word count"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.average_word_count]
    note_text: "Effort proxy from transcript length. Not Genesys handling time."
    note_display: hover
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 5
    col: 20
    width: 4
    height: 4

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
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 9
    col: 0
    width: 16
    height: 8

  - name: sentiment_mix
    title: "Sentiment"
    model: voc
    explore: conversation_insights
    type: looker_column
    fields: [conversation_insights.sentiment_overall, conversation_insights.count]
    sorts: [conversation_insights.sentiment_overall]
    limit: 10
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 9
    col: 16
    width: 8
    height: 8

  - name: top_intents
    title: "Top primary intents"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields: [conversation_insights.primary_intent, conversation_insights.count]
    sorts: [conversation_insights.count desc]
    limit: 10
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 17
    col: 0
    width: 12
    height: 8

  - name: value_chain_volume
    title: "Conversations by value chain"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields: [conversation_insights.value_chain_tag, conversation_insights.count]
    sorts: [conversation_insights.count desc]
    limit: 10
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 17
    col: 12
    width: 12
    height: 8

  - name: latest_enrichment
    title: "Latest enrichment time"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.latest_processing_time]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 25
    col: 0
    width: 8
    height: 4

  - name: model_versions
    title: "Distinct model versions"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.distinct_model_versions]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 25
    col: 8
    width: 8
    height: 4

  - name: days_with_conversations
    title: "Days with conversations"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.days_with_conversations]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      channel: conversation_insights.channel_inferred
      confidence_tier: conversation_insights.confidence_tier
    row: 25
    col: 16
    width: 8
    height: 4
