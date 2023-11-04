! pip install fer
! pip install tensorflow>=1.7 opencv-contrib-python==3.3.0.9

! pip install tensorflow-gpu\>=1.7.0
! pip install ffmpeg moviepy 



from fer import FER
import cv2

img = cv2.imread("/kaggle/input/images-5/photo_2021-06-15_13-18-37.jpg")
detector = FER()
detector.detect_emotions(img)
