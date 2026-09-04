# Oracle Design test cases (utPLSQL requirements)

Use these test cases in utPLSQL for the Oracle Design loop.

## Preconditions
- Database connection: `gametracker-harness-copilot@local`
- Source file staged for import: `src/main/oracle-volume/grouvee_export.json`
- Candidate migrations and repeatable procedure applied.

## Test execution
- Before running utPLSQL, clear `GAMETRACKER.TEST_ORACLE_DESIGN_IMPORT_OUTPUT`.
- Use `workbench/tests/run_test_oracle_design_import.sql`, which clears the table and stores only the latest run.

## Test case matrix

### OD-TC-001 Version verification
- Requirement: Environment is Oracle 26ai-compatible.
- Check: `SELECT version_full FROM v$instance`.
- Pass: version indicates 26ai family.

### OD-TC-002 Compile validity
- Requirement: All created/changed objects compile and are VALID.
- Check: `all_objects` + `all_errors`.
- Pass: no relevant invalid objects, no compile errors.

### OD-TC-003 Direct JSON ingestion path
- Requirement: Import uses raw JSON staging + SQL JSON operators, not generated INSERT scripts.
- Check: inspect repeatable procedure source.
- Pass: procedure references JSON_TABLE/JSON_VALUE/JSON_QUERY (or equivalent) and no embedded generated INSERT data.

### OD-TC-004 One statement per Flyway versioned changeset
- Requirement: exactly one SQL statement per versioned changeset.
- Check: generated `V*.sql` files.
- Pass: each file contains exactly one statement.

### OD-TC-005 Table/column annotations exist
- Requirement: Oracle annotations added for all new/changed tables and columns.
- Check: data dictionary comments views for target objects.
- Pass: no missing table comments and no missing column comments.

### OD-TC-006 Skip reviews
- Requirement: reviews array skipped by design.
- Check: no review target table created/loaded; skip report includes reviews.
- Pass: skipped and documented.

### OD-TC-007 Skip account
- Requirement: account object skipped by design.
- Check: no account target table created/loaded; skip report includes account.
- Pass: skipped and documented.

### OD-TC-008 Skip non-game URLs
- Requirement: only game URL kept.
- Check: mapping shows non-game URLs excluded; no persisted non-game URL columns populated.
- Pass: non-game URLs absent from persisted model.

### OD-TC-009 Skip globally-empty sections
- Requirement: empty-everywhere sections (e.g. lists, favorite_games) are skipped.
- Check: source profiler evidence + mapping/skip report.
- Pass: only truly-empty sections are skipped.

### OD-TC-010 Idempotent import rerun
- Requirement: running import twice does not duplicate logical entities.
- Check: capture key counts before/after two consecutive runs.
- Pass: second run produces no duplicate growth on natural keys.

### OD-TC-011 Referential integrity
- Requirement: normalized schema relationships remain consistent.
- Check: anti-joins and FK validity across new/changed tables.
- Pass: no orphan references.

### OD-TC-012 Performance sanity
- Requirement: no obvious regression for same sample load.
- Check: elapsed import runtime vs baseline.
- Pass: within agreed sanity threshold.

## Suggested utPLSQL package structure
- Package name: `test_oracle_design_import`
- Procedures:
  - `test_compile_validity`
  - `test_one_statement_changesets`
  - `test_annotations_complete`
  - `test_skips_respected`
  - `test_empty_everywhere_skip`
  - `test_idempotent_rerun`
  - `test_referential_integrity`
