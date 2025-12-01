USE mydatabase;

# # # # # # # # # # # # # # # SET TRANSACTION Statement # # # # # # # # # # # # # # #

# # # # # # Demo 1: SET TRANSACTION READ COMMITTED, READ ONLY # # # # # #
SET autocommit = 1;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED, READ ONLY;
START TRANSACTION;
-- Check isolation level & read_only of current transaction
SELECT @@transaction_isolation      AS tx_isolation,
       @@transaction_read_only      AS tx_read_only;
-- Error
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (25, 'L4-5: mild broad based central disc bulge is noted indenting thecal sac.// L5-S1: central disc protrusion is noted indenting thecal sac/// diffuse bone marrow signal reconversion is noted');
ROLLBACK;
SELECT @@session.transaction_isolation   AS session_isolation,
       @@session.transaction_read_only   AS session_read_only;

# # # # # # Demo 2: Do not SET TRANSACTION while in transaction # # # # # #
START TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
ROLLBACK;

# # # # # # Demo 3: SET SESSION TRANSACTION # # # # # #
-- Reset transaction isolation
SET SESSION transaction_isolation = @@GLOBAL.transaction_isolation;
-- Tab 1
START TRANSACTION;
SELECT * FROM radiology_db_reports WHERE patient_id = 1; 
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation; 
-- Tab 2
UPDATE radiology_db_reports SET clinician_notes = 'update' WHERE patient_id = 1;
COMMIT;
-- Tab 1
SELECT * FROM radiology_db_reports WHERE patient_id = 1; 
COMMIT;
START TRANSACTION; 
SELECT * FROM radiology_db_reports WHERE patient_id = 1; 
-- Tab 2
UPDATE radiology_db_reports SET clinician_notes = 'update 2' WHERE patient_id = 1;
-- Tab 1
SELECT * FROM radiology_db_reports WHERE patient_id = 1; 

# # # # # # Demo 4: COMPARE SET TRANSACTION vs SET var_name # # # # # #
SET GLOBAL transaction_read_only  = OFF;
SET SESSION transaction_isolation = @@GLOBAL.transaction_isolation;

SET SESSION transaction_isolation = 'READ-COMMITTED';
SET SESSION transaction_read_only = 0;

SELECT @@session.transaction_isolation AS session_iso,
       @@session.transaction_read_only AS session_ro;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;
	SELECT * FROM radiology_db_reports;
    SELECT trx_id, trx_isolation_level 
    FROM information_schema.innodb_trx 
    WHERE trx_mysql_thread_id = CONNECTION_ID();
COMMIT;

START TRANSACTION;
	SELECT * FROM radiology_db_reports;
    SELECT trx_id, trx_isolation_level 
    FROM information_schema.innodb_trx 
    WHERE trx_mysql_thread_id = CONNECTION_ID();
COMMIT;

# # # # # # Demo 5: READ ONLY vs READ WRITE + TEMPORARY TABLE # # # # # #
SET TRANSACTION READ ONLY;
START TRANSACTION;

INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (22, 'Lumbosacral MRI
Features of muscle spasm 
Central and left paracentral disc protrusion noted at the level of L4-L5
Significantly compressing the thecal sac and the left exit nerve root 
and  desiccative disc material noted .');

ROLLBACK;

SELECT * FROM radiology_db_reports;
  
# # # # # # Demo 6: REPEATABLE READ vs READ COMMITTED # # # # # #
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (23, 'L4-l5 L5-S1: diffuse disc bulges compressing the thecal sac and encroaching exit canals.');
-- REPEATABLE READ
-- Tab 1
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM radiology_db_reports; 
-- Tab 2
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (24, 'No evidence of disc herniation.
No significant thecal sac or nerve root compression noted.
Adequate spinal canal.');
COMMIT;
-- Tab 1
SELECT * FROM radiology_db_reports;
COMMIT;

-- READ COMMITTED
-- Tab 1
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM radiology_db_reports;
-- Tab 2
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (25, 'L4-5: mild broad based central disc bulge is noted indenting thecal sac.// L5-S1: central disc protrusion is noted indenting thecal sac/// diffuse bone marrow signal reconversion is noted');
COMMIT;
-- Tab 1
SELECT * FROM radiology_db_reports;
COMMIT;

# # # # # # Demo 7: READ UNCOMMITTED (DIRTY READ) # # # # # #
UPDATE radiology_db_reports SET clinician_notes = "change notes" WHERE patient_id = 25;
SELECT * FROM radiology_db_reports WHERE patient_id = 25;
-- Tab 1
START TRANSACTION;
UPDATE radiology_db_reports
SET clinician_notes = "nothing"
WHERE patient_id = 25;
-- Tab 2
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT clinician_notes FROM radiology_db_reports WHERE patient_id = 25;
COMMIT;
-- Tab 1
ROLLBACK;
-- Tab 2
SELECT * FROM radiology_db_reports WHERE patient_id = 25;

# # # # # # Demo 8: SERIALIZABLE - PREVENTING PHANTOM INSERT # # # # # #
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (26, 'LSS MRI 
No evidence of disc herniation. 
No signidant thecal sac or nerve root compression noted.');

-- Tab 1
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM radiology_db_reports WHERE patient_id >= 20;

-- Tab 2
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (27, 'L2-3: broad based right paramedin disc extrusion is noted slightly migrating downwards ');

-- Tab 1
COMMIT;
SELECT * FROM radiology_db_reports;

# # # # # # Demo 9: Watch global values / current session # # # # # #
SELECT @@GLOBAL.transaction_isolation AS global_iso,
       @@GLOBAL.transaction_read_only AS global_ro;

SELECT @@SESSION.transaction_isolation AS session_iso,
       @@SESSION.transaction_read_only AS session_ro;

