-- 05_plsql.sql : Triggers, procedures, function, cursor, exceptions (ModelForge)
-- Execute the CREATE blocks individually in MySQL Workbench if preferred.
USE modelforge;

DELIMITER $$

-- Status audit trigger (stores old and new values)
DROP TRIGGER IF EXISTS trg_runs_audit$$
CREATE TRIGGER trg_runs_audit
AFTER UPDATE ON runs
FOR EACH ROW
BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO audit_log (run_id, old_status, new_status)
    VALUES (OLD.run_id, OLD.status, NEW.status);
  END IF;
END$$

-- VRAM quota triggers (custom SQLSTATE 45000)
DROP TRIGGER IF EXISTS trg_runs_vram_ins$$
CREATE TRIGGER trg_runs_vram_ins
BEFORE INSERT ON runs
FOR EACH ROW
BEGIN
  DECLARE node_vram INT;
  IF NEW.node_id IS NOT NULL THEN
    SELECT vram_gb INTO node_vram FROM gpu_nodes WHERE node_id = NEW.node_id;
    IF NEW.vram_used_gb > node_vram THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'VRAM quota exceeded: run needs more memory than the node has';
    END IF;
  END IF;
END$$

DROP TRIGGER IF EXISTS trg_runs_vram_upd$$
CREATE TRIGGER trg_runs_vram_upd
BEFORE UPDATE ON runs
FOR EACH ROW
BEGIN
  DECLARE node_vram INT;
  IF NEW.node_id IS NOT NULL THEN
    SELECT vram_gb INTO node_vram FROM gpu_nodes WHERE node_id = NEW.node_id;
    IF NEW.vram_used_gb > node_vram THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'VRAM quota exceeded: run needs more memory than the node has';
    END IF;
  END IF;
END$$

-- Parameterized CRUD procedures
DROP PROCEDURE IF EXISTS sp_add_run$$
CREATE PROCEDURE sp_add_run(IN p_exp INT, IN p_node INT, IN p_vram DECIMAL(6,2))
BEGIN
  INSERT INTO runs (experiment_id, node_id, status, vram_used_gb)
  VALUES (p_exp, p_node, 'queued', p_vram);
  SELECT LAST_INSERT_ID() AS new_run_id;
END$$

DROP PROCEDURE IF EXISTS sp_get_run$$
CREATE PROCEDURE sp_get_run(IN p_run INT)
BEGIN
  SELECT * FROM runs WHERE run_id = p_run;
END$$

DROP PROCEDURE IF EXISTS sp_finish_run$$
CREATE PROCEDURE sp_finish_run(IN p_run INT, IN p_acc DECIMAL(5,4), IN p_loss DECIMAL(8,4))
BEGIN
  UPDATE runs
  SET status = 'done', accuracy = p_acc, loss = p_loss, ended_at = NOW()
  WHERE run_id = p_run;
END$$

DROP PROCEDURE IF EXISTS sp_delete_run$$
CREATE PROCEDURE sp_delete_run(IN p_run INT)
BEGIN
  DELETE FROM runs WHERE run_id = p_run;
END$$

-- Function: best accuracy for one project
DROP FUNCTION IF EXISTS fn_best_accuracy$$
CREATE FUNCTION fn_best_accuracy(p_project INT)
RETURNS DECIMAL(5,4)
READS SQL DATA
BEGIN
  DECLARE best DECIMAL(5,4);
  SELECT MAX(r.accuracy) INTO best
  FROM runs r
  JOIN experiments e ON e.experiment_id = r.experiment_id
  WHERE e.project_id = p_project;
  RETURN IFNULL(best, 0);
END$$

-- Cursor: top N runs by accuracy
DROP PROCEDURE IF EXISTS sp_top_n_runs$$
CREATE PROCEDURE sp_top_n_runs(IN p_n INT)
BEGIN
  DECLARE v_run INT;
  DECLARE v_acc DECIMAL(5,4);
  DECLARE v_rank INT DEFAULT 0;
  DECLARE finished INT DEFAULT 0;

  DECLARE cur CURSOR FOR
    SELECT run_id, accuracy FROM runs
    WHERE accuracy IS NOT NULL ORDER BY accuracy DESC, run_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

  DROP TEMPORARY TABLE IF EXISTS tmp_top;
  CREATE TEMPORARY TABLE tmp_top (rank_no INT, run_id INT, accuracy DECIMAL(5,4));

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_run, v_acc;
    IF finished = 1 OR v_rank >= GREATEST(p_n, 0) THEN
      LEAVE read_loop;
    END IF;
    SET v_rank = v_rank + 1;
    INSERT INTO tmp_top VALUES (v_rank, v_run, v_acc);
  END LOOP;
  CLOSE cur;

  SELECT * FROM tmp_top ORDER BY rank_no;
  DROP TEMPORARY TABLE tmp_top;
END$$

-- Exception handling: predefined duplicate-key error (1062)
DROP PROCEDURE IF EXISTS sp_safe_add_user$$
CREATE PROCEDURE sp_safe_add_user(IN p_name VARCHAR(80), IN p_email VARCHAR(120))
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SELECT 'Error: a user with this email already exists' AS message;
  INSERT INTO users (name, email) VALUES (p_name, p_email);
  SELECT 'User added' AS message;
END$$

-- Custom exception using SIGNAL, with rollback handler
DROP PROCEDURE IF EXISTS sp_assign_node$$
CREATE PROCEDURE sp_assign_node(IN p_run INT, IN p_node INT)
BEGIN
  DECLARE v_status VARCHAR(15);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SELECT 'Assignment failed and was rolled back' AS message;
  END;

  START TRANSACTION;
  SELECT status INTO v_status FROM gpu_nodes WHERE node_id = p_node;
  IF v_status = 'offline' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot assign run: node is offline';
  END IF;
  UPDATE runs SET node_id = p_node WHERE run_id = p_run;
  COMMIT;
  SELECT 'Node assigned' AS message;
END$$

DELIMITER ;

-- Tests: execute individually after creating the objects.
-- Audit trigger:
-- UPDATE runs SET status = 'running' WHERE run_id = 13;
-- SELECT * FROM audit_log WHERE run_id = 13 ORDER BY changed_at DESC;

-- Deliberate quota error: node 1 has 24 GB; request 30 GB.
-- INSERT INTO runs (experiment_id, node_id, vram_used_gb) VALUES (1, 1, 30);

-- CRUD: capture the generated ID; earlier rolled-back inserts may consume IDs.
-- CALL sp_add_run(6, 2, 8);
-- SET @demo_run_id = LAST_INSERT_ID();
-- CALL sp_get_run(@demo_run_id);
-- CALL sp_finish_run(@demo_run_id, 0.9300, 0.1800);
-- CALL sp_delete_run(@demo_run_id);

-- Function and cursor:
-- SELECT title, fn_best_accuracy(project_id) AS best_accuracy FROM projects;
-- CALL sp_top_n_runs(3);

-- Duplicate email handler, then successful insertion:
-- CALL sp_safe_add_user('Aarav Mehta', 'aarav.mehta@example.com');
-- CALL sp_safe_add_user('Nikhil Rao', 'nikhil.rao@example.com');

-- Node 6 is offline (expected handled error); node 3 is idle (success).
-- CALL sp_assign_node(15, 6);
-- CALL sp_assign_node(15, 3);

-- Inspect objects:
-- SHOW TRIGGERS;
-- SHOW PROCEDURE STATUS WHERE Db = 'modelforge';
-- SHOW FUNCTION STATUS WHERE Db = 'modelforge';