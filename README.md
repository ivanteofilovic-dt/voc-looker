# Voice of the Customer

Looker project for the enriched conversation table. Each row is one enriched conversation. Dashboards count those rows. They do not count unique customers, and they do not count the full conversation dump.

## Connect it

In `manifest.lkml`, set:

- `BQ_CONNECTION` to the Looker BigQuery connection name
- `INSIGHTS_TABLE` to the enriched table, with backticks, for example `` `my-project.voc.conversation_insights` ``
- `DUMP_TABLE` to the conversation dump, same format

The dump is used only for an all-time row count on the data-quality dashboard. Transcript columns are not modeled.

In Looker Admin, create a string user attribute named `voc_can_view_summaries`. Leave the default empty. Set the value `yes` only for roles that may read conversation summaries. Summaries stay hidden until that value is set. If validation complains about the attribute before an admin can create it, remove `required_access_grants` from `conversation_summary` and put it back before business users get access.

Period comparison needs Looker with period-over-period measures (Looker 25.6 or later on BigQuery) and the new LookML runtime. The manifest turns that runtime on. Weeks start on Monday.

## Dashboards

- **VoC overview** — volume, sentiment, top intents, value chain, and freshness
- **Intent trends** — volume, share, month and year comparison, primary and secondary intents
- **Value chain and demand** — value chain, product, and process, with the demand proxy
- **Drivers and outcomes** — driver, pre-contact action, outcome, and agent solution
- **Data quality and coverage** — enriched rows versus the dump, field coverage, and score checks

The intent filter on Intent trends changes the scorecards and the trend. It does not change the intent-mix table, so that table stays a share of the other filters.

## How to read the numbers

**Failure demand** is unresolved, escalated, or a frustration score of 0.6 or higher. **Value demand** is resolved or self-service and not already failure demand. Anything else is Unclassified. This is a proxy, not a P&L.

**Word count** is transcript length. It is not Genesys handling time.

**Repeat-contact candidate** is a flag from the enrichment model. It is not a repeat rate per customer.

**Channel (inferred)** comes from the model. It is not the Genesys channel code.

**Any intent** and **Any product** match the primary value or any secondary value and still count the conversation once. The Intent mentions and Product mentions explores count each mention separately. Use Conversations there when a conversation must count once.

High confidence means a categorization score of 0.8 or higher. Use that cut before treating a slice as decision-grade. Missing scores count against the high-confidence rate. Averages skip missing scores.

Category values stay in the language written by the enrichment model. Labels, dashboard text, and descriptions follow the Looker user locale: English by default, Swedish for locale `sv_SE` or `sv`.

## Explores

| Explore | Grain |
| --- | --- |
| Conversations | One enriched conversation |
| Intent mentions | Primary intent, plus each other distinct intent |
| Product mentions | Primary product, plus each other distinct product |
| Enrichment coverage | One all-time row for both tables |
