#######################################################
# Program Name: Training for DRL-CWADC
# Description: Run this file to train DRL-CWADC  
# Author: Pooja Gupta %
# Arizona State University %
# Last Modified: 03/04/2021 %
#######################################################
from ddpg_tf_orig import Agent
import gym
import logging, time
import numpy as np
#from utils import plotLearning
from matplotlib import pyplot
from ActiveEnv_orig import ActiveEnv
env = ActiveEnv()
# Parameters to build deep neural networks for DRL
agent = Agent(alpha=0.0001, beta = 0.001, input_dims=[44], tau=0.001, env=env,
                  batch_size=32, layer1_size=400, layer2_size=400, n_actions=24, var = 0.25)
score_history = [] 
ep_rewards = []
ep_avgrewards = []
ep_minrewards = []
ep_maxrewards = []
AGGREGATE_STATS_EVERY = 5  # episodes
counter = 0
np.random.seed(0)
for i in range(500):
    time.sleep(36)
    if i <= 2:
        agent.load_models()
    done = False
    score = 0
    obs = env.reset()
    # step_count represents time_step of PSLF
    for step_count in range(300): 
        # agent chooses action based on ddpg algorithm
        act = agent.choose_action(obs, step_count, env)
        # agent takes an action which in turn returns new sttaes and rewards
        new_state, reward, done, info = env.step(act, step_count)
        print("act, reward",  act, reward)
        # store transition states in replay buffer
        agent.remember(obs, act, reward, new_state, int(done))
        if i > 2:
            agent.learn()
        score += reward
        obs = new_state
        print('episode ', i, 'score %.2f' % score,
                '100 game average %.2f' % np.mean(score_history[-100:]))
        if i > 1: 
           if i%10 == 0:
               agent.save_models()
        print("pslfTime",env.pslfTime)
        # terminate the episode when PSLF timestep reaches 35 sec 
        if (env.pslfTime > 35):  
            i += 1
            print("i", i)
            break
    ep_rewards.append(score)
    print("score", score)
    if not i % AGGREGATE_STATS_EVERY:
        average_reward = sum(ep_rewards[-AGGREGATE_STATS_EVERY:])/len(ep_rewards[-AGGREGATE_STATS_EVERY:])
        min_reward = min(ep_rewards[-AGGREGATE_STATS_EVERY:])
        max_reward = max(ep_rewards[-AGGREGATE_STATS_EVERY:])
        
        ep_avgrewards.append(average_reward)
        ep_minrewards.append(min_reward)
        ep_maxrewards.append(max_reward)
x = [i+1 for i in range(500)]
pyplot.plot(x, ep_rewards)
