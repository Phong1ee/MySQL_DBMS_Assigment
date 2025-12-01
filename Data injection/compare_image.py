import hashlib

def file_hash(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()

print("Original:", file_hash("LOCALIZER_0_0001_001.ima"))
print("Retrieved:", file_hash("output_image.ima"))