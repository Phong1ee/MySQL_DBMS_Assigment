CREATE TABLE radiology_db_reports_noindex AS SELECT * FROM radiology_db_reports;
CREATE TABLE radiology_studies_noindex AS SELECT * FROM radiology_studies;
CREATE TABLE radiology_series_noindex AS SELECT * FROM radiology_series;
CREATE TABLE radiology_images_noindex AS SELECT * FROM radiology_series;

-- Before Indexing
EXPLAIN analyze
SELECT s.study_id, se.series_id, i.image_id, i.file_name
FROM radiology_studies s
JOIN radiology_series se ON se.study_id = s.study_id
JOIN radiology_images i  ON i.series_id = se.series_id
WHERE s.patient_id = 1
ORDER BY s.study_date DESC;

EXPLAIN FORMAT=JSON
SELECT s.study_id, se.series_id, i.image_id, i.file_name
FROM radiology_studies s
JOIN radiology_series se ON se.study_id = s.study_id
JOIN radiology_images i  ON i.series_id = se.series_id
WHERE s.patient_id = 1
ORDER BY s.study_date DESC;

ALTER TABLE radiology_studies
  ADD INDEX idx_studies_patient_date (patient_id, study_date);

ALTER TABLE radiology_series
  ADD INDEX idx_series_study (study_id);

ALTER TABLE radiology_images
  ADD INDEX idx_images_series (series_id);

-- After indexing
EXPLAIN analyze
SELECT s.study_id, se.series_id, i.image_id, i.file_name
FROM radiology_studies s
JOIN radiology_series se ON se.study_id = s.study_id
JOIN radiology_images i  ON i.series_id = se.series_id
WHERE s.patient_id = 1
ORDER BY s.study_date DESC;

EXPLAIN FORMAT=JSON
SELECT s.study_id, se.series_id, i.image_id, i.file_name
FROM radiology_studies s
JOIN radiology_series se ON se.study_id = s.study_id
JOIN radiology_images i  ON i.series_id = se.series_id
WHERE s.patient_id = 1
ORDER BY s.study_date DESC;






