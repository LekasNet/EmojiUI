pip install opencv-python

pip install deepface



import cv2 ### pip install opencv-python 
 ## pip install opencv-contrib-python fullpackage

from deepface import DeepFace ## pip install deepface

faceCascade = cv2. CascadeClassifier (cv2.data. haarcascades + 'haarcascade_frontalface_default.xml')
                                      
cap = cv2.VideoCapture(1)
# Check if the webcam is opened correctly
if not cap.isOpened() :
    cap = cv2.VideoCapture (0)
if not cap.isOpened():
    raise IOError ("Cannot open webcam")
while True:
    ret, frame = cap.read()
    result = DeepFace.analyze(frame, actions = ['emotion'])
    gray = cv2.cvtColor(frame, cv2. COLOR_BGR2GRAY)
    
    #print (faceCascade. empty())
    
    faces = faceCascade.detectMultiScale (gray, 1.1,4)
    # Draw a rectangle around the faces
    for (x, y, w, h) in faces:
        cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
        
    font = CV2.FONT_HERSHEY_SIMPLEX
    cv2.putText(frame,
                predictions[0]['dominant_emotion'],
                (50, 50),
                font, 3,
                (0, 255, 0),
                2,
                cv2.LINE_4);
    cv2.imshow('Original video', frame)
    
    if cv2.waitKey(2) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
