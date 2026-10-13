- dashboard: drivers_and_outcomes
  title: "Drivers and outcomes"
  description: "Drivers, pre-contact actions, outcomes, and agent solutions."
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
  - name: driver
    title: "Driver"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: advanced
      display: popover
    model: voc
    explore: conversation_insights
    field: conversation_insights.driver_trigger
  - name: outcome
    title: "Outcome"
    type: field_filter
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    model: voc
    explore: conversation_insights
    field: conversation_insights.outcome

  elements:
  - name: how_to_read
    type: text
    title_text: "How to read this page"
    body_text: "Driver and pre-contact action come from the enrichment model, not from a joined event history. Agent solution is useful when the model returns a normalized action. Free-text solutions will not group into a stable ranking."
    row: 0
    col: 0
    width: 24
    height: 4

  - name: drivers
    title: "Drivers"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields: [conversation_insights.driver_trigger, conversation_insights.count]
    sorts: [conversation_insights.count desc]
    limit: 15
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      driver: conversation_insights.driver_trigger
      outcome: conversation_insights.outcome
    row: 4
    col: 0
    width: 12
    height: 8

  - name: pre_contact
    title: "Pre-contact actions"
    model: voc
    explore: conversation_insights
    type: looker_bar
    fields: [conversation_insights.pre_contact_action, conversation_insights.count]
    sorts: [conversation_insights.count desc]
    limit: 15
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      driver: conversation_insights.driver_trigger
      outcome: conversation_insights.outcome
    row: 4
    col: 12
    width: 12
    height: 8

  - name: outcomes
    title: "Outcomes"
    model: voc
    explore: conversation_insights
    type: looker_column
    fields: [conversation_insights.outcome, conversation_insights.count]
    sorts: [conversation_insights.outcome]
    limit: 10
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      driver: conversation_insights.driver_trigger
      outcome: conversation_insights.outcome
    row: 12
    col: 0
    width: 8
    height: 8

  - name: agent_solutions
    title: "Agent solutions"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.agent_solution
    - conversation_insights.count
    - conversation_insights.percent_of_conversations
    - conversation_insights.failure_demand_rate
    sorts: [conversation_insights.count desc]
    limit: 20
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      driver: conversation_insights.driver_trigger
      outcome: conversation_insights.outcome
    row: 12
    col: 8
    width: 16
    height: 8

  - name: driver_detail
    title: "Driver and pre-contact"
    model: voc
    explore: conversation_insights
    type: looker_grid
    fields:
    - conversation_insights.driver_trigger
    - conversation_insights.pre_contact_action
    - conversation_insights.count
    - conversation_insights.percent_of_conversations
    - conversation_insights.failure_demand_rate
    - conversation_insights.repeat_contact_rate
    - conversation_insights.average_sentiment_score
    sorts: [conversation_insights.count desc]
    limit: 100
    show_totals: true
    listen:
      date: conversation_insights.conversation_date
      value_chain: conversation_insights.value_chain_tag
      any_product: conversation_insights.any_product
      driver: conversation_insights.driver_trigger
      outcome: conversation_insights.outcome
    row: 20
    col: 0
    width: 24
    height: 9
