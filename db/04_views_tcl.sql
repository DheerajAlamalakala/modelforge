-- 04_views_tcl.sql : Views and TCL (ModelForge)
USE modelforge;

-- Simple updatable view
CREATE OR REPLACE VIEW v_done_runs AS
SELECT run_id, experiment_id, node_id, status, accuracy, loss
FROM runs
WHERE status = 'done';

-- WITH CHECK OPTION: updates must keep accuracy >= 0.85
CREATE OR REPLACE VIEW v_high_accuracy_runs AS
SELECT run_id, experiment_id, node_id, status, accuracy, loss
FROM runs
WHERE accuracy >= 0.85
WITH CHECK OPTION;

-- Successful update demo, rolled back to preserve seed data
START TRANSACTION;
UPDATE v_high_accuracy_runs SET loss = 0.2800 WHERE run_id = 3;
ROLLBACK;

-- Expected-error demo; run separately to see CHECK OPTION reject 0.50:
-- UPDATE v_high_accuracy_runs SET accuracy = 0.50 WHERE run_id = 3;

-- Join and aggregate views are read-only
CREATE OR REPLACE VIEW v_run_report AS
SELECT p.title AS project, e.title AS experiment, g.name AS gpu,
       r.status, r.accuracy, r.loss
FROM runs r
JOIN experiments e ON e.experiment_id = r.experiment_id
JOIN projects p ON p.project_id = e.project_id
LEFT JOIN gpu_nodes g ON g.node_id = r.node_id;

CREATE OR REPLACE VIEW v_project_summary AS
SELECT p.title, COUNT(r.run_id) AS total_runs, MAX(r.accuracy) AS best_accuracy
FROM projects p
LEFT JOIN experiments e ON e.project_id = p.project_id
LEFT JOIN runs r ON r.experiment_id = e.experiment_id
GROUP BY p.project_id, p.title;

SELECT * FROM v_run_report;
SELECT * FROM v_project_summary;

-- Expected-error demo; run separately because this view is not updatable:
-- UPDATE v_project_summary SET total_runs = 0;

-- TCL: transaction, savepoints, rollback and commit
SELECT @@autocommit;

START TRANSACTION;
UPDATE gpu_nodes SET status = 'busy' WHERE node_id = 3;
SAVEPOINT after_node_busy;

INSERT INTO runs (experiment_id, node_id, status, vram_used_gb)
VALUES (6, 3, 'running', 12);
SAVEPOINT after_new_run;

DELETE FROM metrics WHERE run_id = 8; -- temporary delete
SELECT COUNT(*) AS metrics_after_delete FROM metrics;
ROLLBACK TO after_new_run;
SELECT COUNT(*) AS metrics_restored FROM metrics;

ROLLBACK TO after_node_busy; -- removes the inserted run
SELECT COUNT(*) AS runs_back_to_seed_count FROM runs;
COMMIT; -- keeps the node update

SELECT node_id, status FROM gpu_nodes WHERE node_id = 3;

-- Full rollback demo
START TRANSACTION;
UPDATE users SET role = 'viewer' WHERE user_id = 2;
ROLLBACK;
SELECT role FROM users WHERE user_id = 2;

-- Reset node 3 for later labs
UPDATE gpu_nodes SET status = 'idle' WHERE node_id = 3;

