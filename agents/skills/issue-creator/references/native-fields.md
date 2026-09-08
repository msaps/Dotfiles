# Native Effort and Priority fields

Use this procedure only when at least one confident Effort or Priority value should be applied.

1. Resolve the repository owner and name with `gh repo view`.
2. Query `gh api /orgs/<owner>/issue-fields` and find the IDs for fields named `Effort` and `Priority`.
3. If the owner is not an organization, the endpoint is unavailable, or either field does not exist, skip that field and report the limitation.
4. For each created issue, send only the values that exist and were selected:

```json
{
  "issue_field_values": [
    {"field_id": 123, "value": "High"},
    {"field_id": 456, "value": "Medium"}
  ]
}
```

POST this JSON with a JSON-aware input method to `repos/<owner>/<repo>/issues/<number>/issue-field-values`. The key is `field_id`, and `value` is the capitalized option name. Never interpolate generated JSON or issue content into shell source.

Failure to set an optional field must not delete or recreate an issue. Return the issue URL and state which field could not be applied.
