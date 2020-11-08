import os
import sys
from datetime import datetime, timedelta
sys.path.append('/usr/src/app')
# fastapi
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from passlib.context import CryptContext
from jose import JWTError, jwt
from typing import Optional
# Local
from app.schema import UserInDB, Token, TokenData, Event, NewUser, User, UpdateUser, TokenWithUser
from app.schema import aitoConnection
# server
import uvicorn


# to get a string like this run:
# openssl rand -hex 32
SECRET_KEY = "27dda44d2976e6f13f29c601d210a3e21dfb7974bd60267ea5849d309295453f"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 9999999

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI()
aito_conn = aitoConnection()


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


def authenticate_user(username: str, password: str):
    user = aito_conn.get_user(username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except JWTError:
        raise credentials_exception
    user = aito_conn.get_user(username=token_data.username)
    if user is None:
        raise credentials_exception
    return user


@app.post("/token", response_model=TokenWithUser)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    current_user = aito_conn.get_user(user.username)
    return {"access_token": access_token, "token_type": "bearer", "user": current_user}


@app.post("/users/create", response_model=User)
async def create_user(from_data: NewUser):
    from_data.password = get_password_hash(from_data.password)
    username = aito_conn.insert_user(from_data)
    if not username:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Such user is already exist"
        )
    user = aito_conn.get_user(username)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="There is no such user"
        )
    return user


@app.get("/")
async def hello():
    return "Hello World"


@app.get("/users/me/", response_model=UserInDB)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return aito_conn.get_user(current_user.username)


@app.get("/event/{event_id}", response_model=Event)
async def get_event(event_id: str, current_user: User = Depends(get_current_user)):
    if aito_conn.is_event_complite(event_id):
        event = aito_conn.get_currently_event(event_id)
        event['isComplete'] = 1
        top5 = aito_conn.get_top5_by_event_id(int(event_id))
        preds = [aito_conn.get_rest_info(top5[i]) for i in range(5)]
        users = aito_conn.get_users_by_event_id(int(event_id))
        event["preds"] = preds
        event["users"] = users["users"]
        event['preds'] = [event['preds'][0]]
        return Event(**event)
    res = aito_conn.get_currently_event(int(event_id))
    users = aito_conn.get_users_by_event_id(int(event_id))
    top5 = aito_conn.get_top5_by_event_id(int(event_id))
    preds = [aito_conn.get_rest_info(top5[i]) for i in range(5)]
    res["users"] = users["users"]
    res["preds"] = preds
    return Event(**res)


@app.post("/event/{event_id}/add", response_model=Event)
async def add_2_event(users : dict, event_id : int, current_user: User = Depends(get_current_user)):
    if "users" not in users or aito_conn.get_user(users["users"][0]) == False:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not valid values, 'users' must included or not exist user"
        )
    aito_conn.add_people_event(event_id, users["users"])
    users = aito_conn.get_users_by_event_id(int(event_id))
    top5 = aito_conn.make_predictions(users["users"])
    aito_conn.create_voting(event_id,top5,users["users"])
    res = aito_conn.get_currently_event(event_id)
    res["users"] = users["users"]
    preds = [aito_conn.get_rest_info(top5[i]) for i in range(5)]
    res["preds"] = preds
    return Event(**res)


@app.post("/even/create", response_model=Event)
async def create_event(from_data: Event, current_user: User = Depends(get_current_user)):
    event_id = aito_conn.insert_event(from_data, current_user)
    top5 = aito_conn.make_predictions([current_user.username])
    current_event = aito_conn.get_currently_event(event_id)
    preds = [aito_conn.get_rest_info(top5[i]) for i in range(5)]
    current_event["preds"] = preds
    current_event["users"] = [current_user.username]
    aito_conn.create_voting(event_id, top5, [current_user.username])
    return Event(**current_event)


@app.post("/users/get_all_events", response_model=dict)
async def get_events_by_user_id(current_user: User = Depends(get_current_user)):
    return aito_conn.get_events_by_user_id(current_user.username)


@app.post("/users/{username}/update_profile", response_model=dict)
async def update_user_profile(from_data: UpdateUser, current_user: User = Depends(get_current_user)):
    aito_conn.update_user_profile(current_user, from_data)
    return {"Message": "done"}


@app.post("/rest/search", response_model=dict)
async def search_rest(rest_name : str, current_user: User = Depends(get_current_user)):
    res = aito_conn.search_places_by_name(rest_name)
    return {"rests": res}


@app.post("/ranking/votes")
async def vote(from_data: dict, current_user: User = Depends(get_current_user)):
    if "vote" not in from_data or "placeID" not in from_data or "eventID" not in from_data:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not valid values, 'eventI, placeID, vote' must included"
        )
    event = aito_conn.vote(int(from_data["vote"]), current_user.username, int(from_data["eventID"]), from_data["placeID"])
    return Event(**event)


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", log_level="info", port=int(os.environ.get('PORT', '5000')))