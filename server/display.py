import cv2
import requests
import numpy as np

url = 'http://192.168.1.65:3000/video_feed'  # Замените на адрес вашего сервера

while True:
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        bytes_data = b''
        for chunk in response.iter_content(chunk_size=1024):
            bytes_data += chunk
            a = bytes_data.find(b'\xff\xd8')
            b = bytes_data.find(b'\xff\xd9')
            if a != -1 and b != -1:
                jpg = bytes_data[a:b + 2]
                bytes_data = bytes_data[b + 2:]
                frame = cv2.imdecode(np.frombuffer(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)
                cv2.imshow('Processed Frame', frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
    else:
        print('Error: Unable to fetch frame')

cv2.destroyAllWindows()