-- 03_queries.sql : DQL, functions, joins, subqueries (ModelForge)
USE modelforge;

-- Basic SELECT: ORDER BY, DISTINCT, BETWEEN, IN, LIKE, aliases
SELECT * FROM runs ORDER BY accuracy DESC;
SELECT DISTINCT format FROM datasets;
SELECT run_id, accuracy FROM runs WHERE accuracy BETWEEN 0.85 AND 0.95;
SELECT name, role FROM users WHERE role IN ('admin','researcher');
SELECT title FROM experiments WHERE title LIKE '%U-Net%';
SELECT title FROM experiments WHERE title LIKE '%ResNet%' OR title LIKE 'B%';
SELECT name, vram_gb, vram_gb * 1024 AS vram_mb FROM gpu_nodes;

-- Aggregates, GROUP BY, HAVING
SELECT COUNT(*) AS total_runs, AVG(accuracy) AS avg_acc,
       MAX(accuracy) AS best_acc, MIN(accuracy) AS worst_acc,
       SUM(vram_used_gb) AS total_vram
FROM runs WHERE status = 'done';
SELECT status, COUNT(*) AS n FROM runs GROUP BY status;
SELECT node_id, ROUND(AVG(accuracy), 3) AS avg_acc, COUNT(*) AS runs_done
FROM runs
WHERE status = 'done' AND node_id IS NOT NULL
GROUP BY node_id
HAVING COUNT(*) >= 2;

-- String functions
SELECT CONCAT(UPPER(name), ' <', LOWER(email), '>') AS contact FROM users;
SELECT name, SUBSTRING(name, 1, 3) AS short_name, LENGTH(name) AS byte_length FROM users;

-- Date functions
SELECT title, created_on,
       ADDDATE(created_on, INTERVAL 3 MONTH) AS review_date,
       LAST_DAY(created_on) AS month_end,
       DATE_FORMAT(created_on, '%d-%b-%Y') AS pretty_date
FROM projects;
SELECT run_id, TIMESTAMPDIFF(MINUTE, started_at, ended_at) AS minutes_taken,
       ROUND(TIMESTAMPDIFF(MINUTE, started_at, ended_at) / 60, 2) AS hours_taken
FROM runs WHERE ended_at IS NOT NULL;

-- NULL handling
SELECT run_id, status, IFNULL(accuracy, 0) AS accuracy_or_zero,
       COALESCE(node_id, -1) AS node_or_none
FROM runs;

-- Subqueries: IN
SELECT title FROM projects
WHERE project_id IN (SELECT project_id FROM datasets WHERE format = 'images');

-- ANY / ALL
SELECT run_id, accuracy FROM runs
WHERE accuracy > ALL (
  SELECT accuracy FROM runs WHERE node_id = 1 AND accuracy IS NOT NULL
);
SELECT run_id, accuracy FROM runs
WHERE accuracy > ANY (
  SELECT accuracy FROM runs WHERE node_id = 3 AND accuracy IS NOT NULL
);

-- Third-highest distinct accuracy
SELECT MAX(accuracy) AS third_highest
FROM runs
WHERE accuracy < (
  SELECT MAX(accuracy) FROM runs
  WHERE accuracy < (SELECT MAX(accuracy) FROM runs WHERE accuracy IS NOT NULL)
);

-- Correlated subquery: runs better than their node's average
SELECT r.run_id, r.node_id, r.accuracy
FROM runs r
WHERE r.accuracy > (
  SELECT AVG(r2.accuracy) FROM runs r2 WHERE r2.node_id = r.node_id
);

-- Dataset provenance: source URL links for reproducibility
SELECT dataset_id, name, format, source_url
FROM datasets
WHERE source_url IS NOT NULL
ORDER BY name;

-- Run lifecycle with per-epoch loss and accuracy (running and completed runs)
SELECT r.run_id, e.title AS experiment, r.status, r.started_at, r.ended_at,
       m.epoch, m.loss AS epoch_loss, m.accuracy AS epoch_accuracy
FROM runs r
JOIN experiments e ON e.experiment_id = r.experiment_id
LEFT JOIN metrics m ON m.run_id = r.run_id
ORDER BY r.run_id, m.epoch;
-- Joins
SELECT p.title AS project, e.title AS experiment, r.run_id,
       r.accuracy, g.name AS gpu
FROM projects p
JOIN experiments e ON e.project_id = p.project_id
JOIN runs r        ON r.experiment_id = e.experiment_id
JOIN gpu_nodes g   ON g.node_id = r.node_id
ORDER BY r.accuracy DESC;

-- LEFT OUTER JOIN includes users with no projects
SELECT u.name, p.title
FROM users u LEFT JOIN projects p ON p.owner_id = u.user_id;

-- FULL OUTER JOIN equivalent in MySQL
SELECT g.name AS gpu, r.run_id
FROM gpu_nodes g LEFT JOIN runs r ON r.node_id = g.node_id
UNION ALL
SELECT g.name AS gpu, r.run_id
FROM gpu_nodes g RIGHT JOIN runs r ON r.node_id = g.node_id
WHERE g.node_id IS NULL;

-- SELF JOIN: user pairs with the same role
SELECT a.name AS user1, b.name AS user2, a.role
FROM users a
JOIN users b ON a.role = b.role AND a.user_id < b.user_id;

-- Set operators: UNION
SELECT owner_id AS user_id FROM projects
UNION
SELECT user_id FROM users WHERE role = 'admin';

-- INTERSECT / EXCEPT require MySQL 8.0.31+.
SELECT owner_id AS user_id FROM projects
INTERSECT
SELECT user_id FROM users WHERE role = 'researcher';

SELECT user_id FROM users
EXCEPT
SELECT owner_id FROM projects;

-- Portable INTERSECT equivalent for older MySQL 8.0 versions:
-- SELECT DISTINCT p.owner_id AS user_id
-- FROM projects p JOIN users u ON u.user_id = p.owner_id
-- WHERE u.role = 'researcher';

-- Portable EXCEPT equivalent for older MySQL 8.0 versions:
-- SELECT u.user_id FROM users u
-- WHERE NOT EXISTS (SELECT 1 FROM projects p WHERE p.owner_id = u.user_id);