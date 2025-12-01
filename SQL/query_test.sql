USE mydatabase;
SELECT COUNT(*) from radiology_db_reports;

SELECT 
    r.patient_id,
    r.clinician_notes,
    i.image_id,
    i.folder_name,
    i.file_name,
    i.image_data
FROM radiology_db_reports r
LEFT JOIN radiology_mri_images i 
    ON r.patient_id = i.patient_id
WHERE r.patient_id = 10;



