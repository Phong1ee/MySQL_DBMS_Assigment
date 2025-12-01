USE mydatabase;

# # # # # # # # # # # # # # # START TRANSACTION, COMMIT and ROLLBACK Commands # # # # # # # # # # # # # # #

# # # # # # Demo 1: START TRANSACTION + COMMIT  + ROLLBACK # # # # # #
-- Commit data of patient_id = 1
START TRANSACTION;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (1, 'L4-5: degenerative annular disc bulge is noted more to the left side compressing thecal sac, compressing left nerve root and narrowing right neural foramen. // Evidence of hyperintense signal within the annulus fibrosus at left paramedian/posterolateral area which probably represents a torn annulus.');
COMMIT;
SELECT * FROM radiology_db_reports;
-- Cannot rollback because data is committed
ROLLBACK;
SELECT * FROM radiology_db_reports;
-- Commit data of patient_id = 2
START TRANSACTION;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (2, 'No evidence of disc herniation.
No significant thecal sac or nerve root compression noted.');
SELECT * FROM radiology_db_reports;
-- Can rollback because data hasn't committed
ROLLBACK;
SELECT * FROM radiology_db_reports;

# # # # # # Demo 2: autocommit = 0 # # # # # #
SELECT @@autocommit;
-- Data exist because autocommit = 1
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (3, 'LSS MRI
Features of muscle spasm.
small central  disc protrusion noted at L5-S1 level abutting the thecal sac.
no significant thecal  sac or nerve root compression noted. ');
SELECT * FROM radiology_db_reports;
DELETE FROM radiology_db_reports WHERE patient_id = 3;
-- Set autocommit = 0
SET autocommit = 0;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (3, 'LSS MRI
Features of muscle spasm.
small central  disc protrusion noted at L5-S1 level abutting the thecal sac.
no significant thecal  sac or nerve root compression noted. ');
SELECT * FROM radiology_db_reports;
COMMIT;

# # # # # # Demo 3: READ ONLY and READ WRITE # # # # # #
-- READ WRITE mode
START TRANSACTION READ WRITE;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (4, 'Feature of muscle spasm.
Diffuse disc bulges noted at L4/L5 &L5/S1 levels, mildly compressing the thecal sac and encroaching exit nerve roots ');
COMMIT;
SELECT * FROM radiology_db_reports;
-- READ ONLY mode
START TRANSACTION READ ONLY;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (5, 'LSS MRI :
Feature of muscle spasm.
Diffuse disc bulge noted ar L4/L5 level ,mildly compressing the thecal sac and both exit nerve roots 
');

# # # # # # Demo 4: WITH CONSISTENT SNAPSHOT # # # # # #
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION WITH CONSISTENT SNAPSHOT;
SELECT * FROM radiology_db_reports;

-- Error when INSERT INTO
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (6, 'LSS MRI :
Feature of muscle spasm.
Diffuse disc bulge noted at L4/L5 level, mild compressing thecal sac and both nerve roots .
Wide base disc bulges noted at L5/S1 level, mild compressing thecal sac and both nerve roots ');

ROLLBACK;

# # # # # # Demo 5: BEGIN vs START TRANSACTION # # # # # #
BEGIN;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (6, 'LSS MRI :
Feature of muscle spasm.
Diffuse disc bulge noted at L4/L5 level, mild compressing thecal sac and both nerve roots .
Wide base disc bulges noted at L5/S1 level, mild compressing thecal sac and both nerve roots ');
SELECT * FROM radiology_db_reports;
COMMIT;




