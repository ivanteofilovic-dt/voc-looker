- dashboard: value_chain_demand
  title: "Value chain and demand"
  description: "Value chain, product, and process view with the failure-demand and value-demand proxy."
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
  - name: process
    title: "Process"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.process_dimension
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

  elements:
  - name: how_to_read
    type: text
    title_text: "How to read this page"
    body_text: "The detail table attributes each conversation to its primary product. The product chart counts every distinct product mentioned. Failure demand is a proxy for pain: outcome unresolved or escalated, or frustration score at or above 0.6. Value demand is a resolved or self-service outcome that is not already failure demand. Everything else is Unclassified. Word count stands in for handling effort until Genesys AHT is available. These are not P&L figures."
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
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
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
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 5
    col: 4
    width: 4
    height: 4

  - name: value_demand_rate
    title: "Value-demand rate"
    model: voc
    explore: conversation_insights
    type: single_value
    fields: [conversation_insights.value_demand_rate]
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 5
    col: 8
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
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 5
    col: 12
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
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 5
    col: 16
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
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 5
    col: 20
    width: 4
    height: 4

  - name: demand_by_value_chain
    title: "Demand class by value chain"
    model: voc
    explore: conversation_insights
    type: looker_column
    fields:
    - conversation_insights.value_chain_tag
    - conversation_insights.demand_class
    - conversation_insights.count
    pivots: [conversation_insights.demand_class]
    sorts: [conversation_insights.count desc]
    limit: 15
    stacking: normal
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 9
    col: 0
    width: 12
    height: 8

  - name: failure_by_process
    title: "Failure demand by process"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields:
    - conversation_insights.process_dimension
    - conversation_insights.failure_demand_conversations
    - conversation_insights.count
    sorts: [conversation_insights.failure_demand_conversations desc]
    limit: 15
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 9
    col: 12
    width: 12
    height: 8

  - name: product_mentions
    title: "Product mentions"
    model: voc
    explore: product_mentions
    type: looker_bar
    fields: [product_mentions.product, product_mentions.product_role, product_mentions.mention_count]
    pivots: [product_mentions.product_role]
    sorts: [product_mentions.mention_count desc]
    limit: 15
    stacking: normal
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: product_mentions.product
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 17
    col: 0
    width: 24
    height: 8

  - name: value_chain_detail
    title: "Value chain, product, and process"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.value_chain_tag
    - conversation_insights.product_mentioned
    - conversation_insights.process_dimension
    - conversation_insights.count
    - conversation_insights.percent_of_conversations
    - conversation_insights.failure_demand_rate
    - conversation_insights.value_demand_rate
    - conversation_insights.repeat_contact_rate
    - conversation_insights.total_word_count
    - conversation_insights.average_word_count
    - conversation_insights.average_frustration_score
    sorts: [conversation_insights.count desc]
    limit: 500
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      process: conversation_insights.process_dimension
      channel: conversation_insights.channel_inferred
    row: 25
    col: 0
    width: 24
    height: 10
