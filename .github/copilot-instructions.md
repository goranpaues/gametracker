# Gametracker Oracle agent instructions (Oracle Design)

## Skill usage
- Use relevant Oracle skills in this workspace as input.

## Database/runtime
- Use SQLcl MCP with connection `gametracker-harness-copilot@local`.
- First query in each run:
  - `SELECT version_full FROM v$instance;`
- Target database is Oracle 26ai-compatible.

## Schema/migration policy
- Keep schema changes minimal and normalized.
- Reuse existing tables where practical.
- Keep import procedure deterministic and idempotent.
- **Flyway rule:** one SQL statement per changeset file only.
  - If multiple DDL or ANNOTATIONS statements are needed, split into multiple versioned files.

## Annotation policy
- Add Oracle annotations for all newly created/changed tables and columns.
- Do not use COMMENT ON TABLE / COMMENT ON COLUMN for annotations; use ANNOTATIONS keyword instead. See [official documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/adfns/registering-application-data-usage-database.html#GUID-2DAF069E-0938-40AF-B05B-75AFE71D666C) for guidance.
- Respect Flyway one-statement-per-changeset rule for each annotation statement.

## Validation gates
- All objects compile and are VALID.
- Import is idempotent on re-run.
- Excluded domains are explicitly reported as skipped by design.
- utPLSQL tests pass when test package is present.