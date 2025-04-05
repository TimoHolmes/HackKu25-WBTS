from fastapi import FastAPI, Query
from models import newUserCredentials
from sqlite import SQLliteDB
from utils import getNewSessionToken, IsValidAuthToken

app = FastAPI()
db = SQLliteDB()

@app.get("/test")
def test():
    print("test")
    return {"status" : 100}

'''
    @brief handles log in
    @param c - AppleCredintial pydantic model 
    @return status code 100 on success 400 on failure
'''
@app.post("/login")
async def login(c : newUserCredentials):
    return {"status" : 100}

@app.get("/getPastRoutes")
async def get_past_routes(UserId: str = Query(...), token: str = Query(...)):
    valid = IsValidAuthToken(token)
    if(not valid):
        return {"status" : 400, "info" : "invalid auth token"}
    results = db.GetPastRoutes(UserId)
    if not results:
        return {"status": 400, "info": "No routes found"}
    
    return {"status": 100, "routes": results}

@app.get("/getTopRatedRoutes")
async def get_top_rated_routes(Likes: str = Query(...), token: str = Query(...)):
    valid = IsValidAuthToken(token)
    if(not valid):
        return {"status" : 400, "info" : "invalid auth token"}
    results = db.GetTopRatedRoutes()
    if not results:
        return {"status": 400, "info": "No routes found"}
    return {"status": 100, "routes": results}


