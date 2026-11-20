-- 02_dml.sql : ModelForge sample data (MySQL 8.0)
-- Run after 01_ddl.sql. Inserts 15 rows into each of the eight tables.
USE modelforge;

-- USERS (15)
INSERT INTO users (user_id, name, email, role) VALUES
(1,'Aarav Mehta','aarav.mehta@example.com','admin'),
(2,'Mira Shah','mira.shah@example.com','researcher'),
(3,'Kabir Rao','kabir.rao@example.com','researcher'),
(4,'Ananya Iyer','ananya.iyer@example.com','researcher'),
(5,'Rohan Das','rohan.das@example.com','viewer'),
(6,'Isha Nair','isha.nair@example.com','researcher'),
(7,'Dev Patel','dev.patel@example.com','researcher'),
(8,'Sara Khan','sara.khan@example.com','viewer'),
(9,'Neel Joshi','neel.joshi@example.com','researcher'),
(10,'Tara Bose','tara.bose@example.com','researcher'),
(11,'Arjun Menon','arjun.menon@example.com','researcher'),
(12,'Diya Kulkarni','diya.kulkarni@example.com','viewer'),
(13,'Vikram Sen','vikram.sen@example.com','researcher'),
(14,'Nina Kapoor','nina.kapoor@example.com','researcher'),
(15,'Om Verma','om.verma@example.com','viewer');

-- PROJECTS (15)
INSERT INTO projects (project_id, owner_id, title, created_on) VALUES
(1,1,'ImageNet ResNet Benchmark','2026-10-01'),
(2,2,'Cloud Removal from Satellite Images','2026-10-02'),
(3,3,'Road Segmentation with U-Net','2026-10-03'),
(4,4,'Plant Disease Classification','2026-10-04'),
(5,6,'Hindi News Topic Classifier','2026-10-05'),
(6,7,'Retail Demand Forecasting','2026-10-06'),
(7,9,'Wildlife Camera Detection','2026-10-07'),
(8,10,'Chest X-ray Baseline','2026-10-08'),
(9,11,'Audio Event Recognition','2026-10-09'),
(10,13,'Document Layout Parsing','2026-10-10'),
(11,14,'Traffic Sign Recognition','2026-10-11'),
(12,2,'Coastal Change Segmentation','2026-10-12'),
(13,3,'Product Defect Detection','2026-10-13'),
(14,6,'Energy Load Forecasting','2026-10-14'),
(15,1,'Small Language Model Fine-tuning','2026-10-15');

-- DATASETS (15)
INSERT INTO datasets (dataset_id, project_id, name, size_mb, format, source_url) VALUES
(1,1,'ImageNet-100 subset',18432.00,'images','https://www.image-net.org/'),
(2,2,'Sentinel-2 cloudy-clear pairs',32768.50,'parquet','https://patricktum.github.io/cloud_removal/sen12mscr/'),
(3,3,'Massachusetts roads tiles',5120.00,'images','https://www.cs.toronto.edu/~vmnih/data/'),
(4,4,'PlantVillage RGB images',4096.75,'images','https://github.com/spMohanty/PlantVillage-Dataset'),
(5,5,'Hindi News Article Text Dataset',1280.00,'json','https://zenodo.org/records/10020768'),
(6,6,'Daily retail sales 2019-2025',96.40,'csv',NULL),
(7,7,'Camera-trap wildlife frames',15360.00,'images',NULL),
(8,8,'Chest X-ray 14 sample',8192.00,'images',NULL),
(9,9,'Urban sound clips metadata',740.25,'parquet',NULL),
(10,10,'DocLayNet training subset',24576.00,'images',NULL),
(11,11,'GTSRB cropped signs',2048.00,'images',NULL),
(12,12,'CoastSat seasonal patches',9216.00,'parquet',NULL),
(13,13,'Factory surface defects',6144.00,'images',NULL),
(14,14,'Hourly smart-meter readings',512.50,'csv',NULL),
(15,15,'ML engineering notes corpus',3584.00,'json',NULL);
-- GPU NODES (15)
INSERT INTO gpu_nodes (node_id, name, vram_gb, status) VALUES
(1,'local-rtx4090',24,'idle'),
(2,'lab-a100-01',80,'busy'),
(3,'lab-a100-02',80,'idle'),
(4,'lab-v100-01',32,'busy'),
(5,'lab-l40s-01',48,'idle'),
(6,'local-rtx3090',24,'offline'),
(7,'lab-a10-01',24,'idle'),
(8,'lab-a10-02',24,'busy'),
(9,'cloud-a100-spot-01',40,'idle'),
(10,'cloud-l4-01',24,'busy'),
(11,'lab-t4-01',16,'idle'),
(12,'lab-t4-02',16,'offline'),
(13,'cloud-a10-spot-02',24,'idle'),
(14,'local-rtx4080',16,'busy'),
(15,'lab-h100-01',80,'idle');

-- EXPERIMENTS (15)
INSERT INTO experiments (experiment_id, project_id, dataset_id, title) VALUES
(1,1,1,'ResNet-50 AdamW baseline'),
(2,2,2,'Cloud mask U-Net v1'),
(3,3,3,'U-Net roads 512px'),
(4,4,4,'EfficientNet-B0 transfer learning'),
(5,5,5,'IndicBERT topic baseline'),
(6,6,6,'LightGBM lag-feature baseline'),
(7,7,7,'YOLO wildlife detector small'),
(8,8,8,'DenseNet-121 X-ray baseline'),
(9,9,9,'AST audio classifier'),
(10,10,10,'LayoutLM document regions'),
(11,11,11,'ResNet-18 sign classifier'),
(12,12,12,'Siamese coastal change model'),
(13,13,13,'ConvNeXt-T defect classifier'),
(14,14,14,'Temporal CNN energy forecast'),
(15,15,15,'LoRA 1B domain adaptation');

-- RUNS (15)
INSERT INTO runs
(run_id, experiment_id, node_id, status, accuracy, loss, vram_used_gb, started_at, ended_at) VALUES
(1,1,1,'done',0.9412,0.1834,18.50,'2026-11-01 09:00:00','2026-11-01 10:42:00'),
(2,2,2,'done',0.8875,0.2710,52.00,'2026-11-01 11:00:00','2026-11-01 13:18:00'),
(3,3,4,'done',0.9120,0.2241,26.00,'2026-11-02 08:30:00','2026-11-02 10:05:00'),
(4,4,5,'done',0.9633,0.1088,21.00,'2026-11-02 10:30:00','2026-11-02 11:47:00'),
(5,5,7,'failed',NULL,1.8420,20.00,'2026-11-03 09:15:00','2026-11-03 09:29:00'),
(6,6,11,'done',0.7814,0.3920,8.00,'2026-11-03 12:00:00','2026-11-03 12:38:00'),
(7,7,8,'running',NULL,0.6100,19.50,'2026-11-04 07:45:00',NULL),
(8,8,9,'done',0.8244,0.3562,31.00,'2026-11-04 08:00:00','2026-11-04 10:20:00'),
(9,9,10,'done',0.9068,0.2475,17.00,'2026-11-05 14:00:00','2026-11-05 15:31:00'),
(10,10,3,'done',0.9321,0.1940,49.00,'2026-11-06 09:00:00','2026-11-06 12:12:00'),
(11,11,14,'queued',NULL,NULL,0.00,'2026-11-18 08:00:00',NULL),
(12,12,15,'done',0.8730,0.3021,46.00,'2026-11-07 11:00:00','2026-11-07 13:42:00'),
(13,13,1,'done',0.9587,0.1190,20.00,'2026-11-08 10:00:00','2026-11-08 11:06:00'),
(14,14,13,'failed',NULL,0.9330,23.00,'2026-11-09 16:10:00','2026-11-09 16:15:00'),
(15,15,2,'done',0.9146,0.2115,68.00,'2026-11-10 07:00:00','2026-11-10 09:55:00');

-- METRICS (15)
INSERT INTO metrics (metric_id, run_id, epoch, loss, accuracy) VALUES
(1,1,1,0.8120,0.7010),
(2,1,10,0.1834,0.9412),
(3,2,1,0.9040,0.6520),
(4,2,20,0.2710,0.8875),
(5,3,1,0.7560,0.7110),
(6,3,15,0.2241,0.9120),
(7,4,1,0.6430,0.8030),
(8,4,12,0.1088,0.9633),
(9,6,1,0.9210,0.5920),
(10,6,30,0.3920,0.7814),
(11,7,1,1.1020,0.5100),
(12,8,1,0.9860,0.6240),
(13,8,25,0.3562,0.8244),
(14,10,1,0.7730,0.7340),
(15,10,18,0.1940,0.9321);

-- AUDIT LOG (15) : sample status transitions for the status trigger lab.
INSERT INTO audit_log (log_id, run_id, old_status, new_status, changed_at) VALUES
(1,1,'queued','running','2026-11-01 09:00:00'),
(2,1,'running','done','2026-11-01 10:42:00'),
(3,2,'queued','running','2026-11-01 11:00:00'),
(4,2,'running','done','2026-11-01 13:18:00'),
(5,3,'queued','running','2026-11-02 08:30:00'),
(6,3,'running','done','2026-11-02 10:05:00'),
(7,4,'queued','running','2026-11-02 10:30:00'),
(8,4,'running','done','2026-11-02 11:47:00'),
(9,5,'queued','running','2026-11-03 09:15:00'),
(10,5,'running','failed','2026-11-03 09:29:00'),
(11,6,'queued','running','2026-11-03 12:00:00'),
(12,6,'running','done','2026-11-03 12:38:00'),
(13,14,'queued','running','2026-11-09 16:10:00'),
(14,14,'running','failed','2026-11-09 16:15:00'),
(15,15,'running','done','2026-11-10 09:55:00');

-- DML examples: UPDATE, DELETE, and SELECT.
-- Roll back the edits so all 15 sample rows in each table remain available.
START TRANSACTION;

UPDATE gpu_nodes
SET status = 'busy'
WHERE node_id = 1;

DELETE FROM metrics
WHERE metric_id = 15;

SELECT user_id, name, email, role
FROM users
ORDER BY user_id;

ROLLBACK;

-- Confirm the seed row counts (each table should report 15).
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL SELECT 'projects', COUNT(*) FROM projects
UNION ALL SELECT 'datasets', COUNT(*) FROM datasets
UNION ALL SELECT 'gpu_nodes', COUNT(*) FROM gpu_nodes
UNION ALL SELECT 'experiments', COUNT(*) FROM experiments
UNION ALL SELECT 'runs', COUNT(*) FROM runs
UNION ALL SELECT 'metrics', COUNT(*) FROM metrics
UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log;