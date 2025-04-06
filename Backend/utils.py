import secrets
import os
from fastapi import UploadFile
import math

def getNewSessionToken():
    return secrets.token_hex(16)  # Generates a 32-character hexadecimal string


UPLOAD_BASE_DIR = "user_routes"

def save_route_file(user_email: str, fileContents: str, fileName):
    # Create a safe folder name based on the email
    safe_email = user_email.replace("@", "_at_").replace(".", "_dot_")
    folder_path = os.path.join(UPLOAD_BASE_DIR, safe_email)
    os.makedirs(folder_path, exist_ok=True)

    # Construct the file path
    file_path = os.path.join(folder_path, fileName)

    # Save the file
    with open(file_path, "wb") as f:
        f.write(fileContents)

    return file_path


def create_bounding_box(latitude, longitude, distance_miles):
    """
    Generates the coordinates for a bounding box around a given point.

    Args:
        latitude (float): Latitude of the center point in degrees.
        longitude (float): Longitude of the center point in degrees.
        distance_miles (float): Distance in miles from the center point to each side of the box.

    Returns:
        tuple: A tuple containing (min_longitude, min_latitude, max_longitude, max_latitude).
    """

    earth_radius_miles = 3958.8  # Radius of the Earth in miles

    # Convert latitude and longitude to radians
    lat_rad = math.radians(latitude)
    lon_rad = math.radians(longitude)

    # Angular distance in radians
    angular_distance = distance_miles / earth_radius_miles

    # Calculate min and max latitudes
    min_lat_rad = lat_rad - angular_distance
    max_lat_rad = lat_rad + angular_distance

    # Calculate delta longitude
    delta_lon_rad = math.asin(math.sin(angular_distance) / math.cos(lat_rad))

    # Calculate min and max longitudes
    min_lon_rad = lon_rad - delta_lon_rad
    max_lon_rad = lon_rad + delta_lon_rad

    # Convert back to degrees
    min_latitude = math.degrees(min_lat_rad)
    max_latitude = math.degrees(max_lat_rad)
    min_longitude = math.degrees(min_lon_rad)
    max_longitude = math.degrees(max_lon_rad)

    return [[min_latitude, min_longitude], [max_latitude, max_longitude]]


def haversine_miles(coord1, coord2):
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
    #unpack variables
    lat1, lon1 = coord1
    lat2, lon2 = coord2


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