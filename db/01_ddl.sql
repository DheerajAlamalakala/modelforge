-- 01_ddl.sql : ModelForge schema (DBMS Lab)
DROP DATABASE IF EXISTS modelforge;
CREATE DATABASE modelforge;
USE modelforge;

CREATE TABLE users (
  user_id    INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(60)  NOT NULL,
  email      VARCHAR(100) NOT NULL UNIQUE,
  role       VARCHAR(20)  NOT NULL DEFAULT 'researcher',
  CONSTRAINT chk_role CHECK (role IN ('admin','researcher','viewer'))
);

CREATE TABLE projects (
  project_id INT AUTO_INCREMENT PRIMARY KEY,
  owner_id   INT NOT NULL,
  title      VARCHAR(100) NOT NULL,
  created_on DATE NOT NULL DEFAULT (CURRENT_DATE),
  FOREIGN KEY (owner_id) REFERENCES users(user_id)
);

CREATE TABLE gpu_nodes (
  node_id   INT AUTO_INCREMENT PRIMARY KEY,
  name      VARCHAR(50) NOT NULL UNIQUE,
  vram_gb   INT NOT NULL CHECK (vram_gb > 0),
  status    VARCHAR(15) NOT NULL DEFAULT 'idle',
  CONSTRAINT chk_node_status CHECK (status IN ('idle','busy','offline'))
);

CREATE TABLE datasets (
  dataset_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id INT NOT NULL,
  name       VARCHAR(80) NOT NULL,
  size_mb    DECIMAL(10,2) NOT NULL CHECK (size_mb >= 0),
  format     VARCHAR(20) DEFAULT 'csv',
  FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE experiments (
  experiment_id INT AUTO_INCREMENT PRIMARY KEY,
  project_id    INT NOT NULL,
  dataset_id    INT,
  title         VARCHAR(100) NOT NULL,
  FOREIGN KEY (project_id) REFERENCES projects(project_id),
  FOREIGN KEY (dataset_id) REFERENCES datasets(dataset_id)
);

CREATE TABLE runs (
  run_id        INT AUTO_INCREMENT PRIMARY KEY,
  experiment_id INT NOT NULL,
  node_id       INT,
  status        VARCHAR(15) NOT NULL DEFAULT 'queued',
  accuracy      DECIMAL(5,4) CHECK (accuracy BETWEEN 0 AND 1),
  loss          DECIMAL(8,4),
  vram_used_gb  INT DEFAULT 0,
  started_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
  ended_at      DATETIME,
  CONSTRAINT chk_run_status CHECK (status IN ('queued','running','done','failed')),
  FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id),
  FOREIGN KEY (node_id) REFERENCES gpu_nodes(node_id)
);

CREATE TABLE metrics (
  metric_id INT AUTO_INCREMENT PRIMARY KEY,
  run_id    INT NOT NULL,
  epoch     INT NOT NULL,
  loss      DECIMAL(8,4),
  accuracy  DECIMAL(5,4) CHECK (accuracy BETWEEN 0 AND 1),
  FOREIGN KEY (run_id) REFERENCES runs(run_id) ON DELETE CASCADE
);

CREATE TABLE audit_log (
  log_id      INT AUTO_INCREMENT PRIMARY KEY,
  run_id      INT NOT NULL,
  old_status  VARCHAR(15),
  new_status  VARCHAR(15),
  changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ALTER examples
ALTER TABLE users ADD COLUMN joined_on DATE DEFAULT (CURRENT_DATE);
ALTER TABLE users MODIFY COLUMN name VARCHAR(80) NOT NULL;
ALTER TABLE datasets ADD CONSTRAINT chk_format CHECK (format IN ('csv','json','parquet','images'));
ALTER TABLE users RENAME COLUMN joined_on TO registered_on;
ALTER TABLE users DROP COLUMN registered_on;

-- Copy table (CREATE TABLE ... AS SELECT), then TRUNCATE and DROP the copy
CREATE TABLE gpu_nodes_backup AS SELECT * FROM gpu_nodes;
TRUNCATE TABLE gpu_nodes_backup;
DROP TABLE gpu_nodes_backup;