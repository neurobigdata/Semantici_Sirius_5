from sklearn.linear_model import LinearRegression
#from sklearn import linear_model
import numpy as np
Time_words = open('Time_words.txt', 'r', encoding='utf-8') #Данные от швейцаров (текст)
A1 = Time_words.readlines()

sc=0 # счетчик столбцов
ssc = 0 # обозначает\определяет промежуток
Matrix_TW = [[0]*3 for i in range (len(A1))] #Матрица соответствия слова и времени его произношения
for j in range(len(A1)):
    pr1 = A1[j].find(' ') #Ищем первый пробел
    pr2 = A1[j].rfind(' ') #Ищем последний пробел
    Matrix_TW[j][0] = int(A1[j][:pr1]) #первому элементу матрицы присваиваем набор символов до первого пробела 
    Matrix_TW[j][1] = int(A1[j][pr1+1:pr2]) #второму элементу матрицы присваиваем набор символов с первого пробела до последнего
    if j==len(A1)-1: #Убираем \n
        Matrix_TW[j][2] = A1[j][pr2+1:]
    else:
        Matrix_TW[j][2] = A1[j][pr2+1:len(A1[j])-1]
        i=0
scet1 = 0
Dop_mass = [[0]*2 for i in range (30000)] #Дополнительный массив
while i<len(Matrix_TW): #определяем расположение слово относительно двух границ временного промежутка: рассматриваем 4 случая
    if Matrix_TW[i][0]>ssc*3000 and Matrix_TW[i][1]<(ssc+1)*3000: #слово полностью содержится в одном промежутке
        sc+=1
        Dop_mass[scet1][0]=ssc+1
        Dop_mass[scet1][1]=(Matrix_TW[i][2])
        scet1+=1
        i+=1
    elif Matrix_TW[i][0]>ssc*3000 and Matrix_TW[i][1]>(ssc+1)*3000: 
        sc+=1
        Dop_mass[scet1][0]=ssc+1
        Dop_mass[scet1][1]=Matrix_TW[i][2]
        ssc+=1
        scet1+=1
    elif Matrix_TW[i][0]<ssc*3000 and Matrix_TW[i][1]>(ssc+1)*3000:
        sc+=1
        ssc+=1
        Dop_mass[scet1][0]=ssc+1
        Dop_mass[scet1][1]=Matrix_TW[i][2]
        scet1+=1
    else:
        sc+=1
        Dop_mass[scet1][0]=ssc+1
        Dop_mass[scet1][1]=Matrix_TW[i][2]
        i+=1
        scet1+=1

Ok_matr = [[0]*sc for i in range (1004)] #Окончательная матрица

kslov = open('kslov.txt', 'r', encoding='utf-8') #Данные от швейцаров (корпус нормализованных слов)
A2 = kslov.readlines()
Dicts = dict()
for i in range (len(A2)): # файл => словарь
    pr1 = A2[i].find(' ')
    if i==len(A2)-1:
        Dicts[A2[i][pr1+1:]]=int(A2[i][:pr1])
    else:
        Dicts[A2[i][pr1+1:len(A2[i])-1]] = int(A2[i][:pr1])
srez_slov = open('srez_slov.txt', 'r', encoding='utf-8') #Данные от левых
A3 = srez_slov.readlines()
for i in range (len(A3)):
    A3[i].rstrip()
A32 = []
for i in range (len(A3)): #файл => двумерный массив
    A32.append(list(map(float, A3[i].split())))
priz_slovo = open('priz_slovo.txt', 'r') #Данные семантиков 
A3 = priz_slovo.readlines()
for i in range (len(A3)):
    A3[i].rstrip()
A33 = []
for i in range (len(A3)): #файл => двумерный массив
    A33.append(list(map(float, A3[i].split())))
Dop_mass = np.array(Dop_mass)
Dop_mass = Dop_mass.T #Транспонируем 
for s in range (len(Ok_matr[0])):
    Ok_matr[0][s]=int(Dop_mass[0][s])
    Ok_matr[1][s]=A32[1][Ok_matr[0][s]-1]
    #print(Ok_matr[1002][s])
    Ok_matr[1002][s]=Dop_mass[1][s]
    sqq = Dicts[Ok_matr[1002][s]]
    for k in range (0,1000):
        Ok_matr[k+2][s] = A33[k+1][sqq-1]
        
#print(Ok_matr)

#------



X_train = [[0]*sc for i in range (len(Ok_matr)-3)]

cl = 0
for i in range (1,len(Ok_matr)-2):
    X_train[cl] = Ok_matr[i]
    cl += 1
X_train = np.array(X_train)
X_train = X_train.T
def linear_regressor(X_train, data, Ok_matr):
    y_train = [[0]*3 for i in range (sc)] #*2-требует изменения(кол-во врем. промежутков для каждого слова)
    #print(y_train)

    cl=0 # счетчик строк в y_train
    for j in Ok_matr[0]:
        y_train[cl] = data[j-1]
        cl += 1

    y_train = np.array(y_train)    
    #print(y_train) #создан ок.вар y_train

    


    lr = LinearRegression(fit_intercept=False)
    lr.fit(X_train,y_train)
    
    return lr.coef_

data = np.loadtxt('X1.txt') #первый испытуемый
data = data.T
lreg = linear_regressor(X_train, data, Ok_matr)

 data = np.loadtxt('X2.txt')#второй
 data = data.T
 lreg = linear_regressor(X_train, data, Ok_matr)

 data = np.loadtxt('X3.txt')#3
 data = data.T
 lreg = linear_regressor(X_train, data, Ok_matr)

 data = np.loadtxt('X4.txt')
 data = data.T
 lreg = linear_regressor(X_train, data, Ok_matr)
 from sklearn.decomposition import PCA
pca = PCA()
lreg = np.array(lreg)
XPCAreduced = pca.fit_transform(lreg)
#print(XPCAreduced)
from sklearn.cluster import KMeans
km = KMeans(n_clusters = 12)
km.fit(XPCAreduced)
y_pred = km.predict(XPCAreduced)
print(y_pred)
