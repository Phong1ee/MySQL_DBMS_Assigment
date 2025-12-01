USE mydatabase;

# # # # # # # # # # # # # # # LOCK INSTANCE FOR BACKUP and UNLOCK INSTANCE Statements # # # # # # # # # # # # # # #

# # # # # # Demo 1: DML still runs when LOCK INSTANCE FOR BACKUP # # # # # #
-- Connection tab 1
LOCK INSTANCE FOR BACKUP;
-- Connection tab 2
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (17, 'L5-S1: left paramedian disc protrusion on top of degenerative annular disc bulge causing compression of thecal sac, compressing left S1 nerve root within lateral recess, compressing left L5 nerve root within left neural foramen and narrowing right neural foramen./// L4-5: annular disc bulge is noted compressing thecal sac and narrowing both neural foramina/// L3-4: left posterolateral disc bulge is notedslightly narrowing left neural foramen.');

UPDATE radiology_db_reports
SET clinician_notes = 'change note'
WHERE patient_id = 17;

DELETE FROM radiology_db_reports WHERE patient_id = 17;

SELECT * FROM radiology_db_reports;

# # # # # # Demo 2: DDL is blocked # # # # # #
-- Connection tab 1
LOCK INSTANCE FOR BACKUP;
-- Connection tab 2
ALTER TABLE radiology_db_reports
ADD COLUMN image VARCHAR(20);
-- Connection tab 1
UNLOCK INSTANCE;
-- Connection tab 2
SELECT * FROM radiology_db_reports;
ALTER TABLE radiology_db_reports
DROP image;

# # # # # # Demo 3: FLUSH TABLES WITH READ LOCK # # # # # #
LOCK INSTANCE FOR BACKUP;
FLUSH TABLES radiology_db_reports WITH READ LOCK;
-- SELECT is accepted
SELECT * FROM radiology_db_reports;
-- INSERT is not accepted
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (19, 'L1-2: central disc bulge is noted indenting thecal sac/// L3-4: right posterolateral disc bulge is noted with end-plate osteophyte formation causing compression of right nerve root within neural foramen. L5-S1: right paramedian disc bulge is noted indenting thecal sac.');

UNLOCK TABLES;
UNLOCK INSTANCE;
-- INSERT is accepted
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (19, 'L1-2: central disc bulge is noted indenting thecal sac/// L3-4: right posterolateral disc bulge is noted with end-plate osteophyte formation causing compression of right nerve root within neural foramen. L5-S1: right paramedian disc bulge is noted indenting thecal sac.');



