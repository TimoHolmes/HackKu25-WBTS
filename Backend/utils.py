import secrets
import os
from fastapi import UploadFile
import math

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


def haversine_miles(lat1, lon1, lat2, lon2):
    """
    Calculates the great circle distance between two points on the Earth
    using the Haversine formula, with the result in miles.

    Args:
        lat1 (float): Latitude of the first point in degrees.
        lon1 (float): Longitude of the first point in degrees.
        lat2 (float): Latitude of the second point in degrees.
        lon2 (float): Longitude of the second point in degrees.

    Returns:
        float: The distance between the two points in miles.
    """
    # Radius of the Earth in miles
    R = 3958.8

    # Convert degrees to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)

    # Differences in coordinates
    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad

    # Haversine formula
    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    distance = R * c

    return distance