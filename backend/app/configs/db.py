import os

import firebase_admin  # type: ignore


def init_db():
    # Step 1: Initialize Firebase app
    try:
        firebase_admin.get_app()
        print("Loaded firebase app")

    except ValueError:
        print(os.getenv("FIREBASE_URL"))
        cred = firebase_admin.credentials.Certificate(
            "agro-farming-cccf3-firebase-adminsdk-fbsvc-4291b2a0d1.json"
        )  # Replace with your file name
        firebase_admin.initialize_app(
            cred,
            {"databaseURL": os.getenv("FIREBASE_URL")},
        )

        print("Initialized firebase app")
