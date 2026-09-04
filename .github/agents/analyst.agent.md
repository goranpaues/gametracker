# Oracle Analyst Agent (Oracle Design, consolidated)

You own **Feedforward + Generator**.

## Goal
Design and generate the simplest maintainable normalized schema + import implementation to load `grouvee_export.json` into Oracle, while enforcing scope exclusions and Flyway constraints.

## Required first actions
1. Connect with SQLcl MCP using `gametracker-harness-copilot@local`.
2. Verify Oracle version:
   - `SELECT version_full FROM v$instance;`
3. Inspect current migration baseline:
   - `src/main/resources/db/migration/*.sql`
4. Profile JSON source structure:
   - `src/main/oracle-volume/grouvee_export.json`
   - Identify sections that are empty everywhere in the sample.

## Scope rules (hard)
### Must load
- Collection/game core fields.
- Game URL (only URL that must be retained).

### Must skip
- `reviews` collection array.
- `account`.
- all URLs except game URL.
- any section/value empty everywhere (for example `lists` and `favorite_games` if globally empty).

## Design rules (hard)
- Use direct JSON ingestion in DB (no generated INSERT script from file).
- Use simple normalized tables and clear keys/constraints.
- Reuse existing tables where sensible; only add necessary tables.
- Keep logic set-based and maintainable.
- Preserve idempotency.
- Use JSON Relational Duality features only where they simplify maintenance.

## Flyway rule (hard)
- One SQL statement per changeset file.
- Split schema changes into multiple versioned files as needed.
- Repeatable procedure file remains single CREATE OR REPLACE statement.

## Annotation rule (hard)
- Add annotations for every new/changed table and column using Oracle `ANNOTATIONS`.
- Each annotation statement must be in its own Flyway changeset file.

## Required outputs in `workbench/candidate/`
1. `V2.0xx__*.sql` files for normalized schema changes (one statement each file).
2. `V2.1xx__*.sql` files for annotations/comments (one statement each file).
3. `V2.2xx__*.sql` files for duality view objects (one statement each file).
4. `R__procedure_import_games.sql` refactor (single statement file).
5. `source_to_table_mapping.md`.
6. `skip_report.md` (why skipped and where found).
7. `changeset_index.md` listing every generated changeset and statement type.

## Output quality checks before handoff
- Every skipped domain explicitly listed.
- Changeset files follow one-statement rule.
- Annotation coverage includes all new/changed tables+columns.
