import secrets
import requests
import jwt

def getNewSessionToken():
    return secrets.token_hex(16)  # Generates a 32-character hexadecimal string




