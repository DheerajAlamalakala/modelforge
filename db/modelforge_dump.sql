-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: modelforge
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `modelforge`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `modelforge` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `modelforge`;

--
-- Table structure for table `audit_log`
--

DROP TABLE IF EXISTS `audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `run_id` int NOT NULL,
  `old_status` varchar(15) NOT NULL,
  `new_status` varchar(15) NOT NULL,
  `changed_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `fk_audit_run` (`run_id`),
  CONSTRAINT `fk_audit_run` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_log`
--

LOCK TABLES `audit_log` WRITE;
/*!40000 ALTER TABLE `audit_log` DISABLE KEYS */;
INSERT INTO `audit_log` VALUES (1,1,'queued','running','2026-11-01 09:00:00'),(2,1,'running','done','2026-11-01 10:42:00'),(3,2,'queued','running','2026-11-01 11:00:00'),(4,2,'running','done','2026-11-01 13:18:00'),(5,3,'queued','running','2026-11-02 08:30:00'),(6,3,'running','done','2026-11-02 10:05:00'),(7,4,'queued','running','2026-11-02 10:30:00'),(8,4,'running','done','2026-11-02 11:47:00'),(9,5,'queued','running','2026-11-03 09:15:00'),(10,5,'running','failed','2026-11-03 09:29:00'),(11,6,'queued','running','2026-11-03 12:00:00'),(12,6,'running','done','2026-11-03 12:38:00'),(13,14,'queued','running','2026-11-09 16:10:00'),(14,14,'running','failed','2026-11-09 16:15:00'),(15,15,'running','done','2026-11-10 09:55:00');
/*!40000 ALTER TABLE `audit_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `datasets`
--

DROP TABLE IF EXISTS `datasets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `datasets` (
  `dataset_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `name` varchar(120) NOT NULL,
  `size_mb` decimal(12,2) NOT NULL,
  `format` varchar(20) NOT NULL DEFAULT 'csv',
  `source_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`dataset_id`),
  KEY `fk_datasets_project` (`project_id`),
  CONSTRAINT `fk_datasets_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_datasets_format` CHECK ((`format` in (_utf8mb4'csv',_utf8mb4'json',_utf8mb4'parquet',_utf8mb4'images'))),
  CONSTRAINT `datasets_chk_1` CHECK ((`size_mb` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datasets`
--

LOCK TABLES `datasets` WRITE;
/*!40000 ALTER TABLE `datasets` DISABLE KEYS */;
INSERT INTO `datasets` VALUES (1,1,'ImageNet-100 subset',18432.00,'images','https://www.image-net.org/'),(2,2,'Sentinel-2 cloudy-clear pairs',32768.50,'parquet','https://patricktum.github.io/cloud_removal/sen12mscr/'),(3,3,'Massachusetts roads tiles',5120.00,'images','https://www.cs.toronto.edu/~vmnih/data/'),(4,4,'PlantVillage RGB images',4096.75,'images','https://github.com/spMohanty/PlantVillage-Dataset'),(5,5,'Indic news articles v2',1280.00,'json','https://zenodo.org/records/10020768'),(6,6,'Daily retail sales 2019-2025',96.40,'csv',NULL),(7,7,'Camera-trap wildlife frames',15360.00,'images',NULL),(8,8,'Chest X-ray 14 sample',8192.00,'images',NULL),(9,9,'Urban sound clips metadata',740.25,'parquet',NULL),(10,10,'DocLayNet training subset',24576.00,'images',NULL),(11,11,'GTSRB cropped signs',2048.00,'images',NULL),(12,12,'CoastSat seasonal patches',9216.00,'parquet',NULL),(13,13,'Factory surface defects',6144.00,'images',NULL),(14,14,'Hourly smart-meter readings',512.50,'csv',NULL),(15,15,'ML engineering notes corpus',3584.00,'json',NULL),(16,16,'CIFAR-10 demo subset',120.50,'images',NULL),(17,18,'sen',100000000.00,'images',NULL);
/*!40000 ALTER TABLE `datasets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `experiments` (
  `experiment_id` int NOT NULL AUTO_INCREMENT,
  `project_id` int NOT NULL,
  `dataset_id` int DEFAULT NULL,
  `title` varchar(140) NOT NULL,
  PRIMARY KEY (`experiment_id`),
  KEY `fk_experiments_project` (`project_id`),
  KEY `fk_experiments_dataset` (`dataset_id`),
  CONSTRAINT `fk_experiments_dataset` FOREIGN KEY (`dataset_id`) REFERENCES `datasets` (`dataset_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_experiments_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `experiments`
--

LOCK TABLES `experiments` WRITE;
/*!40000 ALTER TABLE `experiments` DISABLE KEYS */;
INSERT INTO `experiments` VALUES (1,1,1,'ResNet-50 AdamW baseline'),(2,2,2,'Cloud mask U-Net v1'),(3,3,3,'U-Net roads 512px'),(4,4,4,'EfficientNet-B0 transfer learning'),(5,5,5,'IndicBERT topic baseline'),(6,6,6,'LightGBM lag-feature baseline'),(7,7,7,'YOLO wildlife detector small'),(8,8,8,'DenseNet-121 X-ray baseline'),(9,9,9,'AST audio classifier'),(10,10,10,'LayoutLM document regions'),(11,11,11,'ResNet-18 sign classifier'),(12,12,12,'Siamese coastal change model'),(13,13,13,'ConvNeXt-T defect classifier'),(14,14,14,'Temporal CNN energy forecast'),(15,15,15,'LoRA 1B domain adaptation'),(16,16,16,'ResNet-18 baseline'),(17,18,17,'transformer');
/*!40000 ALTER TABLE `experiments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gpu_nodes`
--

DROP TABLE IF EXISTS `gpu_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gpu_nodes` (
  `node_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `vram_gb` int NOT NULL,
  `status` varchar(15) NOT NULL DEFAULT 'idle',
  PRIMARY KEY (`node_id`),
  UNIQUE KEY `name` (`name`),
  CONSTRAINT `chk_gpu_nodes_status` CHECK ((`status` in (_utf8mb4'idle',_utf8mb4'busy',_utf8mb4'offline'))),
  CONSTRAINT `gpu_nodes_chk_1` CHECK ((`vram_gb` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gpu_nodes`
--

LOCK TABLES `gpu_nodes` WRITE;
/*!40000 ALTER TABLE `gpu_nodes` DISABLE KEYS */;
INSERT INTO `gpu_nodes` VALUES (1,'local-rtx4090',24,'idle'),(2,'lab-a100-01',80,'busy'),(3,'lab-a100-02',80,'idle'),(4,'lab-v100-01',32,'busy'),(5,'lab-l40s-01',48,'idle'),(6,'local-rtx3090',24,'offline'),(7,'lab-a10-01',24,'idle'),(8,'lab-a10-02',24,'busy'),(9,'cloud-a100-spot-01',40,'idle'),(10,'cloud-l4-01',24,'busy'),(11,'lab-t4-01',16,'idle'),(12,'lab-t4-02',16,'offline'),(13,'cloud-a10-spot-02',24,'idle'),(14,'local-rtx4080',16,'busy'),(15,'lab-h100-01',80,'idle');
/*!40000 ALTER TABLE `gpu_nodes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metrics`
--

DROP TABLE IF EXISTS `metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metrics` (
  `metric_id` int NOT NULL AUTO_INCREMENT,
  `run_id` int NOT NULL,
  `epoch` int NOT NULL,
  `loss` decimal(8,4) DEFAULT NULL,
  `accuracy` decimal(5,4) DEFAULT NULL,
  PRIMARY KEY (`metric_id`),
  UNIQUE KEY `uq_metrics_run_epoch` (`run_id`,`epoch`),
  CONSTRAINT `fk_metrics_run` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_metrics_accuracy` CHECK (((`accuracy` is null) or (`accuracy` between 0 and 1))),
  CONSTRAINT `chk_metrics_loss` CHECK (((`loss` is null) or (`loss` >= 0))),
  CONSTRAINT `metrics_chk_1` CHECK ((`epoch` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metrics`
--

LOCK TABLES `metrics` WRITE;
/*!40000 ALTER TABLE `metrics` DISABLE KEYS */;
INSERT INTO `metrics` VALUES (1,1,1,0.8120,0.7010),(2,1,10,0.1834,0.9412),(3,2,1,0.9040,0.6520),(4,2,20,0.2710,0.8875),(5,3,1,0.7560,0.7110),(6,3,15,0.2241,0.9120),(7,4,1,0.6430,0.8030),(8,4,12,0.1088,0.9633),(9,6,1,0.9210,0.5920),(10,6,30,0.3920,0.7814),(11,7,1,1.1020,0.5100),(12,8,1,0.9860,0.6240),(13,8,25,0.3562,0.8244),(14,10,1,0.7730,0.7340),(15,10,18,0.1940,0.9321);
/*!40000 ALTER TABLE `metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `project_id` int NOT NULL AUTO_INCREMENT,
  `owner_id` int NOT NULL,
  `title` varchar(120) NOT NULL,
  `created_on` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`project_id`),
  KEY `fk_projects_owner` (`owner_id`),
  CONSTRAINT `fk_projects_owner` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,1,'ImageNet ResNet Benchmark','2026-10-01'),(2,2,'Cloud Removal from Satellite Images','2026-10-02'),(3,3,'Road Segmentation with U-Net','2026-10-03'),(4,4,'Plant Disease Classification','2026-10-04'),(5,6,'Hindi News Topic Classifier','2026-10-05'),(6,7,'Retail Demand Forecasting','2026-10-06'),(7,9,'Wildlife Camera Detection','2026-10-07'),(8,10,'Chest X-ray Baseline','2026-10-08'),(9,11,'Audio Event Recognition','2026-10-09'),(10,13,'Document Layout Parsing','2026-10-10'),(11,14,'Traffic Sign Recognition','2026-10-11'),(12,2,'Coastal Change Segmentation','2026-10-12'),(13,3,'Product Defect Detection','2026-10-13'),(14,6,'Energy Load Forecasting','2026-10-14'),(15,1,'Small Language Model Fine-tuning','2026-10-15'),(16,16,'Demo Image Classifier','2026-11-18'),(17,16,'llm','2026-11-18'),(18,17,'xyz technologies','2026-11-20');
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `runs`
--

DROP TABLE IF EXISTS `runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `runs` (
  `run_id` int NOT NULL AUTO_INCREMENT,
  `experiment_id` int NOT NULL,
  `node_id` int DEFAULT NULL,
  `status` varchar(15) NOT NULL DEFAULT 'queued',
  `accuracy` decimal(5,4) DEFAULT NULL,
  `loss` decimal(8,4) DEFAULT NULL,
  `vram_used_gb` decimal(6,2) NOT NULL DEFAULT '0.00',
  `notes` varchar(500) DEFAULT NULL,
  `started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` datetime DEFAULT NULL,
  PRIMARY KEY (`run_id`),
  KEY `fk_runs_experiment` (`experiment_id`),
  KEY `fk_runs_node` (`node_id`),
  CONSTRAINT `fk_runs_experiment` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`experiment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_runs_node` FOREIGN KEY (`node_id`) REFERENCES `gpu_nodes` (`node_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `chk_runs_accuracy` CHECK (((`accuracy` is null) or (`accuracy` between 0 and 1))),
  CONSTRAINT `chk_runs_loss` CHECK (((`loss` is null) or (`loss` >= 0))),
  CONSTRAINT `chk_runs_status` CHECK ((`status` in (_utf8mb4'queued',_utf8mb4'running',_utf8mb4'done',_utf8mb4'failed'))),
  CONSTRAINT `chk_runs_vram` CHECK ((`vram_used_gb` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `runs`
--

LOCK TABLES `runs` WRITE;
/*!40000 ALTER TABLE `runs` DISABLE KEYS */;
INSERT INTO `runs` VALUES (1,1,1,'done',0.9412,0.1834,18.50,NULL,'2026-11-01 09:00:00','2026-11-01 10:42:00'),(2,2,2,'done',0.8875,0.2710,52.00,NULL,'2026-11-01 11:00:00','2026-11-01 13:18:00'),(3,3,4,'done',0.9120,0.2241,26.00,NULL,'2026-11-02 08:30:00','2026-11-02 10:05:00'),(4,4,5,'done',0.9633,0.1088,21.00,NULL,'2026-11-02 10:30:00','2026-11-02 11:47:00'),(5,5,7,'failed',NULL,1.8420,20.00,NULL,'2026-11-03 09:15:00','2026-11-03 09:29:00'),(6,6,11,'done',0.7814,0.3920,8.00,NULL,'2026-11-03 12:00:00','2026-11-03 12:38:00'),(7,7,8,'running',NULL,0.6100,19.50,NULL,'2026-11-04 07:45:00',NULL),(8,8,9,'done',0.8244,0.3562,31.00,NULL,'2026-11-04 08:00:00','2026-11-04 10:20:00'),(9,9,10,'done',0.9068,0.2475,17.00,NULL,'2026-11-05 14:00:00','2026-11-05 15:31:00'),(10,10,3,'done',0.9321,0.1940,49.00,NULL,'2026-11-06 09:00:00','2026-11-06 12:12:00'),(11,11,14,'queued',NULL,NULL,0.00,NULL,'2026-11-18 08:00:00',NULL),(12,12,15,'done',0.8730,0.3021,46.00,NULL,'2026-11-07 11:00:00','2026-11-07 13:42:00'),(13,13,1,'done',0.9587,0.1190,20.00,NULL,'2026-11-08 10:00:00','2026-11-08 11:06:00'),(14,14,13,'failed',NULL,0.9330,23.00,NULL,'2026-11-09 16:10:00','2026-11-09 16:15:00'),(15,15,2,'done',0.9146,0.2115,68.00,NULL,'2026-11-10 07:00:00','2026-11-10 09:55:00'),(18,16,1,'done',0.9300,0.1800,4.00,NULL,'2026-11-18 22:52:02','2026-11-18 17:22:02'),(19,16,NULL,'queued',NULL,NULL,0.00,NULL,'2026-11-18 22:56:34',NULL),(20,16,2,'queued',0.9000,1.0000,8.00,NULL,'2026-11-20 13:07:18',NULL),(21,17,9,'running',0.9990,0.1005,25.00,NULL,'2026-11-20 13:13:10',NULL);
/*!40000 ALTER TABLE `runs` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_runs_vram_ins` BEFORE INSERT ON `runs` FOR EACH ROW BEGIN
  DECLARE node_vram INT;
  IF NEW.node_id IS NOT NULL THEN
    SELECT vram_gb INTO node_vram FROM gpu_nodes WHERE node_id = NEW.node_id;
    IF NEW.vram_used_gb > node_vram THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'VRAM quota exceeded: run needs more memory than the node has';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_runs_vram_upd` BEFORE UPDATE ON `runs` FOR EACH ROW BEGIN
  DECLARE node_vram INT;
  IF NEW.node_id IS NOT NULL THEN
    SELECT vram_gb INTO node_vram FROM gpu_nodes WHERE node_id = NEW.node_id;
    IF NEW.vram_used_gb > node_vram THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'VRAM quota exceeded: run needs more memory than the node has';
    END IF;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_runs_audit` AFTER UPDATE ON `runs` FOR EACH ROW BEGIN
  IF OLD.status <> NEW.status THEN
    INSERT INTO audit_log (run_id, old_status, new_status)
    VALUES (OLD.run_id, OLD.status, NEW.status);
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'researcher',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `chk_users_role` CHECK ((`role` in (_utf8mb4'admin',_utf8mb4'researcher',_utf8mb4'viewer')))
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Aarav Mehta','aarav.mehta@example.com',NULL,'admin'),(2,'Mira Shah','mira.shah@example.com',NULL,'researcher'),(3,'Kabir Rao','kabir.rao@example.com',NULL,'researcher'),(4,'Ananya Iyer','ananya.iyer@example.com',NULL,'researcher'),(5,'Rohan Das','rohan.das@example.com',NULL,'viewer'),(6,'Isha Nair','isha.nair@example.com',NULL,'researcher'),(7,'Dev Patel','dev.patel@example.com',NULL,'researcher'),(8,'Sara Khan','sara.khan@example.com',NULL,'viewer'),(9,'Neel Joshi','neel.joshi@example.com',NULL,'researcher'),(10,'Tara Bose','tara.bose@example.com',NULL,'researcher'),(11,'Arjun Menon','arjun.menon@example.com',NULL,'researcher'),(12,'Diya Kulkarni','diya.kulkarni@example.com',NULL,'viewer'),(13,'Vikram Sen','vikram.sen@example.com',NULL,'researcher'),(14,'Nina Kapoor','nina.kapoor@example.com',NULL,'researcher'),(15,'Om Verma','om.verma@example.com',NULL,'viewer'),(16,'ModelForge Demo','demo@modelforge.dev','$2y$12$bUmLYEIAe6J4NIT8gPym1uh1XOMGFKUD5Z5kI7GPVzrVoVJnQdupi','researcher'),(17,'charan','charansaikumarkurapati@gmail.com','$2y$12$ivbRZ63xLCszPCxsSoa5ouTxh/FtD7QuEpwYbtpBwUcm/lh0DofEq','researcher');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_done_runs`
--

DROP TABLE IF EXISTS `v_done_runs`;
/*!50001 DROP VIEW IF EXISTS `v_done_runs`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_done_runs` AS SELECT
 1 AS `run_id`,
 1 AS `experiment_id`,
 1 AS `node_id`,
 1 AS `status`,
 1 AS `accuracy`,
 1 AS `loss`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_high_accuracy_runs`
--

DROP TABLE IF EXISTS `v_high_accuracy_runs`;
/*!50001 DROP VIEW IF EXISTS `v_high_accuracy_runs`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_high_accuracy_runs` AS SELECT
 1 AS `run_id`,
 1 AS `experiment_id`,
 1 AS `node_id`,
 1 AS `status`,
 1 AS `accuracy`,
 1 AS `loss`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_project_summary`
--

DROP TABLE IF EXISTS `v_project_summary`;
/*!50001 DROP VIEW IF EXISTS `v_project_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_project_summary` AS SELECT
 1 AS `title`,
 1 AS `total_runs`,
 1 AS `best_accuracy`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_run_report`
--

DROP TABLE IF EXISTS `v_run_report`;
/*!50001 DROP VIEW IF EXISTS `v_run_report`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_run_report` AS SELECT
 1 AS `project`,
 1 AS `experiment`,
 1 AS `gpu`,
 1 AS `status`,
 1 AS `accuracy`,
 1 AS `loss`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'modelforge'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_best_accuracy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_best_accuracy`(p_project INT) RETURNS decimal(5,4)
    READS SQL DATA
BEGIN
  DECLARE best DECIMAL(5,4);
  SELECT MAX(r.accuracy) INTO best
  FROM runs r
  JOIN experiments e ON e.experiment_id = r.experiment_id
  WHERE e.project_id = p_project;
  RETURN IFNULL(best, 0);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_add_run` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_run`(IN p_exp INT, IN p_node INT, IN p_vram DECIMAL(6,2))
BEGIN
  INSERT INTO runs (experiment_id, node_id, status, vram_used_gb)
  VALUES (p_exp, p_node, 'queued', p_vram);
  SELECT LAST_INSERT_ID() AS new_run_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_assign_node` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_assign_node`(IN p_run INT, IN p_node INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_run` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_run`(IN p_run INT)
BEGIN
  DELETE FROM runs WHERE run_id = p_run;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_finish_run` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_finish_run`(IN p_run INT, IN p_acc DECIMAL(5,4), IN p_loss DECIMAL(8,4))
BEGIN
  UPDATE runs
  SET status = 'done', accuracy = p_acc, loss = p_loss, ended_at = NOW()
  WHERE run_id = p_run;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_get_run` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_run`(IN p_run INT)
BEGIN
  SELECT * FROM runs WHERE run_id = p_run;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_safe_add_user` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_safe_add_user`(IN p_name VARCHAR(80), IN p_email VARCHAR(120))
BEGIN
  DECLARE EXIT HANDLER FOR 1062
    SELECT 'Error: a user with this email already exists' AS message;
  INSERT INTO users (name, email) VALUES (p_name, p_email);
  SELECT 'User added' AS message;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_top_n_runs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_top_n_runs`(IN p_n INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `modelforge`
--

USE `modelforge`;

--
-- Final view structure for view `v_done_runs`
--

/*!50001 DROP VIEW IF EXISTS `v_done_runs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_done_runs` AS select `runs`.`run_id` AS `run_id`,`runs`.`experiment_id` AS `experiment_id`,`runs`.`node_id` AS `node_id`,`runs`.`status` AS `status`,`runs`.`accuracy` AS `accuracy`,`runs`.`loss` AS `loss` from `runs` where (`runs`.`status` = 'done') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_high_accuracy_runs`
--

/*!50001 DROP VIEW IF EXISTS `v_high_accuracy_runs`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_high_accuracy_runs` AS select `runs`.`run_id` AS `run_id`,`runs`.`experiment_id` AS `experiment_id`,`runs`.`node_id` AS `node_id`,`runs`.`status` AS `status`,`runs`.`accuracy` AS `accuracy`,`runs`.`loss` AS `loss` from `runs` where (`runs`.`accuracy` >= 0.85) */
/*!50002 WITH CASCADED CHECK OPTION */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_project_summary`
--

/*!50001 DROP VIEW IF EXISTS `v_project_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_project_summary` AS select `p`.`title` AS `title`,count(`r`.`run_id`) AS `total_runs`,max(`r`.`accuracy`) AS `best_accuracy` from ((`projects` `p` left join `experiments` `e` on((`e`.`project_id` = `p`.`project_id`))) left join `runs` `r` on((`r`.`experiment_id` = `e`.`experiment_id`))) group by `p`.`project_id`,`p`.`title` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_run_report`
--

/*!50001 DROP VIEW IF EXISTS `v_run_report`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_run_report` AS select `p`.`title` AS `project`,`e`.`title` AS `experiment`,`g`.`name` AS `gpu`,`r`.`status` AS `status`,`r`.`accuracy` AS `accuracy`,`r`.`loss` AS `loss` from (((`runs` `r` join `experiments` `e` on((`e`.`experiment_id` = `r`.`experiment_id`))) join `projects` `p` on((`p`.`project_id` = `e`.`project_id`))) left join `gpu_nodes` `g` on((`g`.`node_id` = `r`.`node_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-20 13:58:29
