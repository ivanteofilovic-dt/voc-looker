- dashboard: data_quality
  title: "Data quality and coverage"
  description: "Enrichment coverage against the conversation dump, field coverage, and score-range checks."
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
  - name: model_version
    title: "Model version"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.model_version

  elements:
  - name: how_to_read
    type: text
    title_text: "How to read this page"
    body_text: "The all-time tiles ignore the date filter. They compare the whole enriched table with the whole conversation dump. The other tiles follow Conversation date. Exception counts are expected to be 0. Category values stay in the language written by the enrichment model."
    row: 0
    col: 0
    width: 24
    height: 5

  - name: enriched_all_time
    title: "Enriched conversations"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.enriched_conversations]
    row: 5
    col: 0
    width: 4
    height: 4

  - name: dump_all_time
    title: "Dump conversations"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.dump_conversations]
    row: 5
    col: 4
    width: 4
    height: 4

  - name: coverage_rate
    title: "Enrichment coverage rate"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.enrichment_coverage_rate]
    note_text: "All-time enriched rows divided by all rows in the conversation dump. Ignores the date filter."
    note_display: hover
    row: 5
    col: 8
    width: 4
    height: 4

  - name: earliest_conversation
    title: "Earliest enriched conversation"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.earliest_conversation_date]
    row: 5
    col: 12
    width: 4
    height: 4

  - name: latest_conversation
    title: "Latest enriched conversation"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.latest_conversation_date]
    row: 5
    col: 16
    width: 4
    height: 4

  - name: latest_enrichment
    title: "Latest enrichment time"
    model: voc
    explore: enrichment_coverage
    type: single_value
    fields: [enrichment_coverage.latest_enrichment_time]
    row: 5
    col: 20
    width: 4
    height: 4

  - name: exceptions
    title: "Data-quality exceptions in the selected period"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.duplicate_conversation_keys
    - conversation_insights.sentiment_score_out_of_range
    - conversation_insights.frustration_score_out_of_range
    - conversation_insights.confidence_score_out_of_range
    - conversation_insights.word_count_negative_rows
    limit: 1
    show_totals: false
    listen:
      date: conversation_insights.conversation_date
      model_version: conversation_insights.model_version
    row: 9
    col: 0
    width: 24
    height: 4

  - name: field_coverage
    title: "Field coverage in the selected period"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.primary_intent_coverage
    - conversation_insights.value_chain_coverage
    - conversation_insights.product_coverage
    - conversation_insights.driver_coverage
    - conversation_insights.channel_coverage
    - conversation_insights.outcome_coverage
    limit: 1
    show_totals: false
    note_text: "Populated values in the filtered period. Missing and blank values count as not covered."
    note_display: hover
    listen:
      date: conversation_insights.conversation_date
      model_version: conversation_insights.model_version
    row: 13
    col: 0
    width: 24
    height: 4

  - name: confidence_tier
    title: "Confidence tier"
    model: voc
    explore: conversation_insights
    type: looker_column
    fields: [conversation_insights.confidence_tier, conversation_insights.count]
    sorts: [conversation_insights.confidence_tier]
    limit: 10
    listen:
      date: conversation_insights.conversation_date
      model_version: conversation_insights.model_version
    row: 17
    col: 0
    width: 12
    height: 8

  - name: model_versions
    title: "Model version"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields: [conversation_insights.model_version, conversation_insights.count]
    sorts: [conversation_insights.count desc]
    limit: 15
    listen:
      date: conversation_insights.conversation_date
      model_version: conversation_insights.model_version
    row: 17
    col: 12
    width: 12
    height: 8

  - name: enrichment_week
    title: "Conversations by enrichment week"
    model: voc
    explore: conversation_insights
    type: looker_column
    fields: [conversation_insights.processing_week, conversation_insights.count]
    sorts: [conversation_insights.processing_week]
    limit: 500
    listen:
      date: conversation_insights.conversation_date
      model_version: conversation_insights.model_version
    row: 25
    col: 0
    width: 24
    height: 7
