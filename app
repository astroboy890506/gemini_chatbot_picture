import streamlit as st
from dotenv import load_dotenv
import os
import google.generativeai as genai
from PIL import Image

# Load environment variables from .env file
load_dotenv()

# Ensure the API key is set in the environment before running the script
api_key = os.getenv("GOOGLE_API_KEY")
if not api_key:
    st.error("Google API key not found in environment variables.")
    st.stop()

# Initialize the Google AI model
model = genai.GenerativeModel('gemini-pro-vision')

# Streamlit UI
st.title("Google Gemini Chatbot")

# Initialize session state for chat history
if 'chat_history' not in st.session_state:
    st.session_state.chat_history = []

# Function to get response from Google Gemini API
def get_response(prompt, image):
    try:
        response = model.generate_content(contents=[prompt, image])
        return response.text
    except Exception as e:
        st.error(f"Error invoking Google Gemini API: {e}")
        return None

# Function to display conversation
def display_conversation():
    for message in st.session_state.chat_history:
        st.write(f"{message['role']}: {message['content']}")

# File uploader for image
uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "jpeg", "png"])

# User input text area
user_input = st.text_area("Enter your query here:")

# Handling user interaction
if st.button("Send"):
    if not uploaded_file:
        st.error("Please upload an image!")
    elif user_input.strip() == "":
        st.error("Please enter a query!")
    else:
        with st.spinner("Please wait..."):
            image = Image.open(uploaded_file)
            response = get_response(user_input, image)
        if response:
            st.session_state.chat_history.append({"role": "User", "content": user_input})
            st.session_state.chat_history.append({"role": "Chatbot", "content": response})
            display_conversation()
        else:
            st.error("Failed to get a response from the chatbot.")

# Button to start a new conversation
if st.button("Start New Conversation"):
    st.session_state.chat_history = []
    st.experimental_rerun()

# Display the conversation history
display_conversation()
