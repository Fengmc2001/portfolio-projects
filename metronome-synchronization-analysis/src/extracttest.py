import cv2
import numpy as np
import math


cap = cv2.VideoCapture('sample.MP4')

i = 0
n = 5
N = 10

while i<n*N:
    ret, frame = cap.read()
    
    i += 1
    filename = '/Users/fengmc/projects/3/Experiment/1/centroidframea' + str(i) + '.jpg'
    if i % n == 0:
        cv2.imwrite(filename, frame)
        print(i, filename)
    
    k = cv2.waitKey(1) & 0xFF
    
    if k == 27:
        break

cv2.destroyAllWindows()
