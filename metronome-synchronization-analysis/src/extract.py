import cv2
import math
import numpy as np
import matplotlib.pyplot as plt 

cap = cv2.VideoCapture('sample.MP4')
fps = cap.get(cv2.CAP_PROP_FPS) 
times = []
angles = []
frame_idx = 0


i = 1
while(i):
    ret, frame = cap.read()
    if ret == False:
        break
    
    frame_idx += 1
    t = frame_idx / fps
    times.append(t)
    
    
    height = frame.shape[0]
    width = frame.shape[1]

    hsv = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
    
    #HSV範囲
    lower_value = np.array([30, 70, 40])
    upper_value = np.array([80, 230, 230])
    
    #針の固定点座標調節
    #bar_x = 948
    #bar_y = height - 946
    bar_x = 983
    bar_y = height - 900
    
    #マスク画像の閾
    masked_image = cv2.inRange(hsv, lower_value, upper_value)

    #中央値フィルタ
    output_image = cv2.medianBlur(masked_image, 11)
    
    #centeroid
    moments_image = cv2.moments(output_image)
    #'m10':centeroid X,'m01':centeroid Y
    m00 = moments_image['m00']
    centroid_x, centroid_y = None, None
    if m00 != 0:
        centroid_x = int(moments_image['m10'] / m00)
        centroid_y = int(moments_image['m01'] / m00)
    
    centroid_coordinates = (-1, 1)

    
    if centroid_x != None and centroid_y != None:
        centroid_coordinates = (centroid_x, centroid_y)
        #黒のポイント描く
        cv2.circle(output_image, (centroid_x, centroid_y), 4, (0, 0, 0), -1)
    
    
    vector_x = centroid_x - bar_x
    vector_y = height - centroid_y - bar_y

    cosine_value = vector_y / math.sqrt(vector_x ** 2 + vector_y ** 2)
    theta = math.acos(cosine_value)

    if vector_x < 0:
        degree = -(math.degrees(theta))
    if vector_x >= 0:
        degree = math.degrees(theta)

    print (i,degree)
    angles.append(degree)
    i += 1

    cv2.imwrite('centroidframe.jpg', frame)
    cv2.imshow('centroid extracted', output_image)
    k = cv2.waitKey(1) & 0xFF
    if k == 27:
        break

cv2.destroyAllWindows()
plt.figure(figsize=(8,4))
plt.plot(times, angles)
plt.xlabel('Time (s)')          
plt.ylabel('Angle (°)')        
plt.grid(True)
plt.tight_layout()
plt.show()