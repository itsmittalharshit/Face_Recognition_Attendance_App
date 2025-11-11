from flask import Flask, request, jsonify
import face_recognition
import numpy as np
import os
import cv2
from flask_cors import CORS
import pickle

app = Flask(__name__)
CORS(app)

KNOWN_FACES_DIR = 'known_faces'
ENCODINGS_FILE = 'encodings.pkl'

known_faces = []
known_names = []

# Load known encodings if available
if os.path.exists(ENCODINGS_FILE):
    with open(ENCODINGS_FILE, 'rb') as f:
        data = pickle.load(f)
        known_faces = data['encodings']
        known_names = data['names']

def save_encodings():
    with open(ENCODINGS_FILE, 'wb') as f:
        pickle.dump({'encodings': known_faces, 'names': known_names}, f)

@app.route('/register', methods=['POST'])
def register():
    name = request.form.get('name')
    file = request.files['image']

    if not name or not file:
        return jsonify({"status": "error", "message": "Missing name or image"}), 400

    img = face_recognition.load_image_file(file)
    encodings = face_recognition.face_encodings(img)

    if len(encodings) == 0:
        return jsonify({"status": "error", "message": "No face detected"}), 400

    # Save image in a folder
    user_folder = os.path.join(KNOWN_FACES_DIR, name)
    os.makedirs(user_folder, exist_ok=True)
    image_path = os.path.join(user_folder, f"{name}.jpg")
    cv2.imwrite(image_path, cv2.cvtColor(img, cv2.COLOR_RGB2BGR))

    # Save encoding
    known_faces.append(encodings[0])
    known_names.append(name)
    save_encodings()

    return jsonify({"status": "success", "message": f"User {name} registered successfully!"})


@app.route('/recognize', methods=['POST'])
def recognize():
    file = request.files['image']
    img = face_recognition.load_image_file(file)
    encodings = face_recognition.face_encodings(img)

    if len(encodings) == 0:
        return jsonify({"status": "error", "message": "No face detected"})

    match_results = face_recognition.compare_faces(known_faces, encodings[0])
    if True in match_results:
        name = known_names[match_results.index(True)]
        return jsonify({"status": "success", "name": name})
    else:
        return jsonify({"status": "error", "message": "Unknown face"})


@app.route('/')
def home():
    return "Flask Face Recognition API Running!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
