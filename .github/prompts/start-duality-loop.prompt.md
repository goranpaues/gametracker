---
agent: agent
description: Start the local closed-loop refactor for import_games using Oracle 26ai duality view pipeline and qwen3-coder:30b.
model: qwen3-coder:30b
---
Use the Orchestrator agent and run the full local loop for gametracker.

Inputs:
- Connection name: gametracker@local
- Objective: refactor import_games to use Oracle JSON Relational Duality features
- Objective: expand the database design so all data from the Grouvee export JSON is persisted in normalized relational tables
- Source format: current Grouvee export JSON with root keys including account and collection[]
- Constraint: do not convert JSON file to SQL INSERT script

Execution requirements:
1. Verify version by running SELECT version_full FROM v$instance.
2. Build feedforward artifacts, including a complete source profile for all root sections and nested structures in the Grouvee export.
3. Generate candidate schema migrations to normalize all relevant source domains, including account, collection, lists, reviews, play log, statuses, and comments when present.
4. Generate candidate duality view and import procedure that map the full source contract into normalized tables.
5. Run harness and auto-repair loop up to 5 iterations.
6. End with ACCEPT only when all sensors pass, including normalized coverage checks.

Report:
- status
- versions and assumptions
- normalized entities created or updated
- source-to-table mapping coverage summary
- files changed
- sensor summary
