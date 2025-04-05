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

    def checkUserExists(self, UserId):
        self.Cursor.execute("SELECT * FROM users WHERE UserId = ?", (UserId,))
        results = self.Cursor.fetchall()
        return (results != [])
    
    def SetNewSessionToken(self, UserId):
        sToken = getNewSessionToken()
        self.Cursor.execute(f"UPDATE users SET SessionToken = '{sToken}' WHERE UserId = '{UserId}'") # rewrite to match other executes
        self.Connection.commit()
        return sToken

    def InsertNewUser(self, c):
        sToken = getNewSessionToken()
        self.Cursor.execute("INSERT INTO users (UserId, FirstName, LastName, Email, SessionToken) VALUES (?, ?, ?, ?, ?)", (c.User, c.FirstName, c.LastName, c.Email, sToken))
        self.Connection.commit()
        return sToken
    
    def GetPastRoutes(self, UserId):
        self.Cursor.execute("SELECT * FROM Routes WHERE UserId = ?", (UserId,))
        rows = self.Cursor.fetchall()
        return [dict(row) for row in rows]
    
    def GetTopRatedRoutes(self): 
        self.Cursor.execute("SELECT * FROM Routes WHERE likes = Max(likes) ")
        rows = self.Cursor.fetchall()
        return [dict(row) for row in rows]


command1 = """ Create table if not exists users (
    UserId string primary key Not Null,
    FirstName string, 
    LastName string,
    Email string Not Null,
    SessionToken string,
) """

