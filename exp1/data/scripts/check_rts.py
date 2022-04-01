# -*- coding: utf-8 -*-
"""
Created on Mon Mar 28 15:56:53 2022

@author: nyeh
"""

# STEP 1
#clear enviroment 
from IPython import get_ipython
get_ipython().magic('reset -sf')

# import required libraries
import os
import pandas as pd 
from pathlib import Path
import platform
import matplotlib.pyplot as plt
import seaborn as sns
import pingouin as pg
check_import = "os"
if check_import not in dir():
  print(check_import + " not imported!")
else:
  print(check_import + " imported!")
  
#set up paths
path = os.getcwd()
os.chdir('C:/Users/nyeh/Desktop/fall_2021/NDG/exp1/data')
# Project ID and Experiment number
project_id = 'NDG'
experiment_id = 'exp1'
my_os = platform.system()

# This is platform dependent and returns a Path class object
# Get the server directory
if my_os == 'Windows':
    server_dir = Path('C:/Users/nyeh/Desktop/fall_2021')
    print(server_dir)
else:
    print("You messed up!")
      
# Set up paths
data_dir = server_dir / project_id / experiment_id / 'data'
raw_dir = data_dir / 'raw_py'
analyses_dir = data_dir / 'analyses_py' 
data_files_dir = analyses_dir / 'data_files_py'
reg_analyese_dir = data_dir / 'analyses'

RT_data = pd.read_csv(r"C:\Users\nyeh\Desktop\fall_2021\NDG\exp1\data\analyses\test_rt_data.csv")

test_col_names                 = ['participant','scene_type_resp_keys',	'scene_type_resp_rt',	'test_item_resp',	'test_type_rt',	'old_new_resp',	'item_acc',	'phase_name',	'image',	'sc_image',	'sc_type',	'sc_valence',	'sc_code',	'old_new',	'original_scene',	'scene_code',	'scene_valence',	'id',	'date',	'cb',	'test_item_resp_acc',	'list']
test_data                      = pd.DataFrame(columns = test_col_names) 

# Get sub_list in order to get long format test data
sub_list = os.listdir(raw_dir)
for idx, sub in enumerate(sub_list):
    # set up ids
    temp_id = idx +1
    
    #OG_id = sub.split('sub-ndg1e1s',1)[1]
    
    beh_file = raw_dir / sub / f'{sub}_task-test_beh.tsv'
    beh_data = pd.read_csv(beh_file,sep = ',' )  
    beh_data['participant'] = temp_id
    test_data_temp = beh_data[test_col_names]
      # Update long data
    test_data = test_data.append(test_data_temp)    

#find fast RT people
check_RTS             = RT_data.loc[RT_data['median_rt'] < 1] #participant ids sub-XXX
check_RTS.participant = check_RTS.participant.str[4:] #remove "sub-"
check_RTS.participant = check_RTS['participant'].str.lstrip('0') # strip leading zeros
list_to_check         = check_RTS['participant'].astype(int) #convert to int

#Check for bad RTs
test_data['test_trial'] = test_data.groupby('id').cumcount()+1 #add trial order for later plot
#loop through participants with low RTS to visualize reaction times 
for i in list_to_check:
    print(i)
    temp_data = test_data.loc[test_data['participant'] == i]
    plt.figure() 
    sns.barplot(data=temp_data, x="test_trial",y = "scene_type_resp_rt", hue = "participant").set_title('plot for participant: %i'%i)
    plt.ylim(0, 2)
    plt.axhline(1,ls='--',color = 'black')