#######################################################
# Program Name: Training of DNN-CWADC
# Description: Run this file to train deep neural network 
# Author: Pooja Gupta %
# Arizona State University %
# Last Modified: 03/04/2021 %
#######################################################
# Import of Python packages
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Activation, BatchNormalization,Dropout
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
import pandas as pd
import numpy as np
import scipy.io as sio
from sklearn import metrics
from matplotlib import pyplot
from sklearn.metrics import mean_absolute_error
from tensorflow.keras import regularizers
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import layers
from numpy.random import seed
from numpy.random import shuffle
#Length of training neural network
num_epochs = 50
# Reading the input and the output training data generated after forming the polytopes in LMI toolbox
dfx_train = pd.read_csv('C:\pstv3\TrainingData\TrainingData\InputX_trainAngflowout.csv', header = None)
dfy_train = pd.read_csv('C:\pstv3\TrainingData\TrainingData\OutputY_trainAngflowout.csv', header = None)
#convert the read data to numpy
x_train = dfx_train.to_numpy()
y_train = dfy_train.to_numpy()
# Reading the input and output test data generated after forming the polytopes in LMI toolbox
dfx_test =  pd.read_csv('C:\pstv3\TrainingData\TrainingData\InputX_testAngFlowout.csv', header = None) 
dfy_test = pd.read_csv('C:\pstv3\TrainingData\TrainingData\OutputY_testAngFlowout.csv', header = None)
#convert the read data to numpy
x_test = dfx_test.to_numpy()
y_test = dfy_test.to_numpy()
## Addition of Gaussian error to the training data
x_train3 = np.concatenate([x_train, n np.random.normal(x_train, 0.0002),np.random.normal(x_train, 0.0003),np.random.normal(x_train, 0.0004),np.random.normal(x_train, 0.0005),np.random.normal(x_train, 0.0009),np.random.normal(x_train, 0.01)])
y_train3 = np.concatenate([y_train,y_train,y_train,y_train,y_train,y_train,y_train])
input_dim=x_train.shape[1]
# Build the neural network
model = Sequential()
# Neurons in input layer 5169
model.add(Dense(5169, input_dim=x_train.shape[1] ,activation='relu'))
#model.add(Dropout(0.07))
BatchNormalization(axis=-1, momentum=0.99, epsilon=0.001, center=True, scale=True, beta_initializer='zeros', gamma_initializer='ones', moving_mean_initializer='zeros', moving_variance_initializer='ones', beta_regularizer=None, gamma_regularizer=None, beta_constraint=None, gamma_constraint=None)
# Hidden 1 layer
model.add(Dense(2500, activation='relu', activity_regularizer=regularizers.l2(1e-5))) 
BatchNormalization(axis=-1, momentum=0.99, epsilon=0.001, center=True, scale=True, beta_initializer='zeros', gamma_initializer='ones', moving_mean_initializer='zeros', moving_variance_initializer='ones', beta_regularizer=None, gamma_regularizer=None, beta_constraint=None, gamma_constraint=None)
# Hidden 2 layer
model.add(Dense(1861, activation='relu', activity_regularizer=regularizers.l2(1e-5))) # Hidden 3
BatchNormalization(axis=-1, momentum=0.99, epsilon=0.001, center=True, scale=True, beta_initializer='zeros', gamma_initializer='ones', moving_mean_initializer='zeros', moving_variance_initializer='ones', beta_regularizer=None, gamma_regularizer=None, beta_constraint=None, gamma_constraint=None)
# Output
model.add(Dense(1032, activation='linear'))
model.compile(loss='mean_absolute_error', optimizer=Adam(lr=1e-3), metrics=['mae'])
# monitor = EarlyStopping(monitor='val_loss', min_delta=1e-3, patience=5, verbose=1, mode='auto', restore_best_weights=True)
# ckpointer = ModelCheckpoint(filepath = 'model_zero7.{epoch:02d}-{val_loss:.6f}.hdf5',verbose=1,save_best_only=True,save_weights_only = True)
# Reduce learning rate if MAE doesn't decrease
reduce_lr = ReduceLROnPlateau(monitor='val_mean_absolute_error', factor=0.1, patience=2, min_lr=0.000001, verbose=1)
# Model fitting
history = model.fit(x_train3, y_train3, verbose=1, epochs=num_epochs, validation_split=0.2, batch_size=16, callbacks=[reduce_lr])
xc = range(1,num_epochs)
loss_train = history.history['loss']
l_t= np.array(loss_train[1:num_epochs])
loss_val = history.history['val_loss']
v_t= np.array(loss_val[1:num_epochs])
# Plotting model loss
pyplot.figure()
pyplot.plot(xc, l_t, label='train')
pyplot.plot(xc,  v_t, label='validation')
pyplot.title('Model loss')
pyplot.ylabel('Loss')
pyplot.xlabel('Epoch')
pyplot.legend(['Train', 'Validation'], loc='upper left')
# Plotting validation error
pyplot.figure()
mae_train = history.history['mean_absolute_error']
m_t= np.array(mae_train[1:num_epochs])
mae_val = history.history['val_mean_absolute_error']
m_v= np.array(mae_val[1:num_epochs])
pyplot.plot(xc,m_t)
pyplot.plot(xc,m_v)
pyplot.title('Model MAE')
pyplot.ylabel('MAE')
pyplot.xlabel('Epoch')
pyplot.legend(['Train', 'Test'], loc='upper left')
pyplot.show()
# Testing of the trained data
x_test1 = np.zeros(x_test.shape)
y_test1 = np.zeros(y_test.shape)
seed(1)
# prepare a sequence
sequence = [i for i in range(15)]
shuffle(sequence)
j = 0
while j < len(sequence):
   x_test1[j,:] = x_test[sequence[j],:]
   y_test1[j,:] = y_test[sequence[j],:]
   j += 1
# predict the gain (output of the the trained model) for the testing input    
pred1 = model.predict(x_test1)
score1 = (metrics.mean_absolute_error(pred1,y_test1))
print(f"Fold score (MAE): {score1}")
# arrangement of the predicted data as accepted by the polytopic input -Section 6.1.1
K1 =np.zeros([24,43])
k=0
for j in range(43):
    for i in range(24):
        K1[i,j] = pred1[14, k]
        k += 1
