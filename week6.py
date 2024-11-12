import cv2
import numpy

#get image name and read with cv2
iname=input("Enter image path: ")
iread=cv2.imread(iname, cv2.IMREAD_COLOR)
#greyscale
igrey=cv2.cvtColor(iread,cv2.COLOR_BGR2GRAY)
#gaussian blur
igb=cv2.GaussianBlur(src=igrey,ksize=(7,7),sigmaX=1.5)
#hough transform
crcls=cv2.HoughCircles(igb,cv2.HOUGH_GRADIENT,1,20,param1=50,param2=30,minRadius=0,maxRadius=40)
crcls=numpy.uint16(numpy.around(crcls))
#result handling
for i in crcls[0,:]:
    cv2.circle(igb,(i[0],i[1]),i[2],(255,0,0),2)
    cv2.circle(igb,(i[0],i[1]),2,(0,255,0),3)
cv2.imshow('circles',igb)
cv2.waitKey(0)
cv2.destroyAllWindows()