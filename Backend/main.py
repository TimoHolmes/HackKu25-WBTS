from fastapi import FastAPI, Query
from models import AppleCredential
from sqlite import SQLliteDB
from utils import getNewSessionToken, IsValidAuthToken
from post_route import save_route_file

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

@app.post("/postRoute")
async def post_routw(UserId: str = Query(...), 
                     Path: str = Query(...), 
                     PathName: str = Query(...), 
                     PathIncline: str = Query(...), 
                     PathLength: str = Query(...), 
                     token: str = Query(...)):
    valid = IsValidAuthToken(token)
    if(not valid):
        return {"status" : 400, "info" : "invalid auth token"}
    Path = save_route_file(UserId, Path)
    db.PostRoute(UserId, PathName, Path, PathIncline, PathLength)
    return {"status": 100, "info": "Route uploaded successfully", "filePath": Path}
