import sqlite3
from sqlite3 import Error
from typing import List, Tuple, Any
from contextlib import closing
from datetime import datetime
from pathlib import Path
from datetime import timedelta
from utils import getNewSessionToken, haversine_miles

#Store file path for UserId, firstname, lastname, session token, past-paths

class SQLliteDB:
    def __init__(self):
        self.Connection = sqlite3.connect('hackku.db')
        self.Connection.row_factory = sqlite3.Row
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
    
    def GetTopRatedRoutes(self, long, lat, distance): 
        self.Cursor.execute("SELECT * FROM routes order by likes")
        rows = self.Cursor.fetchall()

        returnList = []

        for tuple in rows:
            tupleDist = haversine_miles(lat, long, tuple(4), tuple(5))
            if max(distance - 1, 0) < tupleDist and tupleDist < distance + 1:
                returnList.append(tuple)
            

        return returnList

    def PostRoute(self, r, FilePath):
        self.Cursor.execute("INSERT INTO routes (Email, RouteName, Distance, Incline, Longitude, Latitude, Likes, FilePath) " \
        "VALUES (?,?,?,?,?,?,?)", (r.Email, r.RouteName, r.Distance, r.Incline, r.Longitude, r.Latitude, 0, FilePath))
        self.Connection.commit()

    def checkToken(self,  token):
        self.Cursor.execute("Select * from users where SessionToken = ?", (token, ))
        return (self.Cursor.fetchall() != [])

    def getRecentRoutes(self, long, lat, distance):
        self.Cursor.execute("SELECT * FROM Routes ORDER BY CreatedTime DESC")
        rows = self.Cursor.fetchall()

        returnList = []

        for tuple in rows:
            tupleDist = haversine_miles(lat, long, tuple(4), tuple(5))
            if max(distance - 1, 0) < tupleDist and tupleDist < distance + 1:
                returnList.append(tuple)
        return returnList
    
    def getRouteByEmailAndName(self, Email, route_name):
        self.Cursor.execute("SELECT * FROM routes WHERE Email = ? AND RouteName = ?", (Email, route_name))
        return self.Cursor.fetchone()

command1 = """ Create table if not exists users (
    UserId string primary key Not Null,
    FirstName string, 
    LastName string,
    Email string Not Null,
    SessionToken string,
) """

