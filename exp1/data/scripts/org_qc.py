# -*- coding: utf-8 -*-
"""
Created on Sat Mar  5 12:35:23 2022

@author: nyeh
"""
### organize and perform some quality data control 
#clear enviroment 
from IPython import get_ipython
get_ipython().magic('reset -sf')

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

  # This is platform dependent and returns a Path class object
  # Get the server directory
if my_os == 'Windows':
    server_dir = Path('C:/Users/nyeh/Desktop/fall_2021')
    print(server_dir)
else:
    print("You messed up!")
      
# Set up paths
data_dir = server_dir / project_id / experiment_id / 'data'
source_dir = data_dir / 'sourcedata'
raw_dir = data_dir / 'raw'
analyses_dir = data_dir / 'analyses' 
data_files_dir = analyses_dir / 'data_files'

# set up participant log 
par_col_names = ['OG_id'  ,'id' ,'cb' ,'list' ,'success' ,'failure']
par_log = pd.DataFrame(columns = par_col_names)

# Get study Subject List
sub_list= os.listdir(source_dir)

# loop through participants

for idx, sub in enumerate(sub_list):
    # set up ids
    id = str(idx+1)
    id = id.rjust(3,"0")
    OG_id = sub.split('sub-ndg1e1s',1)[1]
    
    #Load the study behavioral data file
    study_file = source_dir / sub / f'data_PARTICIPANT_study_procedure_{sub}.csv'
    study_data = pd.read_csv(study_file, )
    vars_to_remove = ['instruction_image_resp_keys', 'instruction_image_resp_rt',
           'confirm_image_resp_keys', 'confirm_image_resp_rt',
           'feedback_key_resp_keys', 'feedback_key_resp_rt',
           'confirm_outer_loop_thisRepN', 'confirm_outer_loop_thisTrialN',
           'confirm_outer_loop_thisN', 'confirm_outer_loop_thisIndex',
           'confirm_outer_loop_ran', 'confirm_outer_loop_order',
           'confirm_inner_loop_thisRepN', 'confirm_inner_loop_thisTrialN',
           'confirm_inner_loop_thisN', 'confirm_inner_loop_thisIndex',
           'confirm_inner_loop_ran', 'confirm_inner_loop_order',
           'confirm_questions', 'correct_answer', 'expName',
           'psychopyVersion', 'OS', 'frameRate', 'phases_thisRepN', 'phases_thisTrialN', 'phases_thisN',
           'phases_thisIndex', 'phases_ran', 'phases_order', 'trials_thisRepN', 'trials_thisTrialN',
           'trials_thisN', 'trials_thisIndex', 'trials_ran', 'trials_order',]
    
    study_data.drop(vars_to_remove, axis = 1, inplace=True) # remove columns
    study_data = study_data[study_data['phase_name'].notnull()] #remove rows with NA values from pysychopy setup
    study_data = study_data[study_data['phase_progress'].str.startswith('Real')] # select real trials 
    
    study_data.rename(columns = {"study_arousal_resp_key":"study_arousal_rating"},inplace = True)
    
    #load test behavioral data file
    test_file = source_dir / sub / f'data_PARTICIPANT_test_procedure_{sub}.csv'
    test_data = pd.read_csv(test_file, )
    vars_to_keep = [  'scene_type_resp_keys',     'scene_type_resp_rt',     'test_type_resp_key',     'test_type_rt',
     'old_new_resp',     'item_acc',       'phase_name',       'image', 'id',
     'sc_image',     'sc_type',     'sc_valence',     'sc_code',     'old_new',     'original_scene',
     'scene_code',     'scene_valence',     'date',  
     'cb' ]
    
    test_data = test_data.loc[:, test_data.columns.isin(vars_to_keep)]
    test_data = test_data[test_data['phase_name'].str.endswith('_crit')] # select real trials 
    test_data.rename(columns = {"test_type_resp_key":"test_item_resp"},inplace = True)
    
    # Perform quality control on data
    #check trial counts
    
    n_study_trials = len(study_data.index)
    if n_study_trials != 180:
        print(f"study data for {OG_id} has wrong number of trials/rows")
    else:
        print(f" study data for {OG_id} has correct rows")
        
    n_test_trials = len(test_data.index)
    if n_test_trials !=520:
        print(f"test data for {OG_id} has wrong number of trials/rows")
    else:
        print(f" test data for {OG_id} has correct rows")
        
    # add reappraisal success rating
    def categorise(row):
        if row['study_success_resp_key'] == 1:
            return 'success'
        elif row['study_success_resp_key'] == 0:
            return 'failure'
        else:
            return 'na' # maybe change to view?
    study_data['study_success_rating'] = study_data.apply(lambda row: categorise(row), axis=1)
    
    # check number of reappraisal trials
    n_r_trials = study_data['instruction'].value_counts()[1]
    n_sf_trials = study_data['study_success_rating'].value_counts()['success'] + study_data['study_success_rating'].value_counts()['failure']
    if n_r_trials != 60 | n_sf_trials != 60:
        print(f"study data for {OG_id} has wrong number of reappraisal trials")
    else:
        print(f"study data for {OG_id} has correct (60) number of reappraisal trials")

    # create test memory acc variable
    def score(memory):
        if memory['old_new'] == 'old' and memory['test_item_resp'] ==1 or memory['old_new'] == 'new' and memory['test_item_resp'] == 0:
            return 1
        else:
            return 0
    test_data['test_item_resp_acc'] = test_data.apply(lambda memory: score(memory), axis=1)
    
    # compare newly created acc variable with psychopy original acc variable 
    memory_test = test_data['item_acc'].equals(test_data['test_item_resp_acc'])
    if memory_test:
        print(f"test data accuracy score matches for {OG_id}")
    else:
        print(f"test data accuracy score incorrect for {OG_id}")
         
    # grab stimuli list 1 or 2. Always last value for phase name
    list = study_data['phase_name'].tail(1).item()[-1]     
    # grab counterbalance (ABC): ABCCBA, BCAACB, CABBAC. A = negative reappraisal, B = negative view, C = View neutral
    test_data = test_data[test_data['phase_name'].str.endswith('_crit')] # select real trials 
    phase_name = study_data['phase_name'].head(1).item()
    if phase_name.startswith("neg_decrease1_study"):
        study_cb = 'B'
    elif phase_name.startswit['neg_view1_study']:
        study_cb = 'A'
    else:
        study_cb = 'C'
    
    test_data['list'] = list
    test_data['cb'] = study_cb   
    
    # Combine study and test data

    study_cols = ["sc_code","study_arousal_rating","study_arousal_rt","study_success_rating","study_success_rt","test_file","instruction"]
    temp_study = study_data.loc[:, study_data.columns.isin(study_cols)]
    temp_study.sort_values(['sc_code'], ascending = [True], inplace =True)
    test_data.sort_values(['old_new', 'sc_code'], ascending=[False, True],inplace= True)
    combo_data = pd.merge(test_data, temp_study, how="left")
    # likely could have merged them based on left with a key see below
    #temp_study2 = temp_study.sort_values(['sc_code'], ascending = [False]) mess with sorting to check
    #temp_test = test_data.sort_values(['old_new', 'sc_code'], ascending=[True, True]) mess with sorting to check
    #combo2 = pd.merge(temp_test,temp_study2,how= "left" ,on = [ 'sc_code'])    
    # # Make directory
    sub_raw = raw_dir / id
    sub_raw.mkdir(parents=True, exist_ok=True)

     # Write study, test, and study-test data files
    data_study_file = sub_raw / f'sub-{id}_task-study_beh.tsv'
    study_data.to_csv(data_study_file, index=False)
     
    data_test_file = sub_raw / f'sub-{id}_task-test_beh.tsv'
    test_data.to_csv(data_test_file, index=False)
    
    data_combo_data_file = sub_raw / f'sub-{id}_task-studytest_beh.tsv'
    combo_data.to_csv(data_study_file, index=False)
    
    # Update participant log
    temp_df = pd.DataFrame([[sub,id,study_cb,list,study_data['study_success_rating'].value_counts()['success'], study_data['study_success_rating'].value_counts()['failure']]], columns=par_log.columns)
    par_log = par_log.append(temp_df, ignore_index=True)
    
    # could add summary report for all your checks...trial counts, reappraisal counts, item acc check, etc.. Could add reaction time check