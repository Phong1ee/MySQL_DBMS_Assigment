import mysql.connector
import numpy as np
import json
import io
import nibabel as nib
from PIL import Image
import tensorflow as tf
from tensorflow.keras.applications.resnet50 import ResNet50, preprocess_input
from tensorflow.keras.models import Model
import pydicom
from pydicom.filebase import DicomBytesIO

# -----------------------------------------
# Load pretrained model (ResNet50)
# -----------------------------------------
base_model = ResNet50(weights="imagenet", include_top=True)
model = Model(inputs=base_model.input, outputs=base_model.layers[-2].output)

# -----------------------------------------
# Connect MySQL
# -----------------------------------------
def get_connection():
    return mysql.connector.connect(
        host="127.0.0.1",
        user="root",
        password="root123",  # hoặc mật khẩu bạn đã đặt
        database="mydatabase"
    )

# -----------------------------------------
# Convert MRI .ima (Siemens/NIfTI) to PNG
# -----------------------------------------
def ima_to_image(image_bytes):
    try:
        ds = pydicom.dcmread(DicomBytesIO(image_bytes))
        pixel = ds.pixel_array

        # normalize 0-255
        pixel = (pixel - pixel.min()) / (pixel.max() - pixel.min())
        pixel = (pixel * 255).astype(np.uint8)

        return Image.fromarray(pixel)
    except Exception as e:
        print("IMA decode failed:", e)
        return None

# -----------------------------------------
# Generate embedding from PIL image
# -----------------------------------------
def get_embedding(pil_img):
    pil_img = pil_img.convert("RGB")
    pil_img = pil_img.resize((224, 224))

    arr = np.array(pil_img)
    arr = np.expand_dims(arr, axis=0)
    arr = preprocess_input(arr)

    embedding = model.predict(arr)
    return embedding.flatten().tolist()

# -----------------------------------------
# Main embedding pipeline
# -----------------------------------------
def process_images():
    conn = get_connection()
    cursor = conn.cursor(buffered=True)

    cursor.execute("""
        SELECT image_id, image_data 
        FROM radiology_images
        WHERE embedding IS NULL
        LIMIT 10000;
    """)

    rows = cursor.fetchall()
    print(f"Found {len(rows)} images needing embeddings")

    for image_id, image_data in rows:
        print(f"Processing image_id {image_id} ...")

        pil_img = ima_to_image(image_data)
        if pil_img is None:
            print("Skipping (decode error)")
            continue

        embedding = get_embedding(pil_img)

        embedding_json = json.dumps(embedding)

        cursor.execute("""
            UPDATE radiology_images 
            SET embedding = %s 
            WHERE image_id = %s;
        """, (embedding_json, image_id))
        conn.commit()

    cursor.close()
    conn.close()

if __name__ == "__main__":
    process_images()
