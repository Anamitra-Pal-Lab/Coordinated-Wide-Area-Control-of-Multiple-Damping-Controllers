#######################################################
# Program Name: Power system environment for DRL-CWADC
# Description: Run this file to create environment for 
# training DRL-CWADC  
# Author: Pooja Gupta %
# Arizona State University %
# Last Modified: 03/04/2021 %
#######################################################
import logging, time
import math
import gym
from gym import spaces
from gym.utils import seeding
import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from subprocess import call, Popen, PIPE
import math as math
import csv
import random
import os
import shutil
from pathlib import Path
import pandas as pd
#class ActiveEnv(gym.Env):
class ActiveEnv():    
    def __init__(self, seed =None):
        self.np_random = None
        self.seed = self.seed(seed)
        self._current_step = 0
        self.gen_data = self.load_gen_data() 
        # initilaization of observation space
        self.observation_space = spaces.Box(low=obs[:,0], high =obs[:,1], dtype=np.float32)
        # initialization of action space-here only 4 actions added due to space constraints
        self.action_high =  np.array([3*np.abs(self.get_action()[0]), 1.0*np.abs(self.get_action()[1]), 1.0*np.abs(self.get_action()[2]), 1.0*np.abs(self.get_action()[3])])
        self.action_low = np.array(-self.action_high)
        self.action_space = spaces.Box(low =  self.action_low, high = self.action_high, dtype=np.float32)
        self._done = False
        self.reward = 0
        self.log_terminalReached(self._done)
    def seed (self, seed=None):
        self.np_random, seed = seeding.np_random(seed)
        return [seed]
    # function for loading the generator data  - speeds and angles of the generators identified using SMA 
    def load_gen_data(self):
         if os.path.exists('/upslf21/MyPSLF/RL_PSLF/AS1.csv'):
             try:
                 ang = pd.read_csv('/upslf21/MyPSLF/RL_PSLF/AS1.csv', delimiter=r"\s+")
             except pd.errors.EmptyDataError:
                 print('Note: AS1.csv was empty. Reading AS2.csv.')
                 ang = pd.read_csv('/upslf21/MyPSLF/RL_PSLF/AS2.csv', delimiter=r"\s+")
         else:
            ang = pd.read_csv('/upslf21/MyPSLF/RL_PSLF/AS2.csv', delimiter=r"\s+")
         return ang.to_numpy()
    # function for loading the polytopic gains- used as an initial input
    def load_Gains_data(self):
        #Gains =  pd.read_csv('Gain_Gens1.csv', header = None)
        Gains =  pd.read_csv('Gain_Gens2.csv', header = None)

        return Gains.to_numpy()
    # function for calculating the change in speeds and angles of generators
    def _get_obs(self):
        state =[]
        self.ang_speed = self.load_gen_data()
        j = 0
        while j < (len(self.ang_speed)):
            dang = self.ang_speed[j,3]/180 * math.pi - self.ang_speed[j,2]/180 * math.pi
            dspd = self.ang_speed[j,5]-self.ang_speed[j,4]
            ang_spd1.append(dang)
            ang_spd1.append(dspd)
            j += 1
        state = (ang_spd1)
        return np.array(state)
    # function to find the change in maximum angle and speed for finding the maximum bound
    def load_maxChange_gen_data(self):
        max_angspd = pd.read_csv('C:/RLGC-master/RLGC-master/Fault_max_delChange.csv', delimiter=r"\s+")
        return max_angspd.to_numpy()
    # function to load the powerflows of lines
    def load_RegPower_data(self):
        if os.path.exists('C:/upslf21/MyPSLF/RL_PSLF/RegPowFlowsPSLF.csv'):
            try:
                RegPower =  pd.read_csv('C:/upslf21/MyPSLF/RL_PSLF/RegPowFlowsPSLF.csv', delimiter=r"\s+", header = None)
            except pd.errors.EmptyDataError:
                print('Note: Reg.csv was empty. Reading Reg3.csv.')
                RegPower =  pd.read_csv('C:/upslf21/MyPSLF/RL_PSLF/RegPowFlowsPSLF3.csv', delimiter=r"\s+", header = None)
        else:
            RegPower =  pd.read_csv('C:/upslf21/MyPSLF/RL_PSLF/RegPowFlowsPSLF3.csv', delimiter=r"\s+", header = None)
        return (RegPower[0].to_numpy()-RegPower[1].to_numpy())
    # reset function for speeds and angles at every timestep
    def reset(self):
        aSpd = []
        j = 0
        dang = 0.05
        dspd = 0.025
        while j < 22 :
            aSpd.append(dang)
            aSpd.append(dspd)
            j += 1
        high = np.array(aSpd)
        state = self.np_random.uniform(low=-high, high=high)
        return state
    # function to generate the controller actions based on different PSLF timesteps
    def get_action(self):
        ang = []
        spd = []
        Gang = []
        Gspd = []
        result_ang = 0
        result_spd = 0
        result = 0
        GangSVC = []
        GspdSVC = []
        result_angSVC = 0
        result_spdSVC = 0
        resultSVC = 0
        GangPSS5 = []
        GspdPSS5 = []
        result_angPSS5 = 0
        result_spdPSS5 = 0
        resultPSS5 = 0
        GangPSS8 = []
        GspdPSS8 = []
        result_angPSS8 = 0
        result_spdPSS8 = 0
        resultPSS8 = 0
        Gain_Cont =self.load_Gains_data()
        max_ang_spd =  self.load_maxChange_gen_data()
        #extract the speeds and angles of generators
        j = 0
        while j < (len(max_ang_spd)):
            if j != 2:
                dang = max_ang_spd[j,3]/180 * math.pi - max_ang_spd[j,2]/180 * math.pi
                ang.append(dang)
            j += 1
        j = 0
        while j < (len(max_ang_spd)):
            dspd = max_ang_spd[j,5] - max_ang_spd[j,4]
            spd.append(dspd)
            j += 1
        # Load Gains Data
        # for DC-SDC
        j = 2
        while j < 23:
            gainDel = Gain_Cont[22,j]
            Gang.append(gainDel)
            j += 1
        j = 23
        while j < Gain_Cont.shape[1]:
            gainSpd = Gain_Cont[22,j]
            Gspd.append(gainSpd)
            j += 1   
        # for SVC
        j = 2
        while j < 23:
            gainDelSVC = Gain_Cont[23,j]
            GangSVC.append(gainDelSVC)
            j += 1
        j = 23
        while j < Gain_Cont.shape[1]:
            gainSpdSVC = Gain_Cont[23,j]
            GspdSVC.append(gainSpdSVC)
            j += 1 
        # for PSSs-shown here for only 2 PSSs
        j = 2
        while j < 23:
            gainDelPSS5 = Gain_Cont[0,j]
            GangPSS5.append(gainDelPSS5)
            gainDelPSS8 = Gain_Cont[1,j]
            GangPSS8.append(gainDelPSS8)
            j += 1
        j = 23
        while j < Gain_Cont.shape[1]:
            gainSpdPSS5 = Gain_Cont[0,j]
            GspdPSS5.append(gainSpdPSS5)         
            gainSpdPSS8 = Gain_Cont[1,j]
            GspdPSS8.append(gainSpdPSS8)
            j += 1 
        angle  = np.array(ang)
        speed  = np.array(spd)
        Gangle  = np.array(Gang)
        Gspeed  = np.array(Gspd)
        GangleSVC  = np.array(GangSVC)
        GspeedSVC  = np.array(GspdSVC)
        GanglePSS5  = np.array(GangPSS5)
        GspeedPSS5  = np.array(GspdPSS5)
        GanglePSS8  = np.array(GangPSS8)
        GspeedPSS8  = np.array(GspdPSS8)
        for i in range(len(angle)):
            result_ang += angle[i] * Gangle[i] 
            result_angSVC += angle[i] * GangleSVC[i]    
            result_angPSS5 += angle[i] * GanglePSS5[i]
            result_angPSS8 += angle[i] * GanglePSS8[i]
        for i in range(len(speed)):
            result_spd += speed[i] * Gspeed[i]
            result_spdSVC += speed[i] * GspeedSVC[i]
            result_spdPSS5 += speed[i] * GspeedPSS5[i]
            result_spdPSS8 += speed[i] * GspeedPSS8[i]
        result = result_ang + result_spd
        resultSVC = result_angSVC + result_spdSVC
        resultPSS5 = result_angPSS5 + result_spdPSS5
        resultPSS8 = result_angPSS8 + result_spdPSS8
        return (result, resultSVC, resultPSS5, resultPSS8)
    # logs actions for PSLF
    def log_action(self, action):
        action_pslf = action
        myFile = open('/upslf21/MyPSLF/RL_PSLF/Ang_Python.csv','w', newline='')
        with myFile:
            writer = csv.writer(myFile)
            writer.writerows(np.transpose(action_pslf))
    # writes the information for PSLF if the episode is terminated       
    def log_terminalReached(self, done):
        if (done == True):
            tdone = 1
        else:
            tdone = 0
        tdone1 =[[tdone],[tdone],[tdone],[tdone]]
        myFile = open('/upslf21/MyPSLF/RL_PSLF/waitinfo.csv.csv','w', newline='')
        with myFile:
            writer = csv.writer(myFile)
            writer.writerows(tdone1)
    # function to calculate the reward        
    def calc_reward(self, action, obtstate):
        #state_loss = 0
        #assigned_reward = 0
        ang_costs = 0
        spd_costs = 0
        cont_PSS = 0
        cont_pen =np.zeros(22)
        self.angSum = 0
        action_state_num =  obtstate
        for i in range(len(self.ang_speed)):
            self.angSum += np.abs(self.ang_speed[i,3]/180 * math.pi - self.ang_speed[i,2]/180 * math.pi) 
            ang_costs += 10 * np.abs(self.ang_speed[i,3]/180 * math.pi - self.ang_speed[i,2]/180 * math.pi) 
            spd_costs += 10 * np.abs(self.ang_speed[i,5]-self.ang_speed[i,4]) 
            
        if (self.pslfTime <= 5):
            if ((np.abs(action[0,0])) > 2*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 3*np.abs(self.get_action()[0])) :
                cont1_pen = 3 * np.abs(action[0,0])
            elif ((np.abs(action[0,0])) > 1*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 2*np.abs(self.get_action()[0])) :
                cont1_pen = 2 * np.abs(action[0,0])
            else:
                cont1_pen = 1 * np.abs(action[0,0])
                
            if ((np.abs(action[0,1])) > (0.95)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= 1.0*np.abs(self.get_action()[1])):
                cont2_pen = 1 * np.abs(action[0,1])

            elif ((np.abs(action[0,1])) > (0.75)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= (0.95)*np.abs(self.get_action()[1])):
                cont2_pen = 2 * np.abs(action[0,1])
                    
            else:
                cont2_pen = 3 * np.abs(action[0,1])
                
            i = 0
            for i in range(20):
                if ((np.abs(action[0,i+2])) > (0.95)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= 1.0*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 4*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.75)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.95)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 3*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.5)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.75)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 2*np.abs(action[0,i+2])
                else:
                    cont_pen[i] = 1*np.abs(action[0,i+2])
                        
        if (self.pslfTime > 5) and (self.pslfTime <= 8):
            if ((np.abs(action[0,0])) > 2*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 3*np.abs(self.get_action()[0])) :
                cont1_pen = 4 * np.abs(action[0,0])
            elif ((np.abs(action[0,0])) > 1*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 2*np.abs(self.get_action()[0])) :
                cont1_pen = 3 * np.abs(action[0,0])
            elif ((np.abs(action[0,0])) > 0.75*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 1*np.abs(self.get_action()[0])) :
                cont1_pen = 2 * np.abs(action[0,0])
            else:
                cont1_pen = 1 * np.abs(action[0,0])
                
            if ((np.abs(action[0,1])) > (0.95)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= 1.0*np.abs(self.get_action()[1])):
                cont2_pen = 4 * np.abs(action[0,1])
            elif ((np.abs(action[0,1])) > (0.75)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= (0.95)*np.abs(self.get_action()[1])):
                cont2_pen = 3 * np.abs(action[0,1])
            elif ((np.abs(action[0,1])) > (0.5)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= (0.75)*np.abs(self.get_action()[1])):
                cont2_pen = 2 * np.abs(action[0,1])
            else:
                cont2_pen = 1 * np.abs(action[0,1])
                    
            i = 0
            for i in range(20):
                if ((np.abs(action[0,i+2])) > (0.95)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= 1.0*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 4*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.75)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.95)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 3*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.5)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.75)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 2*np.abs(action[0,i+2])
                else:
                    cont_pen[i] = 1*np.abs(action[0,i+2])
                        
        if (self.pslfTime > 8):
            if ((np.abs(action[0,0])) > 2*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 3*np.abs(self.get_action()[0])) :
                cont1_pen = 4 * np.abs(action[0,0])
            elif ((np.abs(action[0,0])) > 1*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 2*np.abs(self.get_action()[0])) :
                cont1_pen = 3 * np.abs(action[0,0])
            elif ((np.abs(action[0,0])) > 0.75*np.abs(self.get_action()[0])) and ((np.abs(action[0,0])) <= 1*np.abs(self.get_action()[0])):
                cont1_pen = 2 * np.abs(action[0,0])
            else:
                cont1_pen = 1 * np.abs(action[0,0])
                
            if ((np.abs(action[0,1])) > (0.95)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= 1.0*np.abs(self.get_action()[1])):
                cont2_pen = 4 * np.abs(action[0,1])
            elif (np.abs(action[0,1])) > (0.75)*np.abs(self.get_action()[1]) and ((np.abs(action[0,1])) <= (0.95)*np.abs(self.get_action()[1])):
                cont2_pen = 3 * np.abs(action[0,1])
            elif ((np.abs(action[0,1])) > (0.5)*np.abs(self.get_action()[1])) and ((np.abs(action[0,1])) <= (0.75)*np.abs(self.get_action()[1])):
                cont2_pen = 2 * np.abs(action[0,1])
            else:
                cont2_pen = 1 * np.abs(action[0,1])
                    
            i = 0
            for i in range(20):
                if ((np.abs(action[0,i+2])) > (0.95)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= 1.0*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 4*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.75)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.95)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 3*np.abs(action[0,i+2])
                elif ((np.abs(action[0,i+2])) > (0.5)*np.abs(self.get_action()[i+2])) and ((np.abs(action[0,i+2])) <= (0.75)*np.abs(self.get_action()[i+2])):
                    cont_pen[i] = 2*np.abs(action[0,i+2])
                else:
                    cont_pen[i] = 1*np.abs(action[0,i+2])
                        
        for i in range(22):
            cont_PSS += cont_pen[i]
        costs_tot = ang_costs + spd_costs + cont1_pen + cont2_pen + cont_PSS
        print("angC, spdC, actC0, actC0", ang_costs, spd_costs, cont1_pen, cont2_pen)
        return -costs_tot
    # main step function for the DRL algorithm       
    def step(self, action, time_count):                
        log_action = self.log_action(action)       
        nstate =  self._get_obs()   
        # calculation of the rewards corresponding to the generated actions
        reward = self.calc_reward (action, nstate)
        print("angSum", self.angSum)
        # terminate the episode when PSLF timestep reaches 35 sec
        if (self.pslfTime > 35): 
            self._done = True
            self.log_terminalReached(self._done)
        return nstate, reward, self._done, {}
             
   
            