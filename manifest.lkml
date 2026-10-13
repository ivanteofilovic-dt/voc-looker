project_name: "voc"

# Period-over-period measures require the new LookML runtime.
new_lookml_runtime: yes

localization_settings: {
  default_locale: en
  localization_level: permissive
}

# Replace these before validating SQL. Keep the backticks inside the table constants.
constant: BQ_CONNECTION {
  value: "bigquery_voc"
  export: override_optional
}

constant: INSIGHTS_TABLE {
  value: "`your-gcp-project.your_dataset.conversation_insights`"
  export: override_optional
}

constant: DUMP_TABLE {
  value: "`your-gcp-project.your_dataset.conversation_data_dump`"
  export: override_optional
}
