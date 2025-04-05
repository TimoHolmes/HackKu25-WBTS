from pydantic import BaseModel
from typing import Optional


class newUserCredentials(BaseModel):
    FirstName: str
    LastName: str
    Email: str 
    Password: str


class logInCredentials(BaseModel):
    Email: str
    Password: str

