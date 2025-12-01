USE mydatabase;

# # # # # # # # # # # # # # # LOCK TABLES and UNLOCK TABLES Statements # # # # # # # # # # # # # # #

# # # # # # Demo 1: READ Lock # # # # # #
-- Connection tab 1
LOCK TABLES radiology_db_reports READ;
SELECT * FROM radiology_db_reports;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (19, 'L1-2: central disc bulge is noted indenting thecal sac/// L3-4: right posterolateral disc bulge is noted with end-plate osteophyte formation causing compression of right nerve root within neural foramen. L5-S1: right paramedian disc bulge is noted indenting thecal sac.');
-- Connection tab 2
SELECT * FROM radiology_db_reports;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (20, 'Compression fracture is noted involving D12 body with compression of thecal sac and indentation of spinal cord at this level and maximum posterior displacement of posterior border of vertebral body by about 6.5mm. This fracture is believed to be pathological due to the mottled appearance of vertebral bodies. L4-5: secondary lumbar canal stenosis is noted due to degenerative annular disc bulge along with hypertrophy of facet joints and ligamenta flaca. compression of right L4 nerve root within right neural foramen due to the above mentioned disc bulge is also noted. L5-S1: degenerative annular disc bulge more toward the right side causing compression of thecal sac, compression of right L5 nerve root within right neural foramen and narrowing of left neural foramen. Diffusely altered signal of vertebral bone marrow; further evaluation is advised.');
-- Connection tab 1
UNLOCK TABLES;  
SELECT * FROM radiology_db_reports;

# # # # # # Demo 2: WRITE Lock # # # # # #
-- Connection tab 1
LOCK TABLES radiology_db_reports WRITE;
SELECT * FROM radiology_db_reports;
INSERT INTO radiology_db_reports VALUES (4, 'row 4');
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (21, 'L5-S1: left paramedian disc protrusion on top of degenerative annular disc bulge with end-plate osteophytes formation causing compression of thecal sac, compression of left S1 nerve root within lateral recess, and  narrowing of  neural foramina. ');
UPDATE radiology_db_reports SET clinician_notes = 'change note' WHERE patient_id = 1;
-- Connection tab 2
SELECT * FROM radiology_db_reports;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (22, 'Lumbosacral MRI
Features of muscle spasm 
Central and left paracentral disc protrusion noted at the level of L4-L5
Significantly compressing the thecal sac and the left exit nerve root 
and  desiccative disc material noted .');
-- Connection tab 1
UNLOCK TABLES;
SELECT * FROM radiology_db_reports;

# # # # # # Demo 3: Combining LOCK TABLES with a Transaction & ROLLBACK Does Not Release the Lock # # # # # #
-- Connection tab 1
SET autocommit = 0;
LOCK TABLES radiology_db_reports WRITE;
INSERT INTO radiology_db_reports (patient_id, clinician_notes) VALUES (23, 'L4-l5 L5-S1: diffuse disc bulges compressing the thecal sac and encroaching exit canals.');
-- Connection tab 2
SELECT * FROM radiology_db_reports;
-- Connection tab 1
ROLLBACK;
-- Connection tab 2
SELECT * FROM radiology_db_reports;
-- Connection tab 1
UNLOCK TABLES; 
-- Connection tab 2
SELECT * FROM radiology_db_reports;

# # # # # # Demo 4: Error “Table was not locked with LOCK TABLES” & alias # # # # # #
UNLOCK TABLES;
LOCK TABLES radiology_db_reports READ;

SELECT * FROM radiology_db_reports; -- Success
SELECT * FROM radiology_studies; -- Error
UNLOCK TABLES;



