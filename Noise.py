# -*- coding: utf-8 -*-
"""
Created on Thu Jul 23 23:01:46 2020

@author: pgupta69
"""

import numpy as np

class OUActionNoise():
    def _init_(self, mu , sigma =0.1, theta =0.2, dt =1e-2, x0=None):
        self.theta = theta
        self.mu = mu
        self.sigma = sigma
        self.dt = dt
        self.x0 = x0
        self.reset()
        
    def _call_(self):
        x = self.x_prev + self.theta * (self.mu - self.x_prev) * self.d + \
        self.sigma * np.sqrt(self.dt) * np.random.normal(self.mu.shape)
        
        self.x_prev = x
        return x
    
    def reset(self):
        self.x_prev = self.x0 if self.x0 is not None else np.zeros_like(self.mmu
        