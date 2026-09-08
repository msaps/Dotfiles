# Automatic mode

Use this mode only when `--auto` is supplied by the invoking workflow. Do not ask questions or infer missing required fields.

## Fields

Every issue requires:

- `--type bug|task|feature`
- `--title "<title>"`

A bug also requires `--problem`, `--fix`, and `--requirements`. A task or feature requires `--overview`, `--goal`, and `--requirements`.

Optional fields are `--effort low|medium|high`, `--priority low|medium|high|urgent`, and `--subissues '<JSON array>'`.

When `--subissues` is present, each array item follows the same schema as the top level except that it cannot contain `--auto` or nested `--subissues`. Requirements must be a non-empty string list. Example:

```json
[
  {
    "type": "task",
    "title": "Add the widget migration",
    "overview": "Persist widgets before exposing them through the API.",
    "goal": "Create the production-safe widgets table.",
    "requirements": ["Add forward and rollback migrations", "Cover migration validation"],
    "effort": "low",
    "priority": "medium"
  }
]
```

## Validation

Validate the parent and every child before creating anything. On failure, create no issues and return one of:

```text
[issue-creator] Auto mode error: missing required fields: <fields>
[issue-creator] Auto mode error: invalid --subissues entry <index>: <reason>
```

After validation, create the parent and children in array order without confirmation. Apply only explicitly supplied Effort and Priority values, then return all URLs.
