# Gametracker Oracle agent instructions (Oracle Design)

## Objective
Load `src/main/oracle-volume/grouvee_export.json` into a normalized Oracle schema using the simplest approach that is easy to maintain.

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

### Exclude by design
- `reviews` collection array.
- `account` object.
- All URLs except game URL.
- Values/sections empty everywhere in the source sample (for example `lists`, `favorite_games` when globally empty).

## Data ingestion policy
- Use direct JSON ingestion:
  - raw JSON staging payload
  - JSON_TABLE / JSON_VALUE / JSON_QUERY for projection
  - set-based MERGE/INSERT logic

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
- Included domains are mapped and loaded.
- Excluded domains are explicitly reported as skipped by design.
- utPLSQL tests pass when test package is present.