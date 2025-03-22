import os

import openai
from google import genai
from google.genai import types

openai.api_key = os.getenv("OPENAI_API_KEY")

client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))


def get_openai_response(message: str):
    # Send the message to OpenAI get the response and return the response
    response = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": message}],
    )

    return response.choices[0].message.content


def get_gemini_response(message: str, sensor_data: dict):
    # Send the message to Gemini get the response and return the response
    # Only run this block for Vertex AI API

    content = types.Content(
        role="user",
        parts=[
            types.Part.from_text(text=message),
        ],
    )

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=[content],
        config=types.GenerateContentConfig(
            system_instruction=f"The user have a farm where the weather is {sensor_data}. Please use the weather data to answer the user's question. Units of the weather data are {'{'} Soil_temperature: Celsius, temperature: Celsius, humidity: %, Smoke: ppm, Soil_moisture: %, Light_sense: lux {'}'}. No need to weather data in your response. Just answer the user's question.",
            max_output_tokens=500,
            temperature=1,
            top_p=0.95,
            top_k=40,
            response_mime_type="text/plain",
        ),
    )
    print(response.text)

    return response.text.strip()
