import os
from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import FileResponse
from models import newUserCredentials, logInCredentials, routeInformation
from sqlite import SQLliteDB
from utils import getNewSessionToken, save_route_file
import hashlib

UPLOAD_BASE_DIR = "/path/to/upload/directory"

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
async def login(c : logInCredentials):
    userExists = db.checkUserExists(c.Email)
    if(not userExists):
        return {"status" : 400, "info" : "user does not exist"}
    
    passw = c.Password.encode("utf-8")
    hasher = hashlib.sha256()
    hasher.update(passw)
    digest = hasher.hexdigest()
    if(digest == db.getPassHashFromEmail(c.Email)):
        sessionToken = db.SetNewSessionToken(c.Email)
        return {"status" : 200, "Token" : sessionToken, "info" : "login accepted"}
    else:
        return {"status" : 400, "info" : "invalid password"}
        
@app.post("/newUser")
async def newUser(c: newUserCredentials):
    userExists = db.checkUserExists(c.Email)
    if(userExists):
        return {"status" : 400, "info" : "user already exists"}
    
    if(c.FirstName == None or c.LastName == None or c.Email == None or c.Password == None):
        return {"status" : 400, "info" : "empty field"}

    hasher = hashlib.sha256()
    c.Password = c.Password.encode("utf-8")
    hasher.update(c.Password)
    c.Password = hasher.hexdigest()

    stoken = db.InsertNewUser(c)
    return {"status" : 200, "Token": stoken, "info" : "user created"}


@app.get("/getPastRoutes")
async def get_past_routes(Email: str = Query(...), token: str = Query(...)):
    if(not db.checkToken(token)):
        return {"status" : 400, "info" : "invalid token"}
    results = db.GetPastRoutes(Email)
    if not results:
        return {"status": 400, "info": "No routes found"}
    return {"status": 200, "routes": results}

@app.get("/getTopRatedRoutes")
async def get_top_rated_routes(token:str = Query(...), Longitude: float = Query(...), Latitude: float = Query(...), Distance: float = Query(...)):
    results = db.GetTopRatedRoutes(token, Longitude, Latitude, Distance)
    if not results:
        return {"status": 400, "info": "No routes found"}
    return {"status": 200, "routes": results}

@app.get("/getRecentRoutes")
async def getRecentRoutes(token: str = Query(...), Longitude: float = Query(...), Latitude: float = Query(...), Distance: float = Query(...)):
    results = db.getRecentRoutes(Longitude, Latitude, Distance)

@app.post("/postRoute")
async def post_route(r: routeInformation):
    if(not db.checkToken(r.Tokenoken)):
        return {"status" : 400, "info" : "invalid token"}

    Path = save_route_file(r.Email, r.gpxFileContent, r.RouteName)
    db.PostRoute(r, Path)
    return {"status": 200, "info": "Route uploaded successfully", "filePath": Path}

@app.get('/routeByEmailAndName')
async def get_route_by_email_and_name(
    token: str = Query(...),
    Email: str = Query(...),
    RouteName: str = Query(...)
):
    if not db.checkToken(token):
        return {"status": 400, "info": "Invalid token"}

    route = db.getRouteByEmailAndName(Email, RouteName)
    if not route:
        return {"status": 400, "info": "Route not found"}

    db_file_path = route["FilePath"] 

    safe_email = Email.replace("@", "_at_").replace(".", "_dot_")
    file_path = os.path.join(UPLOAD_BASE_DIR, safe_email, db_file_path)

    if not os.path.exists(file_path):
        raise HTTPException(status_code=404, detail="GPX file not found")

    return FileResponse(
        path=file_path,
        media_type="application/gpx+xml",
        filename=os.path.basename(file_path)
    )