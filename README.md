# ModelForge

A local ML experiment tracker built for DBMS Lab (MySQL) and Scripting Languages Lab (PHP/JavaScript). A Java Swing extension is planned for the Java Programming Lab.

## Database (DBMS Lab)

Schema: users, projects, datasets, gpu_nodes, experiments, runs, metrics, audit_log.

| File | Contents |
|---|---|
| db/01_ddl.sql | Eight tables, constraints, ALTER, CTAS, TRUNCATE, and DROP examples |
| db/02_dml.sql | 15 sample rows per table, plus INSERT, UPDATE, DELETE examples |
| db/03_queries.sql | SELECT, aggregates, functions, joins, subqueries, and set operators |
| db/04_views_tcl.sql | Updatable and read-only views, CHECK OPTION, transactions and savepoints |
| db/05_plsql.sql | Triggers, parameterized CRUD procedures, function, cursor, handlers, and SIGNAL |

## Syllabus coverage checklist

| Syllabus item | File / section |
|---|---|
| CREATE, PK, FK, CHECK, NOT NULL, DEFAULT | 01_ddl.sql table definitions |
| ALTER, CREATE TABLE AS SELECT, TRUNCATE, DROP | 01_ddl.sql DDL examples |
| INSERT, UPDATE, DELETE | 02_dml.sql |
| ORDER BY, DISTINCT, BETWEEN, IN, LIKE, aliases | 03_queries.sql Basic SELECT |
| COUNT, SUM, AVG, MAX, MIN, GROUP BY, HAVING | 03_queries.sql Aggregates |
| String, date, and NULL functions | 03_queries.sql Function sections |
| IN, ANY, ALL, third-highest subqueries | 03_queries.sql Subqueries |
| LEFT/FULL OUTER join equivalent and self join | 03_queries.sql Joins |
| UNION, INTERSECT, EXCEPT | 03_queries.sql Set operators (portable equivalents included) |
| Views and WITH CHECK OPTION | 04_views_tcl.sql Views |
| START TRANSACTION, SAVEPOINT, ROLLBACK, COMMIT | 04_views_tcl.sql TCL |
| Status audit and VRAM guard triggers | 05_plsql.sql trigger sections |
| Parameterized CRUD procedures and function | 05_plsql.sql procedure/function sections |
| Cursor | 05_plsql.sql cursor section |
| Exception handlers and SIGNAL | 05_plsql.sql exception section |

## Setup

Requires MySQL 8.0. In MySQL Workbench, run these files in order:

1. db/01_ddl.sql
2. db/02_dml.sql
3. db/03_queries.sql
4. db/04_views_tcl.sql
5. db/05_plsql.sql

The DDL script drops and recreates the dedicated modelforge database for a clean setup. The quota violation and view CHECK OPTION errors are commented examples; run them individually when demonstrating those errors.

## Web portal (SL Lab)

The PHP app uses the same eight-table modelforge database. It includes registration/login with password hashing, a 20-minute idle session timeout, a visit cookie, project and dataset forms, batch experiment insertion with explode(), jQuery UI autocomplete (with a local datalist fallback), and a project dropdown that loads runs through AJAX. The XML catalog is at web/public/catalog/datasets.xml and uses its sibling DTD and XSLT files.

Requires PHP 8.1+ with PDO MySQL enabled. Copy web/config.example.php to web/config.local.php and enter the local MySQL credentials there; config.local.php is ignored by Git. For an existing database created before password_hash was added, run web/setup.sql once in Workbench. A fresh database created with the current db/01_ddl.sql already has that column.

From the repository root, start the local server with:

    php -S 127.0.0.1:8000 -t web/public

Then open http://127.0.0.1:8000, register an account, add a project and dataset, and use the batch experiment form. jQuery UI is loaded from its CDN; the autocomplete degrades to a native datalist if the CDN is unavailable.

## Submission checklist

- [x] Schema relationship diagram exported to `db/eer_diagram.png` and `db/eer_diagram.pdf`.
- [x] Full MySQL snapshot saved as `db/modelforge_dump.sql` (includes routines and triggers).
- [ ] Add Workbench screenshots of the queries and demonstrations to `db/screenshots/` if screenshots are required by the lab rubric.
- [x] Run all five scripts in order on an isolated temporary MySQL 8.0 database; each completed successfully. The seed script reported 15 rows in each table, and the final schema contained 4 views, 3 triggers, and 8 routines.

## Project status

- [x] DBMS database layer (schema, sample data, queries, views, TCL, stored programs, diagram, dump, and isolated clean-run verification)
- [x] SL PHP/JavaScript portal (registration/login, sessions, forms, XML catalog, autocomplete, project run explorer; live localhost login and API verified)
- [ ] Java desktop app (outside the DBMS and SL deliverables)
