CREATE DATABASE mydatabase;
USE mydatabase;

CREATE TABLE radiology_db_reports (
    patient_id INT PRIMARY KEY,
    clinician_notes TEXT
);

CREATE TABLE radiology_studies (
    study_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,
    study_name VARCHAR(255),     
    study_date DATE,              
    study_time TIME,              
    FOREIGN KEY (patient_id) REFERENCES radiology_db_reports(patient_id)
);

CREATE TABLE radiology_series (
    series_id INT AUTO_INCREMENT PRIMARY KEY,
    study_id INT,
    series_name VARCHAR(255),
    FOREIGN KEY (study_id) REFERENCES radiology_studies(study_id)
);


CREATE TABLE radiology_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    series_id INT,
    file_name VARCHAR(255),
    image_data LONGBLOB,         
    FOREIGN KEY (series_id) REFERENCES radiology_series(series_id)
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Radiologists Report.csv'
INTO TABLE radiology_db_reports
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(patient_id, clinician_notes);

SELECT COUNT(*) from radiology_db_reports;

SELECT COUNT(*) from radiology_images;


USE mydatabase;
SELECT 
    i.image_id,
    i.file_name,
    i.image_data,
    st.study_date,
    st.study_time,
    st.study_name,
    s.series_name,
    r.patient_id
FROM radiology_images i
JOIN radiology_series s ON i.series_id = s.series_id
JOIN radiology_studies st ON s.study_id = st.study_id
JOIN radiology_db_reports r ON st.patient_id = r.patient_id
WHERE r.patient_id = 10;

SELECT image_data
FROM radiology_images
WHERE image_id = 1
INTO DUMPFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/output_image.ima';





