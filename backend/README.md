# Plant Care

Repo for Plant Care

Set up configuration

1. Install black formatter extension if not installed.
   https://marketplace.visualstudio.com/items?itemName=ms-python.black-formatter

2. Create .env file to store credentials and API keys in backend folder.

3. Setup virtual environment

- Navigate to backend folder
  I. Open the editor in fastapi-backend folder

or

II. Navigate terminal to fastapi-backend folder using below command from root dir

```bash
cd backend
```

- Use the following command to create a virtual environment:

```bash
python3.12 -m venv venv
```

- Activate virtual environment

I. in unix

```bash
source venv/bin/activate
```

II. in windows

```cmd
venv\Scripts\activate
```

- Install necessary libraries

```bash
pip install -r requirements.txt
```

4. Run code

- Debugging

```bash
uvicorn app.main:fast_api_app --reload
```

- Production server

```bash
fastapi run app\main.py
```
