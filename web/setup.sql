-- Safe to run against an existing ModelForge database; it skips the column if present.
USE modelforge;
SET @mf_auth_column_sql = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'password_hash') = 0,
  'ALTER TABLE users ADD COLUMN password_hash VARCHAR(255) NULL AFTER email',
  'SELECT ''password_hash already exists'' AS message'
);
PREPARE mf_auth_stmt FROM @mf_auth_column_sql;
EXECUTE mf_auth_stmt;
DEALLOCATE PREPARE mf_auth_stmt;

-- Add optional links for dataset provenance (safe to rerun).
SET @mf_source_column_sql = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = DATABASE() AND table_name = 'datasets' AND column_name = 'source_url') = 0,
  'ALTER TABLE datasets ADD COLUMN source_url VARCHAR(500) NULL AFTER format',
  'SELECT ''source_url already exists'' AS message'
);
PREPARE mf_source_stmt FROM @mf_source_column_sql;
EXECUTE mf_source_stmt;
DEALLOCATE PREPARE mf_source_stmt;

-- Store user notes about a run (safe to rerun).
SET @mf_run_notes_sql = IF(
  (SELECT COUNT(*) FROM information_schema.columns
   WHERE table_schema = DATABASE() AND table_name = 'runs' AND column_name = 'notes') = 0,
  'ALTER TABLE runs ADD COLUMN notes VARCHAR(500) NULL AFTER vram_used_gb',
  'SELECT ''runs.notes already exists'' AS message'
);
PREPARE mf_run_notes_stmt FROM @mf_run_notes_sql;
EXECUTE mf_run_notes_stmt;
DEALLOCATE PREPARE mf_run_notes_stmt;