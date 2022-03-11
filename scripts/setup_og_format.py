# -*- coding: utf-8 -*-
"""
Created on Sat Mar  5 10:54:55 2022

@author: nyeh
"""
# import required libraries
import os
import pandas as pd 
from pathlib import Path
import platform
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
# The name of the task
# This is platform dependent and returns a Path class object
# Get the server directory
if my_os == 'Windows':
    server_dir = Path('C:/Users/nyeh/Desktop/fall_2021')
    print(server_dir)
else:
    print("You messed up!")
    
data_dir = server_dir / project_id / experiment_id / 'data'

# STEP : DEFINE PATHS (DO NOT CHANGE AFTER THIS)
# This is the source_data directory
source_dir = data_dir / 'sourcedata'
# this is the OG directory

og_dir = data_dir / 'og'

og_study_dir = og_dir / 'study_data'
og_study_dir.mkdir(parents=True, exist_ok=True)

og_test_dir = og_dir / 'test_data'
og_test_dir.mkdir(parents=True, exist_ok=True)

og_qual_dir = og_dir / 'qualtrics_data'
og_qual_dir.mkdir(parents=True, exist_ok=True)

# Report directory
#report_dir = deriv_dir / 'reports'
#report_dir.mkdir(parents=True, exist_ok=True)

# set up 
col_names = ['time_stamp' , 'id', 'exp_id']
study_ts = pd.DataFrame(columns = col_names)
test_ts = study_ts
# Get study Subject List
sub_study_list= os.listdir(og_study_dir)
sub_test_list= os.listdir(og_test_dir)

exp_code = "sub-ndg1e1s"
for sub in sub_test_list:
    # Load the behavioral data file
    beh_file = og_test_dir / sub
    beh_data = pd.read_csv(beh_file, )
    exp_id = beh_data.id[1]
    id = exp_id.split(exp_code,1)[1]
    temp_df = pd.DataFrame([[sub,id,exp_id]], columns=test_ts.columns)
    test_ts = test_ts.append(temp_df, ignore_index=True)
    #test_ts = pd.concat([pd.DataFrame([[sub,id,exp_id]], columns=test_ts.columns),test_ts], ignore_index=False)
    
    # Make directory
    sub_source = source_dir / exp_id
    sub_source.mkdir(parents=True, exist_ok=True)

    # Write  data file
    #data_test_file = source_dir / f'data_PARTICIPANT_test_procedure_{exp_id}.csv'
    #beh_data.to_csv(data_test_file, index=False)

# grab study participants
for sub in sub_study_list:
    print(sub)
    # Load the study data 
    beh_file = og_study_dir / sub
    beh_data = pd.read_csv(beh_file, )
    exp_id = beh_data.id[1]
    id = exp_id.split(exp_code,1)[1]
    # update study dataframe
    temp_df = pd.DataFrame([[sub,id,exp_id]], columns=study_ts.columns)
    study_ts = study_ts.append(temp_df, ignore_index=True)
       
# check if who did study and test phase
combo_ts = pd.merge(test_ts,study_ts, on='id') 
new_sub_list = combo_ts['time_stamp_y']
#save data for study participants who returned for test
for sub in new_sub_list:
       # Load the behavioral data file
    beh_file = og_study_dir / sub
    beh_data = pd.read_csv(beh_file, )
    exp_id = beh_data.id[1]
    id = exp_id.split(exp_code,1)[1]
    
    # Make directory
    sub_source = source_dir / exp_id
    sub_source.mkdir(parents=True, exist_ok=True)

    # Write  data file
    data_test_file = source_dir / f'data_PARTICIPANT_study_procedure_{exp_id}.csv'
    beh_data.to_csv(data_test_file, index=False)
