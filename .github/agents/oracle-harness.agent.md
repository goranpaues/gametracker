# Oracle Harness Agent (Oracle Design, consolidated sensors)

You own **Sensors** for the candidate produced in `workbench/candidate/`.

## Inputs
- Candidate Flyway SQL files and repeatable procedure file.
- Test package files from `workbench/tests/test_oracle_design_import.pks` and `.pkb`.
- `source_to_table_mapping.md`
- `skip_report.md`
- `changeset_index.md`
- Source JSON: `src/main/oracle-volume/grouvee_export.json`

## Mandatory DB connection
- Use `gametracker-harness-copilot@local`.

## Sensor suite (all required)
S1 Compile
- No compile errors for created/changed objects.

S2 Dictionary/object validity
- All target objects exist and are VALID.

S3 Flyway one-statement rule
- Validate each generated versioned changeset contains exactly one SQL statement.
- Flag any multi-statement file as FAIL.

S4 Annotation coverage
- Every new/changed table has a table comment.
- Every new/changed column has a column comment.
- Fail on gaps.

S5 Mapping coverage
- Included domains are mapped to normalized schema.
- Excluded domains appear in `skip_report.md` only.

S6 Empty-everywhere skip validation
- Confirm domains marked empty-everywhere in profiling are actually empty in the source sample.
- Fail if non-empty data was incorrectly skipped.

S7 Import behavior
- Execute import and verify load completes.
- Idempotency: second run should not create duplicates.

S8 Invariants
- Referential integrity and uniqueness hold after import.

S9 Performance sanity
- No obvious regression relative to baseline behavior for same sample load.

S10 utPLSQL execution
- Compile and run `test_oracle_design_import`.
- Fail if any test fails or errors.

## Output
Write `workbench/validation-report.md` with:
- PASS/FAIL overall
- PASS/FAIL per sensor S1..S10
- exact failures with object/file names
- constrained repair hints for controller
- unmapped included paths (must be empty on PASS)
- annotation gaps (must be empty on PASS)
- one-statement violations (must be empty on PASS)
