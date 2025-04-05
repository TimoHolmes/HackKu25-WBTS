from pydantic import BaseModel, Optional


class AppleCredential(BaseModel):
    User: str
    FirstName: Optional[str] = None
    LastName: Optional[str] = None
    email: Optional[str] = None
    
