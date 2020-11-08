from datetime import datetime
import pandas as pd

from pydantic import BaseModel
from typing import Optional

from aito.client import AitoClient
import aito.api as aito_api


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None


class TokenWithUser(Token):
    user: dict


class User(BaseModel):
    username: str
    latitude: int
    longitude: int
    full_name: Optional[str] = None
    email: str
    ambience: Optional[str] = None
    cuisine: Optional[str] = None
    drink_level: Optional[str] = None
    interest: Optional[str] = None
    payment: Optional[str] = None
    smoker: Optional[str] = None
    transport: Optional[str] = None


class NewUser(BaseModel):
    username: str
    email: str
    password: str
    full_name: Optional[str] = None


class UpdateUser(BaseModel):
    ambience: Optional[str] = None
    cuisine: Optional[str] = None
    drink_level: Optional[str] = None
    interest: Optional[str] = None
    payment: Optional[str] = None
    smoker: Optional[str] = None
    transport: Optional[str] = None
    full_name: Optional[str] = None


class UserInDB(User):
    hashed_password: str


class Event(BaseModel):
    id: Optional[int] = None
    title: str
    description: Optional[str] = None
    date: Optional[datetime] = None
    owner: Optional[str] = None
    users: Optional[list] = None
    preds: Optional[list] = None
    isComplete: Optional[int] = None


class Ranking(BaseModel):
    eventID: int
    placeID: str
    username: str
    vote: int


class aitoConnection:
    def __init__(self):
        AITO_INSTANCE_URL = "https://junction-food.aito.app/"
        AITO_API_KEY = "aQB6FLR4kR9P8zBj5chm33fU3Nhc9PaZ6vu3s4A8"
        self.client = AitoClient(
            instance_url=AITO_INSTANCE_URL,
            api_key=AITO_API_KEY
        )

    def insert_event(self, event: Event, user: User):
        query = {
            "limit": 1,
            "select": ["id"],
            "from": "events",
            "orderBy": {
                "$desc": "id"
            }
        }
        try:
            new_id = aito_api.generic_query(client=self.client, query=query)['hits'][0]['id'] + 1
        except IndexError:
            new_id = 0
        entries = \
            [
                {
                    "id": new_id,
                    "title": event.title,
                    "description": event.description,
                    "date": str(datetime.now()),
                    "owner": user.username,
                }
            ]

        aito_api.upload_entries(
            client=self.client,
            table_name="events",
            entries=entries)
        self.add_people_event(new_id, [user.username])
        return new_id

    def get_currently_event(self, id):
        query = {
            "select": ["id", "title", "description", "date", "owner"],
            "from": "events",
            "where": {
                "id": int(id)
            }
        }
        try:
            event = aito_api.generic_query(client=self.client, query=query)['hits'][0]
        except IndexError:
            raise IndexError
        return event

    def add_people_event(self, id: int, users: list):
        # query = {
        #     "select": ["username"],
        #     "from": "userevents",
        #     "where": {
        #         "id": id
        #     }
        # }
        # try:
        #     exist_users = aito_api.generic_query(client=self.client, query=query)['hits'][0]
        # except IndexError:
        #     raise IndexError
        for user in users:
            entries = \
                [
                    {
                        "username": user,
                        "eventId": id,
                    }
                ]
            aito_api.upload_entries(
                client=self.client,
                table_name="usersevents",
                entries=entries)

    def get_users_by_event_id(self, event_id: int):
        query = {
            "from": "usersevents",
            "where": {
                "eventId": event_id
            }
        }
        users = aito_api.generic_query(client=self.client, query=query)['hits']
        res = {
            "users": [item["username"] for item in users]
        }
        return res

    def get_events_by_user_id(self, username: str):
        query = {
            "from": "usersevents",
            "select": ["eventId.id", "eventId.date", "eventId.description", "eventId.owner", "eventId.title"],
            "where": {
                "username": username
            }
        }
        events = aito_api.generic_query(client=self.client, query=query)["hits"]
        events = [dict((key[8:], val) for key, val in zip(events[i], events[i].values())) for i in range(len(events))]
        res = {
            "events": [item for item in events]
        }
        for item in res["events"]:
            users = self.get_users_by_event_id(item["id"])
            item["users"] = users["users"]
        return res

    def get_random_lat(self):
        return 5

    def get_random_lon(self):
        return 8

    def insert_user(self, user: NewUser):
        query = {
            "limit": 1,
            "select": ["username"],
            "from": "users",
            "where": {
                "username": user.username
            }
        }
        try:
            user_in_db = aito_api.generic_query(client=self.client, query=query)['hits'][0]['username']
            if user.username == user_in_db:
                return False
        except IndexError:
            new_id = 0
        entries = \
            [
                {
                    "latitude": self.get_random_lat(),
                    "longitude": self.get_random_lon(),
                    "username": user.username,
                    "full_name": user.full_name,
                    "email": str(user.email),
                    "hashed_password": user.password,
                }
            ]
        aito_api.upload_entries(
            client=self.client,
            table_name="users",
            entries=entries)
        return user.username

    def get_user(self, username : str):
        query = {
            "limit": 1,
            "select": ["username", "latitude", "longitude", "full_name", "email", "hashed_password",
                       "ambience", "cuisine", "drink_level", "interest", "payment", "smoker",
                       "transport"],
            "from": "users",
            "where": {
                "username": username
            }
        }
        try:
            user = aito_api.generic_query(client=self.client, query=query)['hits'][0]
        except IndexError:
            return False
        return UserInDB(**user)

    def update_user_profile(self, current: UserInDB, updated: UpdateUser):
        entries = \
            [
                {
                    "latitude": self.get_random_lat(),
                    "longitude": self.get_random_lon(),
                    "username": current.username,
                    "full_name": updated.full_name,
                    "email": str(current.email),
                    "hashed_password": current.hashed_password,
                    "ambience": updated.ambience,
                    "cuisine": updated.cuisine,
                    "drink_level": updated.drink_level,
                    "interest": updated.interest,
                    "payment": updated.payment,
                    "smoker": updated.smoker,
                    "transport": updated.transport,
                }
            ]
        query = {
            "from": "users",
            "where": {
                "username": current.username
            }
        }
        aito_api.delete_entries(self.client, query=query)
        aito_api.upload_entries(
            client=self.client,
            table_name="users",
            entries=entries)

    def create_voting(self, event_id: int, top_rest: list, users_list: list):
        del_quer = {
            "from": "voting",
            "where": {"eventID": event_id}
        }
        aito_api.delete_entries(self.client, del_quer)
        for username in users_list:
            new_voting = pd.DataFrame({"eventID": event_id, "placeID": top_rest, "vote": 0, "username": username})
            aito_api.upload_entries(client=self.client, table_name='voting', entries=new_voting.to_dict(orient='records'))

    def get_user_by_username(self, username):
        query = {
            "from": "users",
            "where": {
                "username": username,
            }
        }
        res = aito_api.generic_query(client=self.client, query=query)
        return res['hits'][0]

    def make_predictions(self, users):
        df_list = []
        for username in users:
            user = self.get_user_by_username(username)
            smoking_area = 'permitted' if user['smoker'] == 'true' else 'not permitted'
            alcohol = "No_Alcohol_Served" if user['drink_level'] == 'abstemious' else 'Wine-Beer'
            payment = {"$match": user['payment']}
            cuisine = user['cuisine']
            rec_query = {
                "limit": 130,
                "from": "places",
                "recommend": "placeID",
                "goal":
                    {
                        "$multiply": [
                            {"$p": {"smoking_area": smoking_area}},
                            {"$p": {"alcohol": alcohol}},
                            {"$p": {"payment": payment}},
                            {"$p": {"cuisine": cuisine}}
                        ]

                    }
            }
            # if user['dress_preference'] == 'informal' or user['dress_preference'] == 'casual':
            #     rec_query['goal']['dress_preference'] = 'informal'
            # elif user['dress_preference'] == 'formal':
            #     rec_query['goal']['dress_preference'] = 'formal'
            # elif user['dress_preference'] == 'formal':
            #     rec_query['goal']['dress_preference'] = 'formal'

            if user['transport'] == 'car owner':
                rec_query['goal']['$multiply'].append(
                    {
                        "$p": {
                            "$or": [
                                {"parking_lot": "public"},
                                {"parking_lot": "yes"}

                            ]
                        }
                    }
                )
            preds = aito_api.recommend(client=self.client, query=rec_query)
            new_df = pd.DataFrame({
                "score": [d['$score'] for d in preds['hits']],
                "placeID": [d['feature'] for d in preds['hits']]
            }).set_index('placeID').sort_values('score', ascending=False)
            new_df.score = range(130)
            df_list.append(new_df)
        top5 = list(pd.concat(df_list, axis=1).sum(axis=1).sort_values().head().index)
        return top5

    def get_rest_info(self, rest_id):
        get_users = {
            "from": "places",
            "where": {
                "placeID": rest_id
            }
        }
        users = aito_api.generic_query(client=self.client, query=get_users)
        return users['hits'][0]

    def get_top5_by_event_id(self, event_id: int):
        top5_quer = {
            "limit": 5,
            "from": "voting",
            "select": ["placeID"],
            "where":
                {
                    "eventID": event_id
                }
        }
        top5 = aito_api.generic_query(client=self.client, query=top5_quer)['hits']
        top5 = [item['placeID'] for item in top5]
        return top5

    def search_places_by_name(self, name: str):
        get_users = {
            "limit": 10,
            "from": "places",
            "where":
                {
                    "name": {
                        "$startsWith": name
                    }
                }
        }
        users = aito_api.generic_query(client=self.client, query=get_users)
        return users['hits']

    def vote(self, vote : int, username: str, event_id: int, place_id: str):
        del_quer = {
            "from": "voting",
            "where": {
                "username": username,
                "eventID": int(event_id),
                "placeID": place_id
            }
        }
        aito_api.delete_entries(self.client, del_quer)
        new_voting = pd.DataFrame({"eventID": [event_id], "placeID": [place_id], "vote": [vote], "username": [username]})
        aito_api.upload_entries(client=self.client, table_name='voting', entries=new_voting.to_dict(orient='records'))
        query = {
            "from": "voting",
            "where": {
                "eventID": int(event_id)
            }
        }
        res = aito_api.generic_query(client=self.client, query=query)['hits']
        vote_res = [item['vote'] for item in res]
        if 0 not in vote_res:
            vote_is_done = pd.DataFrame({"eventID": [event_id], "isComplete": [1]})

            aito_api.upload_entries(client=self.client, table_name='progress',
                                    entries=vote_is_done.to_dict(orient='records'))
            event = self.get_currently_event(event_id)
            event['isComplete'] = 1
            top5 = self.get_top5_by_event_id(int(event_id))
            preds = [self.get_rest_info(top5[i]) for i in range(5)]
            users = self.get_users_by_event_id(int(event_id))
            event["preds"] = preds
            event["users"] = users["users"]
            event['preds'] = event['preds'][0]
        else:
            event = self.get_currently_event(event_id)
            top5 = self.get_top5_by_event_id(int(event_id))
            users = self.get_users_by_event_id(int(event_id))
            preds = [self.get_rest_info(top5[i]) for i in range(5)]
            event["preds"] = preds
            event["users"] = users["users"]
        return event

    def is_event_complite(self, event_id: int):
        query = {
            "from": "progress",
            "where": {
                "eventID": int(event_id)
            }
        }
        is_complete = aito_api.generic_query(client=self.client, query=query)['hits']
        if len(is_complete) > 0:
            return True
        else:
            return False