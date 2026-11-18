# ModelForge

A local ML experiment tracker built across three lab courses: a MySQL database (DBMS Lab), a PHP/JavaScript web portal (Scripting Languages Lab), and a Java Swing desktop app (Java Programming Lab).

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

## Submission checklist

- [ ] Reverse-engineer modelforge in Workbench and export the EER diagram.
- [ ] Save a database dump as db/modelforge_dump.sql.
- [ ] Save query and demonstration screenshots in db/screenshots/.
- [ ] Run all five scripts against a fresh database and confirm expected row counts and objects.

## Project status

- [ ] Database layer (SQL scripts and seed data complete; clean run pending)
- [ ] Web portal
- [ ] Java desktop app