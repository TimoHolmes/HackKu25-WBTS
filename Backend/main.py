from fastapi import FastAPI
from models import AppleCredential

app = FastAPI()

@app.get("/test")
def test():
    return {"status" : 100}

'''
    @brief handles log in
    @param AppleCredintial - pydantic model 
    @return status code 100 on success 400 on failure
'''
@app.post("/login")
async def login(c : AppleCredential):
    return {"staus" : 400}