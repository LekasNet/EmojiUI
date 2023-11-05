import cv2 # pip install opencv-python
import matplotlib.pyplot as plt # pip install matplotlib, чисто для вывода 
from deepface import DeepFace # pip install deepface с версией python 3.11 


img = cv2.imread("/Downloads/scare-011.jpg") # читает изображение, путь укажи сам

#plt.imshow(img) # Выводит изображение как график

predictions = DeepFace.analyze(img_path = img, actions = ['emotion']) # сама нейронка которая все анализирует


#predictions[0]['dominant_emotion'] # Почему-то может быть как list, так и dict, если неправильно читается выводится, заменить на нижнюю строчку.

#predictions['dominant_emotion']

emotion = predictions[0]['dominant_emotion']

print(emotion)
