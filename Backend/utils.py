import secrets
import requests
import jwt

def getNewSessionToken():
    return secrets.token_hex(16)  # Generates a 32-character hexadecimal string

APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"
APPLE_ISSUER = "https://appleid.apple.com"
YOUR_CLIENT_ID = ""


def IsValidAuthToken(identity_token: str):
    try:
        header = jwt.get_unverified_header(identity_token)
        kid = header['kid']
        response = requests.get(APPLE_JWKS_URL)
        response.raise_for_status()
        public_keys = response.json()['keys']
        public_key = None
        for key in public_keys:
            if key['kid'] == kid:
                public_key = jwt.algorithms.RSAAlgorithm.from_jwk(key)
                break
        if not public_key:
            print(f"Public key with kid '{kid}' not found.")
            return False

        payload = jwt.decode(
            identity_token,
            public_key,
            algorithms=["RS256"],
            issuer=APPLE_ISSUER,
            audience=YOUR_CLIENT_ID,
            options={"require": ["exp", "sub", "aud", "iss"]}
        )
        # Optionally perform additional checks on 'iat', 'nbf', 'nonce'
        return True
    except (jwt.ExpiredSignatureError, jwt.InvalidIssuerError,
            jwt.InvalidAudienceError, jwt.InvalidSignatureError,
            jwt.MissingClaimError, requests.exceptions.RequestException) as e:
        print(f"JWT validation failed: {e}")
        return False



