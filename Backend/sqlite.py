import sqlite3
from sqlite3 import Error
from typing import List, Tuple, Any
from contextlib import closing
from datetime import datetime
from pathlib import Path
from datetime import timedelta
from utils import getNewSessionToken

#Store file path for UserId, firstname, lastname, session token, past-paths

class SQLliteDB:
    def __init__(self):
        self.Connection = sqlite3.connect('hackku.db')
        self.Cursor = self.Connection.cursor()

    def checkUserExists(self, Email):
        self.Cursor.execute("SELECT * FROM users WHERE Email = ?", (Email,))
        results = self.Cursor.fetchall()
        return (results != [])
    
    def getPassHashFromEmail(self, Email):
        self.Cursor.execute("SELECT PassHash FROM users WHERE Email = ?", (Email, ))
        return self.Cursor.fetchall()[0][0]
    
    def SetNewSessionToken(self, Email):
        sToken = getNewSessionToken()
        self.Cursor.execute(f"UPDATE users SET SessionToken = '{sToken}' WHERE Email = '{Email}'") # rewrite to match other executes
        self.Connection.commit()
        return sToken

    def InsertNewUser(self, c):
        sToken = getNewSessionToken()
        self.Cursor.execute("INSERT INTO users (Email, FirstName, LastName, PassHash, SessionToken) VALUES (?, ?, ?, ?, ?)", (c.Email, c.FirstName, c.LastName, c.Password, sToken))
        self.Connection.commit()
        return sToken
    
    def GetPastRoutes(self, Email):
        self.Cursor.execute("SELECT * FROM Routes WHERE Email = ?", (Email ,))
        rows = self.Cursor.fetchall()
        return [dict(row) for row in rows]
    
    def GetTopRatedRoutes(self): 
        self.Cursor.execute("SELECT * FROM Routes WHERE likes = Max(likes) ")
        rows = self.Cursor.fetchall()
        return [dict(row) for row in rows]
    
    def PostRoute(self, r):
        self.Cursor.execute("INSERT INTO ROUTES (Email, RouteName, Distance, Incline, Longitude, Latitude, Likes, FilePath) " \
        "VALUES (?,?,?,?,?,?,?)", (r.Email, r.RouteName, r.Distance, r.Incline, r.Longitude, r.Latitude, 0,r.FilePath))

    def checkToken(self, token):
        self.Cursor.execute("Select * from users where SessionToken = ?", (token, ))
        return (self.Cursor.fetchall() != [])



command1 = """ Create table if not exists users (
    UserId string primary key Not Null,
    FirstName string, 
    LastName string,
    Email string Not Null,
    SessionToken string,
) """

