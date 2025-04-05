import sqlite3
from sqlite3 import Error
from typing import List, Tuple, Any
from contextlib import closing
from datetime import datetime
from pathlib import Path
from datetime import timedelta

#Store file path for UserId, firstname, lastname, session token, past-paths
def getSQLiteCurser():
    connection = sqlite3.connect('hackku.db')
    return connection.cursor()



command1 = """ Create table if not exists users (
    UserId string primary key Not Null,
    FirstName string, 
    LastName string,
    Email string Not Null,
    SessionToken string,
) """

command2 =""" Create table if not exists past_paths
(
    UserId string,
    Path TEXT NOT NULL,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    foreign key (UserId) references users(UserId)
) """
<<<<<<< HEAD

cursor.execute(command1)
cursor.execute(command2)
connection.commit()
=======
>>>>>>> e79f7fef4c15276a286dccc2fed93eaf3e6572bd
