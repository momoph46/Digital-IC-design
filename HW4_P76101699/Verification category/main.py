import numpy as np
import cv2

# img_name = 'shin'

# img=cv2.imread('./'+img_name+'.jpg',0)
img = cv2.imread('./image.jpg',0)
img=cv2.resize(img,dsize=(32,31),interpolation=cv2.INTER_CUBIC)

#print(img.shape)
#print(type(img))

#print(len(img))
#print(len(img[0]))
height = img.shape[0]
width = img.shape[1]

for i in range(1,height,2): 
    #newimg.append(img_array[i-1])
    newline = np.empty(32,dtype=int)
    for j in range(0,width):
        if (j==0):
            e0 = (int(img[i-1][0])+int(img[i+1][0]))/2
            newline[j]=int(e0)
        elif (j==31):
            e31 = (int(img[i-1][31])+int(img[i+1][31]))/2
            #newline.append(int(e31))
            newline[j]=int(e31)
        else :
            a = int(img[i-1][j-1])
            b = int(img[i-1][j])
            c = int(img[i-1][j+1])
            d = int(img[i+1][j-1])
            e = int(img[i+1][j])
            f = int(img[i+1][j+1])
            #elist = [(b,e,1),(a,f,2),(c,d,3)]
            #elist.sort(key=lambda x: (abs(x[0]-x[1]),x[2]))
            elist = [(b,e),(a,f),(c,d)]
            elist.sort(key=lambda x: (abs(x[0]-x[1])))
            #newline.append(int((elist[0][0]+elist[0][1])/2))
            e1 = int((elist[0][0]+elist[0][1])/2)
            newline[j] = e1
    
    #newimg.append(newline)        
    img[i] = newline


#testimage = '0pat_'+img_name+'.dat'
#goldimage = '0exp_'+img_name+'.dat'

testimage = 'img.dat'
goldimage = 'golden.dat'

f = open(testimage,'w')
for i,line in enumerate(img):
    if (i%2==0):
        for j in line:
            wrt_char = hex(j)[2:4]
            f.write(wrt_char+'\n')         
f.close()

d = open(goldimage,'w')
for i in img:
    for j in i:
        wrt_char = hex(j)[2:4]
        d.write(wrt_char+'\n')

d.close()

