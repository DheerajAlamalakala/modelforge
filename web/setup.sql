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
