
import os
from fastapi import UploadFile

UPLOAD_BASE_DIR = "user_routes"

def save_route_file(user_email: str, file: UploadFile):
    # Create a safe folder name based on the email
    safe_email = user_email.replace("@", "_at_").replace(".", "_dot_")
    folder_path = os.path.join(UPLOAD_BASE_DIR, safe_email)
    os.makedirs(folder_path, exist_ok=True)

    # Construct the file path
    file_path = os.path.join(folder_path, file.filename)

    # Save the file
    with open(file_path, "wb") as f:
        f.write(file.file.read())

    return file_path