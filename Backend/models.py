from pydantic import BaseModel
from typing import Optional


class AppleCredential(BaseModel):
    User: str
    FirstName: Optional[str] = None
    LastName: Optional[str] = None
    Email: Optional[str] = None

