# Gametracker Oracle agent instructions (Oracle Design)

## Skill usage
- Use relevant Oracle skills in this workspace as input.

## Database/runtime
- Use SQLcl MCP with connection `gametracker-harness-copilot@local`.
- First query in each run:
  - `SELECT version_full FROM v$instance;`
- Target database is Oracle 26ai-compatible.

## Include/exclude scope
### Include
- Collection/game data needed for normalized tracking.
- Game URL only (from URL fields).
- Other sections only when they contain non-empty values and add clear business value.

## Schema/migration policy
- Keep schema changes minimal and normalized.
- Reuse existing tables where practical.
- Keep import procedure deterministic and idempotent.
- **Flyway rule:** one SQL statement per changeset file only.
  - If multiple DDL or ANNOTATIONS statements are needed, split into multiple versioned files.

## Annotation policy
- Add Oracle annotations for all newly created/changed tables and columns.
- Implement with `ANNOTATIONS`.
- Respect Flyway one-statement-per-changeset rule for each comment statement.

## Validation gates
- All objects compile and are VALID.
- Import is idempotent on re-run.
- Excluded domains are explicitly reported as skipped by design.
- utPLSQL tests pass when test package is present.