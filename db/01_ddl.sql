-- 01_ddl.sql : ModelForge database schema (MySQL 8.0)
-- Run this file in MySQL Workbench to create a clean lab database.
-- The DROP DATABASE is intentionally destructive; it resets only the
-- dedicated "modelforge" lab database so the script can be rerun.

DROP DATABASE IF EXISTS modelforge;
CREATE DATABASE modelforge
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE modelforge;

-- 1. Users
CREATE TABLE users (
  user_id    INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(80)  NOT NULL,
  email      VARCHAR(120) NOT NULL UNIQUE,
  role       VARCHAR(20)  NOT NULL DEFAULT 'researcher',
  CONSTRAINT chk_users_role CHECK (role IN ('admin','researcher','viewer'))
) ENGINE=InnoDB;

-- 2. Projects
CREATE TABLE projects (
  project_id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id   INT NOT NULL,
  title      VARCHAR(120) NOT NULL,
  created_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  CONSTRAINT fk_projects_owner FOREIGN KEY (owner_id)
    REFERENCES users(user_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. Datasets
CREATE TABLE datasets (
  dataset_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT NOT NULL,
  name       VARCHAR(120) NOT NULL,
  size_mb    DECIMAL(12,2) NOT NULL CHECK (size_mb >= 0),
  format     VARCHAR(20) NOT NULL DEFAULT 'csv',
  CONSTRAINT chk_datasets_format CHECK (format IN ('csv','json','parquet','images')),
  CONSTRAINT fk_datasets_project FOREIGN KEY (project_id)
    REFERENCES projects(project_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. GPU nodes
CREATE TABLE gpu_nodes (
  node_id  INT AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(60) NOT NULL UNIQUE,
  vram_gb  INT NOT NULL CHECK (vram_gb > 0),
  status   VARCHAR(15) NOT NULL DEFAULT 'idle',
  CONSTRAINT chk_gpu_nodes_status CHECK (status IN ('idle','busy','offline'))
) ENGINE=InnoDB;

-- 5. Experiments
CREATE TABLE experiments (
  experiment_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id    INT NOT NULL,
  dataset_id    INT,
  title         VARCHAR(140) NOT NULL,
  CONSTRAINT fk_experiments_project FOREIGN KEY (project_id)
    REFERENCES projects(project_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_experiments_dataset FOREIGN KEY (dataset_id)
    REFERENCES datasets(dataset_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- 6. Runs
CREATE TABLE runs (
  run_id        INT AUTO_INCREMENT PRIMARY KEY,
  experiment_id INT NOT NULL,
  node_id       INT,
  status        VARCHAR(15) NOT NULL DEFAULT 'queued',
  accuracy      DECIMAL(5,4),
  loss          DECIMAL(8,4),
  vram_used_gb  DECIMAL(6,2) NOT NULL DEFAULT 0,
  started_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at      DATETIME,
  CONSTRAINT chk_runs_status CHECK (status IN ('queued','running','done','failed')),
  CONSTRAINT chk_runs_accuracy CHECK (accuracy IS NULL OR accuracy BETWEEN 0 AND 1),
  CONSTRAINT chk_runs_loss CHECK (loss IS NULL OR loss >= 0),
  CONSTRAINT chk_runs_vram CHECK (vram_used_gb >= 0),
  CONSTRAINT fk_runs_experiment FOREIGN KEY (experiment_id)
    REFERENCES experiments(experiment_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_runs_node FOREIGN KEY (node_id)
    REFERENCES gpu_nodes(node_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- 7. Per-epoch metrics
CREATE TABLE metrics (
  metric_id INT AUTO_INCREMENT PRIMARY KEY,
  run_id    INT NOT NULL,
  epoch     INT NOT NULL CHECK (epoch > 0),
  loss      DECIMAL(8,4),
  accuracy  DECIMAL(5,4),
  CONSTRAINT chk_metrics_loss CHECK (loss IS NULL OR loss >= 0),
  CONSTRAINT chk_metrics_accuracy CHECK (accuracy IS NULL OR accuracy BETWEEN 0 AND 1),
  CONSTRAINT uq_metrics_run_epoch UNIQUE (run_id, epoch),
  CONSTRAINT fk_metrics_run FOREIGN KEY (run_id)
    REFERENCES runs(run_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. Status audit trail. The trigger is added in 05_plsql.sql.
CREATE TABLE audit_log (
  log_id      INT AUTO_INCREMENT PRIMARY KEY,
  run_id      INT NOT NULL,
  old_status  VARCHAR(15) NOT NULL,
  new_status  VARCHAR(15) NOT NULL,
  changed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_audit_run FOREIGN KEY (run_id)
    REFERENCES runs(run_id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ALTER examples: add, modify, rename, then remove a temporary column.
ALTER TABLE users ADD COLUMN lab_note VARCHAR(40) NULL;
ALTER TABLE users MODIFY COLUMN name VARCHAR(100) NOT NULL;
ALTER TABLE users RENAME COLUMN lab_note TO temporary_note;
ALTER TABLE users DROP COLUMN temporary_note;

-- TRUNCATE and DROP examples use a disposable table and do not affect lab data.
CREATE TABLE ddl_demo (
  demo_id INT PRIMARY KEY,
  note VARCHAR(40)
) ENGINE=InnoDB;
INSERT INTO ddl_demo VALUES (1, 'truncate example');
TRUNCATE TABLE ddl_demo;
DROP TABLE ddl_demo;

-- Optional inspection:
-- SHOW TABLES;
-- DESCRIBE runs;
-- SHOW CREATE TABLE runs;

