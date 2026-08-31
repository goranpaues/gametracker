# Start Oracle Design loop (large context, 4 consolidated agents)

Run the Oracle Design closed-loop workflow for this repository.

## Mandatory runtime selections
- Agent mode.
- Model: latest large-context Copilot model (not Auto if manual selection is required by user preference).

## Database
- Use SQLcl MCP connection `gametracker-harness-copilot@local`.
- First query: `SELECT version_full FROM v$instance;`

## Target
Load `src/main/oracle-volume/grouvee_export.json` into normalized schema design with the simplest maintainable approach.

## Inclusion/exclusion rules
Include:
- Collection/game core data.
- Game URL only.
- Other domains only if non-empty and useful.

Exclude:
- `reviews` array.
- `account`.
- non-game URLs.
- values empty everywhere (e.g., `lists`, `favorite_games` if globally empty).

## Hard constraints
1. Flyway changesets must have exactly one SQL statement per file.
2. Do not use COMMENT ON TABLE / COMMENT ON COLUMN for annotations; use ANNOTATIONS keyword instead. See https://oracle-base.com/articles/23/annotations-23 for guidance.
3. Use SurrogateKey, UI_Display and Description ANNOTATIONS where it makes sense to have them. Example: ID NUMBER ANNOTATIONS (SurrogateKey, UI_Display 'Game ID', Description 'Primary key for the games table').
4. Ensure all mandatory columns have appropriate ANNOTATIONS.

## Execution order (explicit workspace agents)
Explicitly invoke these workspace agents from `.github/agents/` in this exact order:
1. `oracle-analyst` produces candidate files in `workbench/candidate/`.
2. `oracle-test-designer` produces `workbench/tests/` utPLSQL package and test matrix.
3. `oracle-harness` validates and writes `workbench/validation-report.md`.
4. `oracle-loop` repairs and reruns until PASS or max 8 retries.
5. Produce `workbench/final-report.md`.

## Acceptance
Accept only if sensors pass, one-statement rule passes, annotation coverage passes, utPLSQL passes, included mapping is complete, and excluded domains match scope rules.
