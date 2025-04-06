from pydantic import BaseModel
from typing import Optional
from fastapi import UploadFile


class newUserCredentials(BaseModel):
    FirstName: str
    LastName: str
    Email: str 
    Password: str


class logInCredentials(BaseModel):
    Email: str
    Password: str


class routeInformation(BaseModel):
    Email: str
    RouteName: str
    Distance: str
    Incline: str
    Longitude: str
    Latitude: str
    FilePath: str
    gpxFile: UploadFile


