from flask import Flask, request, Response, jsonify, url_for, send_from_directory
import cv2
import numpy as np
from deepface import DeepFace
from random import randint

app = Flask(__name__)
app.config['SERVER_NAME'] = '192.168.1.65:3000'


def prediction(img):
    # Выполняем анализ с помощью DeepFace
    predictions = DeepFace.analyze(img, actions=['emotion'])
    # Возвращаем доминирующую эмоцию
    emotion = predictions[0]['dominant_emotion']
    return emotion


@app.route('/images/<filename>')
def get_image(filename):
    # Убедитесь, что путь к папке static корректен
    return send_from_directory('static', filename)


@app.route('/quest', methods=['GET'])
def get_quest():
    # Вы можете добавить логику для выбора случайного квеста или возврата следующего из списка
    quests = [
        {
            "image_url": url_for('get_image', filename='img1.jpg', _external=True),
            "options": ["Радость", "Грусть", "Гнев", "Отвращение"],
            "answer": "Радость"
        },
        {
            "image_url": url_for('get_image', filename='img2.jpg', _external=True),
            "options": ["Радость", "Грусть", "Гнев", "Отвращение"],
            "answer": "Грусть"
        },
        # Добавьте столько квестов, сколько нужно
    ]
    quest = quests[randint(0, 1)]  # Здесь просто берём первый квест для примера
    return jsonify(quest)


@app.route('/upload', methods=['POST'])
def upload():
    if request.method == 'POST':
        # Получаем изображение из тела запроса
        file = request.files['image'].read()
        npimg = np.frombuffer(file, np.uint8)  # Используем frombuffer вместо fromstring

        # Преобразуем numpy массив в изображение
        img = cv2.imdecode(npimg, cv2.IMREAD_COLOR)

        # Получаем предсказание эмоции
        emotion = prediction(img)

        # Возвращаем результат в ответе
        if emotion == "disgust":
            return Response(f"Predicted emotion: {emotion}", status=201)
        elif emotion == "fear":
            return Response(f"Predicted emotion: {emotion}", status=202)
        elif emotion == "happy":
            return Response(f"Predicted emotion: {emotion}", status=203)
        elif emotion == "sad":
            return Response(f"Predicted emotion: {emotion}", status=204)
        elif emotion == "surprise":
            return Response(f"Predicted emotion: {emotion}", status=205)
        elif emotion == "neutral":
            return Response(f"Predicted emotion: {emotion}", status=206)
        elif emotion == "angry":
            return Response(f"Predicted emotion: {emotion}", status=207)
        else:
            return Response(f"Face doesn't recognized", status=200)
    else:
        return Response("Invalid request", status=400)


if __name__ == '__main__':
    app.run(host='192.168.1.65', port=3000, debug=True)
