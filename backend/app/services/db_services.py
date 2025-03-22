from firebase_admin import db  # type: ignore


def get_sensor_data():

    # Reference the 'Sensor' path in the database
    ref = db.reference("Sensor")

    # Fetch sensor data
    return ref.get()
