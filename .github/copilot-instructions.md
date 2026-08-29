# Gametracker Local Oracle Agent Instructions

Scope: local-only closed-loop refactor and validation for import_games using Oracle 26ai JSON Relational Duality Views.

## Operating Rules
- Keep all work local.
- Use sqlcl MCP tools and the saved Oracle connection name gametracker@local.
- Do not use cloud services or external APIs for data processing.
- Prefer set-based SQL and PL/SQL over row-by-row loops.
- Preserve backward compatibility of public procedure entry points unless explicitly changed.

## Target Architecture
The system runs in five layers:
1. FEEDFORWARD
2. GENERATOR
3. SENSORS
4. CONTROLLER
5. ACTUATOR

## Required Artifacts
Write all loop artifacts under workbench/:
- workbench/schema-facts.md
- workbench/source-profile.md
- workbench/tests/test_import_games.sql
- workbench/candidate/V2.1__game_duality_view.sql
- workbench/candidate/R__procedure_import_games.sql
- workbench/validation-report.md
- workbench/status.md

## Oracle Skill References
Use these references when generating SQL:
- skills/db/appdev/json-in-oracle.md
- skills/db/agent/schema-discovery.md
- skills/db/agent/idempotency-patterns.md
- skills/db/agent/safe-dml-patterns.md
- skills/db/agent/destructive-op-guards.md
- skills/db/sqlcl/sqlcl-mcp-server.md

## Connection Boot Step
At start of database work:
1. List available connections.
2. Connect to gametracker@local.
3. Run: SELECT version_full FROM v$instance;
4. Record version in schema-facts.md.

## Safety and Acceptance
- Reject unsafe destructive SQL without explicit guardrails.
- Validate compile status, dictionary state, tests, invariants, transaction behavior, security, and performance.
- Accept only when all sensors pass.
