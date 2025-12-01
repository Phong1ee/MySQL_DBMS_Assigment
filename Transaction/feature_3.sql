USE mydatabase;

# # # # # # # # # # # # # # # SAVEPOINT, ROLLBACK TO SAVEPOINT, and RELEASE SAVEPOINT Statements # # # # # # # # # # # # # # #

# # # # # # Demo 1: SAVEPOINT + ROLLBACK TO SAVEPOINT # # # # # #
START TRANSACTION;
-- Mark savepoint
SAVEPOINT sp;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (7, 'LSS MRI
diffuse disc bulge noted  at L4-L5 level , compressing the thecal sac and exit canals.
small central disc protrusion noted at L5-S1 level.
no significant spinal canal narrowing noted.');
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (8, 'LSS MRI :
Feature of muscle spasm.
Mild diffuse disc bulge noted at L4/L5 level , with  mild compresing thecal sac,
NB:
ABout 7 cm,  mixed   pelvic cyst noted,  correlate with US .');
SELECT * FROM radiology_db_reports;
-- Rollback to savepoint: Cancel changes after savepoint
ROLLBACK TO SAVEPOINT sp;
SELECT * FROM radiology_db_reports;
COMMIT;
SELECT * FROM radiology_db_reports;

# # # # # # Demo 2: SAVEPOINT + ROLLBACK TO SAVEPOINT # # # # # #
START TRANSACTION;

INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (9, 'LSS MRI
No evidence of disc herniation.
No significant thecal sac or nerve root compression noted.');
SAVEPOINT sp_v1;

INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (10, 'LSS MRI
no evidence of disc herniation.
no significant thecal sac or nerve root compression noted.');
SAVEPOINT sp_v2;

UPDATE radiology_db_reports SET clinician_notes = 'change note' WHERE patient_id = 10;
SELECT * FROM radiology_db_reports;

-- Rollback savepoint sp_v2
ROLLBACK TO SAVEPOINT sp_v2;
SELECT * FROM radiology_db_reports;

-- Rollback savepoint sp_v1
ROLLBACK TO SAVEPOINT sp_v1;
SELECT * FROM radiology_db_reports;

COMMIT;

# # # # # # Demo 3: Savepoints have the same name # # # # # #
START TRANSACTION;

INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (11, 'LSS MRI :
About 3*2 cm lesion with inhomogenous signal intensity noted just posterior to L1 veretbral body ,largely compressing the Rt side of the thecal sac. contrast study is advsied.
Diffuse disc bulge noted at L4/L5 level, compresing the thecal sac and encroaching upon both neural canals.
Wide base disc bulge noted at L5/S1 level, extending to Lt lateral recess , compressin the thecal sac and nerve roots, more to left side, associated with ligamnetum flavum hyperatrophy. 
  ');
SAVEPOINT sp_v3;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (12, 'LSS MRI
Rt paracentral disc protrusion noted at L4-L5 level, compressing the thecal sac.
Adequate spinal canal.');
SAVEPOINT sp_v3;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (13, 'L4-5 broad based central and left paracentral disc protrusion is noted compressing thecal sac and narrowing left neural foramen./// L5-S1: broad based degenerative central disc bulge is noted indenting thecal sac but not causing significant nerve root compression or foraminal narrowing.//// dehydrated L4-5 and L5-S1 intervetrebral discs./// vertebral bone marrow signal reconversion is noted.');

SELECT * FROM radiology_db_reports;
ROLLBACK TO SAVEPOINT sp_v3;
SELECT * FROM radiology_db_reports;

COMMIT;

# # # # # # Demo 4: RELEASE SAVEPOINT # # # # # #
START TRANSACTION;

INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (14, 'LSS MRI :
Feature of muscle spasm.
No significant disc herniation or protrusion seen.
Adequate thecal sac ');
SAVEPOINT sp_v4;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (15, 'Lumbosacral MRI
Mild disc bulge noted at L5-S1 level
Small right foraminal disc protrusion with annular tear is noted
No significant thecal sac or nerve root compression noted');

RELEASE SAVEPOINT sp_v4;
ROLLBACK TO SAVEPOINT sp_v4;

# # # # # # Demo 5: Delete savepoint(s) when COMMIT/ROLLBACK # # # # # #
START TRANSACTION;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (16, 'Lumbosacral MRI
Features of muscle spasm
Dissicating   lower disc space noted
-Central and left paracentral disc protrusion noted at L4-L5 level compressing the thecal sac and Lt exit nerve root 
-Diffuse Disc bulges noted at the L5-S1 level , mild compressing the thecal sac and exiting nerve root.');
SAVEPOINT sp_v5;
COMMIT;
ROLLBACK TO SAVEPOINT sp_v5;

START TRANSACTION;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (17, 'L5-S1: left paramedian disc protrusion on top of degenerative annular disc bulge causing compression of thecal sac, compressing left S1 nerve root within lateral recess, compressing left L5 nerve root within left neural foramen and narrowing right neural foramen./// L4-5: annular disc bulge is noted compressing thecal sac and narrowing both neural foramina/// L3-4: left posterolateral disc bulge is notedslightly narrowing left neural foramen.');
SAVEPOINT sp_v6;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (18, 'nan');
SAVEPOINT sp_v7;
ROLLBACK; -- Cancel all savepoints
ROLLBACK TO SAVEPOINT sp_v6;


