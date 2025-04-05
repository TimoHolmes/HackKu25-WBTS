from fastapi import FastAPI, Query
from models import AppleCredential
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
async def login(c : AppleCredential):
    valid = IsValidAuthToken(c.IdToken)
    if(not valid):
        return {"status" : 400, "info" : "invalid jwt token"}
    
    if(c.Email != None):
        if(db.checkUserExists(c.User)):
            sToken = db.SetNewSessionToken(c.User)
            return {"status" : 100, "SessionToken": sToken, "info" : "login sucess"}
        sToken = db.InsertNewUser(c)
        print("account created succesfully")
        return {"status" : 100, "SessionToken" : {sToken}, "info" : "account created successfully"}
    
    exists = db.checkUserExists(c.User)

    if not exists:
        print("invalid login")
        return {"status" : 400, "info" : "Invalid login"}
    else:
        sToken = db.SetNewSessionToken(c.User)
        return {"status" : 100, "SessionToken": sToken, "info" : "login sucess"}

@app.get("/getPasRoutes")
async def get_past_routes(UserId: str = Query(...)):
    results = db.GetPastRoutes(UserId)
    if not results:
        return {"status": 400, "info": "No routes found"}
    
    return {"status": 100, "routes": results}