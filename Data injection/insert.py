import os
from datetime import datetime

base_dir = r"C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\01_MRI_Data"

output_sql = "bulk_insert.sql"

with open(output_sql, "w", encoding="utf-8") as f:
    f.write("USE test_1;\n\n")

    for patient_folder in sorted(os.listdir(base_dir)):
        patient_path = os.path.join(base_dir, patient_folder)
        if not os.path.isdir(patient_path):
            continue

        try:
            patient_id = int(patient_folder)
        except ValueError:
            continue  


        f.write(f"INSERT IGNORE INTO radiology_db_reports (patient_id, clinician_notes) "
                f"VALUES ({patient_id}, NULL);\n")

        for study_folder in os.listdir(patient_path):
            study_path = os.path.join(patient_path, study_folder)
            if not os.path.isdir(study_path):
                continue

            parts = study_folder.split("_")
            study_date, study_time = "NULL", "NULL"

            # Detect date and time
            for part in parts:
                if part.isdigit() and len(part) == 8:  
                    try:
                        study_date = datetime.strptime(part, "%Y%m%d").strftime("'%Y-%m-%d'")
                    except Exception:
                        pass
                elif part.isdigit() and len(part) == 6: 
                    try:
                        study_time = datetime.strptime(part, "%H%M%S").strftime("'%H:%M:%S'")
                    except Exception:
                        pass

            f.write(f"INSERT INTO radiology_studies (patient_id, study_name, study_date, study_time) "
                    f"VALUES ({patient_id}, '{study_folder}', {study_date}, {study_time});\n")
            f.write("SET @last_study_id = LAST_INSERT_ID();\n")

            for series_folder in os.listdir(study_path):
                series_path = os.path.join(study_path, series_folder)
                if not os.path.isdir(series_path):
                    continue

                f.write(f"INSERT INTO radiology_series (study_id, series_name) "
                        f"VALUES (@last_study_id, '{series_folder}');\n")
                f.write("SET @last_series_id = LAST_INSERT_ID();\n")

                for file_name in os.listdir(series_path):
                    if not file_name.lower().endswith(".ima"):
                        continue

                    file_path = os.path.join(series_path, file_name).replace("\\", "/")

                    f.write(f"INSERT INTO radiology_images (series_id, file_name, image_data) "
                            f"VALUES (@last_series_id, '{file_name}', LOAD_FILE('{file_path}'));\n")

print(f" SQL file generated: {output_sql}")
