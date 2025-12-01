CREATE TABLE radiology_db_reports_noindex AS SELECT * FROM radiology_db_reports;
CREATE TABLE radiology_studies_noindex AS SELECT * FROM radiology_studies;
CREATE TABLE radiology_series_noindex AS SELECT * FROM radiology_series;
CREATE TABLE radiology_images_noindex AS SELECT * FROM radiology_series;

-- Before Indexing
EXPLAIN analyze
SELECT COUNT(i.image_id) AS image_count
FROM radiology_images i
JOIN radiology_series se ON se.series_id = i.series_id
WHERE se.study_id = 10;


EXPLAIN FORMAT=JSON
SELECT COUNT(i.image_id) AS image_count
FROM radiology_images i
JOIN radiology_series se ON se.series_id = i.series_id
WHERE se.study_id = 10;

ALTER TABLE radiology_series
  ADD INDEX idx_series_study (study_id);

ALTER TABLE radiology_images
  ADD INDEX idx_images_series (series_id);

-- After indexing
EXPLAIN analyze
SELECT COUNT(i.image_id) AS image_count
FROM radiology_images i
JOIN radiology_series se ON se.series_id = i.series_id
WHERE se.study_id = 10;


EXPLAIN FORMAT=JSON
SELECT COUNT(i.image_id) AS image_count
FROM radiology_images i
JOIN radiology_series se ON se.series_id = i.series_id
WHERE se.study_id = 10;






