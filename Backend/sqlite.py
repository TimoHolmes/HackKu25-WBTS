import sqlite3
from sqlite3 import Error
from typing import List, Tuple, Any
from contextlib import closing
from datetime import datetime
from pathlib import Path

#Store file path for UserId, firstname, lastname, session token, past-paths
def getSQLiteCurser():
    connection = sqlite3.connect('hackku.db')
    return connection.cursor()



command1 = """ Create table if not exists users (
    UserId string primary key Not Null,
    FirstName string, 
    LastName string,
    Email string Not Null,
    SessionToken string
) """
