from fastapi import FastAPI
from models import AppleCredential
from sqlite import getSQLiteCurser
from utils import getNewSessionToken

app = FastAPI()
dbCurser = getSQLiteCurser()

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
    if(c.Email != None):
        sToken = getNewSessionToken()
        dbCurser.execute(f"insert into users ({c.User}, {c.FirstName}, {c.LastName}, {c.Email}, {sToken})")
        return {"status" : 100, "SessionToken" : {sToken}, "info" : "account created successfully"}
    
    dbCurser.execute(f"SELECT * FROM users WHERE UserId = {c.User}")
    results = dbCurser.fetchall()
    if not results:
        return {"status" : 400, "info" : "Invalid login"}
    else:
        sToken = getNewSessionToken()
        dbCurser.execute(f"UPDATE users SET SessionToken = {sToken} WHERE UserId = {c.User}")
        return {"status" : 100, "SessionToken": sToken, "info" : "login sucess"}


