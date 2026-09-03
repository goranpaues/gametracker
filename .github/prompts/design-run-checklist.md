# Oracle Design run checklist

1. Open VS Code in [gametracker](C:/Users/GöranPaues/git/gametracker).
2. Open Chat, switch to **Agent** mode.
3. In model picker, choose your desired large-context model explicitly (not Auto).
4. Confirm SQLcl MCP server is available in tools and `gametracker-harness-copilot@local` is configured.
5. Open and run prompt from [start-design-normalized-import.prompt.md](C:/Users/GöranPaues/git/gametracker/.github/prompts/start-design-normalized-import.prompt.md).
6. Ensure the loop runs in this order:
   - Analyst
   - Test Designer
   - Validator
   - Loop repair/retry (up to 8 times)
7. After each loop iteration, check:
   - `workbench/validation-report.md`
   - `workbench/final-report.md` (on completion)
8. To let it auto-run several iterations, include this sentence in your start prompt:
   - "Run fully autonomously without pausing for approval between iterations; stop only on PASS or when max retries is reached."
9. Validate mandatory gates before accepting:
   - one statement per versioned Flyway file
   - annotations complete for new/changed tables and columns
   - skip rules respected (`reviews`, `account`, non-game URLs)
   - empty-everywhere fields skipped only when truly empty
   - idempotent rerun and referential integrity pass
   - utPLSQL suite pass (`S10`)
10. Run utPLSQL suite:
   - compile/install generated test package from `workbench/tests/test_oracle_design_import.pks` and `workbench/tests/test_oracle_design_import.pkb`
   - execute `ut.run('test_oracle_design_import');`
11. Choose the best solution using this order:
    - PASS on all sensors S1..S10
    - no mapping/annotation/changeset violations
    - simplest schema and import logic (fewest new objects while meeting requirements)
    - stable idempotent rerun behavior
12. Move accepted candidate SQL files from `workbench/candidate/` into [db/migration](C:/Users/GöranPaues/git/gametracker/src/main/resources/db/migration/) with final version naming.
