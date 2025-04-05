import secrets
import requests
import jwt
import os
from fastapi import UploadFile


def getNewSessionToken():
    return secrets.token_hex(16)  # Generates a 32-character hexadecimal string


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
