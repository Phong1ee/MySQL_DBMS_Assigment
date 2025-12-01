import mysql.connector
import numpy as np
import json
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import io
from PIL import Image

from tensorflow.keras.applications import ResNet50
from tensorflow.keras.applications.resnet50 import preprocess_input


class RadiologyImageSearch:
    def __init__(self):
        self.db_config = {
            'host': '127.0.0.1',
            'user': 'root',
            'password': 'root123',
            'database': 'mydatabase'
        }
        self.model = self.load_model()
    
    def load_model(self):
        print("✓ Loading ResNet50...")
        return ResNet50(weights='imagenet', include_top=False, pooling='avg')
    
    def get_query_embedding(self, query_image_path):
        image = Image.open(query_image_path).convert('RGB')
        image = image.resize((224, 224))

        img = np.array(image)
        img = np.expand_dims(img, axis=0)
        img = preprocess_input(img)

        emb = self.model.predict(img, verbose=0)
        return emb.flatten().tolist()
    
    def search_by_image(self, query_image_path, top_k=10):
        print("\n=== SEARCH STARTED ===")

        # 1. Extract embedding
        query_emb = self.get_query_embedding(query_image_path)
        print(f"Query embedding dim: {len(query_emb)}")

        # 2. Load embeddings from DB
        conn = mysql.connector.connect(**self.db_config)
        cursor = conn.cursor()

        cursor.execute("""
            SELECT image_id, file_name, image_data, embedding
            FROM radiology_images
            WHERE embedding IS NOT NULL;
        """)

        rows = cursor.fetchall()
        print(f"Loaded {len(rows)} embeddings from database")

        similarities = []

        for row in rows:
            image_id, file_name, image_data, emb_json = row

            db_vec = json.loads(emb_json)

            # Fast cosine
            sim = cosine_similarity([query_emb], [db_vec])[0][0]

            similarities.append({
                "image_id": image_id,
                "file_name": file_name,
                "similarity": sim,
                "image_data": image_data
            })
        
        similarities.sort(key=lambda x: x["similarity"], reverse=True)

        cursor.close()
        conn.close()

        return similarities[:top_k]


searcher = RadiologyImageSearch()
results = searcher.search_by_image("normal-mri-lumbosacral-spine.jpg", top_k=10)

for r in results:
    print(r["image_id"], r["similarity"])