# -*- coding: utf-8 -*-
"""
Created on Mon Mar  7 15:43:12 2022

@author: nyeh
"""
### analysis script
# Step 1 Set up libraries, path and data failes 
# Step 2 Calculate hit rates, false alarm rates, and corrected hit rates
# Step 3 Calculate alternative measures for trade-off 
# Step 4 Create long style data for trial-by-trial plotting or analyses
# Step 5 Update new measures dataframes
# Step 6 save csv files

# STEP 1
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
analyses_dir = data_dir / 'analyses' 
data_files_dir = analyses_dir / 'data_files'

# set up data files
hit_col_names                 = ['participant' ,'study_cb' ,'list', 'study_condition', 'proportion']
hit_graphs_col_names          = ['participant', 'study_cb', 'list' ,'study_condition', 'sc' ,'valence' ,'proportion']
memory_col_names              = ['participant' ,'study_cb' ,'list', 'study_instruction_condition' ,'corrected_recognition']
memory_graph_col_names        = ['participant' ,'study_cb' ,'list' ,'study_instruction_condition' ,'scene_component', 'valence' ,'corrected_recognition']
tradeoff_datagraphs_col_names = ['participant' ,'study_cb' ,'list' ,'study_instruction_condition', 'intact', 'OB' ,'BG', 'F']
reappraisal_success_col_names = ['participant', 'success_object_hit', 'success_background_hit' ,'success_total', 'failure_object_hit', 'failure_background_hit', 'failure_total']
arousal_col_names             = ['participant', 'study_cb' ,'list' ,'study_condition' ,'arousal_ratings']
lme_col_names                 = ['id', 'list', 'cb' ,'item_acc' ,'sc_type' ,'sc_valence', 'scene_valence', 'old_new', 'study_instruction', 'study_success_resp', 'study_arousal_resp', 'test_item_resp', 'original_scene', 'sc_image' ,'sc_code']

hit_fa_data                   = pd.DataFrame(columns = hit_col_names)
hit_fa_datagraphs             = pd.DataFrame(columns = hit_graphs_col_names)
memory_acc_data               = pd.DataFrame(columns = memory_col_names)
memory_acc_datagraphs         = pd.DataFrame(columns = memory_graph_col_names)
tradeoff_datagraphs           = pd.DataFrame(columns = memory_acc_datagraphs)
reappraisal_strategy_success  = pd.DataFrame(columns = reappraisal_success_col_names)
arousal_data                  = pd.DataFrame(columns = arousal_col_names)
lme_test_data                 = pd.DataFrame(columns = lme_col_names) 

# Get study Subject List
sub_list= os.listdir(data_files_dir)

#loop through participants
for sub in sub_list:
    beh_file = data_files_dir / sub / f'{sub}_task-studytest_beh.tsv'
    beh_data = pd.read_csv(beh_file,sep = '\t' )      
    # assign cb and list information
    study_cb = beh_data['cb'][1]
    studylist =  beh_data['list'][1]
    
    # STEP 2 
    #old_resp = beh_data['old_new_resp'].value_counts()[1]
    #beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[1]
    
    fa = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[0]
    cr   = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[1]
    hit = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[2]
    miss = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[3]
    
    # confirm trial counts 
    check_totals = fa + cr + hit + miss
    if check_totals !=520:
        print(f"test data for {sub} has wrong number of trials/rows")
    else:
        print(f" test data for {sub} has correct rows")
    
    # compute hit rates as function of study instructions x  scene component x valence
    old_beh = beh_data.loc[(beh_data['old_new'] == 'old') & (beh_data['old_new_resp'] == "old")]
    hits_sc_valence_means = old_beh.groupby(['old_new','sc_type','sc_valence', 'scene_valence', 'study_instruction'])['old_new_resp'].value_counts()
    #old_beh = beh_data[beh_data['old_new']=='old']
    #old_beh = old_beh[old_beh['old_new_resp']=='old']
    #hits_sc_valence_means = old_beh.groupby(['old_new','sc_type','sc_valence', 'scene_valence', 'study_instruction'])['old_new_resp'].value_counts()
    # note there were only 60 reappraisal trials 
    hit_decrease_object_negative  = hits_sc_valence_means[3]/60
    hit_decrease_background_negative = hits_sc_valence_means[0]/60
    hit_view_object_negative = hits_sc_valence_means[4]/60
    hit_view_background_negative = hits_sc_valence_means[1]/60
    hit_view_object_neutral = hits_sc_valence_means[5]/60
    hit_view_background_neutral = hits_sc_valence_means[2]/60
    
    total_success = beh_data['study_success_resp'].value_counts()[1]/2
    total_failure = 60-total_success
    old_reappraisal = beh_data.loc[(beh_data['old_new'] == 'old') & (beh_data['old_new_resp'] == "old") & (beh_data['study_instruction'] == "decrease") & (beh_data['scene_valence'] == "negative")]
    hits_sc_valence_success_means = old_reappraisal.groupby(['old_new','sc_type','sc_valence', 'scene_valence', 'study_success_resp'])['old_new_resp'].value_counts()
    
    # Calculate hit rates (old response to old items) for success/failure objects and backgrounds 
    
    hit_success_decrease_object_negative = hits_sc_valence_success_means[3]/total_success
    hit_success_decrease_background_negative = hits_sc_valence_success_means[1]/total_success
    hit_failure_decrease_object_negative = hits_sc_valence_success_means[2]/total_failure
    hit_failure_decrease_background_negative = hits_sc_valence_success_means[0]/total_failure
    
    #Calculate False alarm rate (old response to new items)
    new_beh = beh_data.loc[(beh_data['old_new'] == 'new') & (beh_data['old_new_resp'] == "old")]
    FA_rates = new_beh.groupby(['old_new','sc_type','sc_valence'])['old_new_resp'].value_counts()

    FA_objects_negative = FA_rates[1]/60
    FA_objects_neutral = FA_rates[2]/20
    FA_backgrounds_neutral = FA_rates[0]/80
    
    # Calculate corrected hit rates (hit - false alarms)
    #decrease condition for negative objects/backgrounds
    CR_decrease_object_negative = (hit_decrease_object_negative - FA_objects_negative)
    CR_decrease_background_negative = (hit_decrease_background_negative - FA_backgrounds_neutral)

    # view condition for negative objects/backgrounds
    CR_view_object_negative = (hit_view_object_negative - FA_objects_negative)
    CR_view_background_negative = (hit_view_background_negative - FA_backgrounds_neutral)

    # view condition for neutral object/backgrounds
    CR_view_object_neutral = (hit_view_object_neutral-FA_objects_neutral )
    CR_view_background_neutral = (hit_view_background_neutral - FA_backgrounds_neutral)

    # success condition for decrease object/backgrounds
    CR_success_decrease_object_negative = (hit_success_decrease_object_negative-FA_objects_negative)
    CR_success_decrease_background_negative = (hit_success_decrease_background_negative-FA_backgrounds_neutral)

    # failure condition for decrease object/backgrounds
    CR_failure_decrease_object_negative = (hit_failure_decrease_object_negative-FA_objects_negative)
    CR_failure_decrease_background_negative = (hit_failure_decrease_background_negative-FA_backgrounds_neutral)
    
    # Step 3
    # subset only old data
    alt_data = beh_data.loc[beh_data['old_new'] == 'old']
    # add additional columns for new measures
    alt_data = alt_data.reindex(alt_data.columns.tolist() + ['Intact','Forget','Rearrange_OB','Rearrange_BG'], axis=1) 
    
    # score measures
    numbers = range(1, 181)
   #alt_data.loc[alt_data['sc_code']== trial].index_values
    for trial in numbers:
        
        temp_index = alt_data.index[alt_data["sc_code"] == trial].tolist() #find scene (ob + bg)
        
        if alt_data['old_new_resp'][temp_index[0]] == 'old' and alt_data['old_new_resp'][temp_index[1]] == 'old':
            alt_data['Intact'][temp_index[0]] = 1
            alt_data['Intact'][temp_index[1]] = 1
            
        elif alt_data['old_new_resp'][temp_index[0]] == 'old' and alt_data['sc_type'][temp_index[0]] == 'object' and alt_data['old_new_resp'][temp_index[1]] == 'new' :
            alt_data['Rearrange_OB'][temp_index[0]] = 1
            alt_data['Rearrange_OB'][temp_index[1]] = 1
            
        elif alt_data['old_new_resp'][temp_index[1]] == 'old' and alt_data['sc_type'][temp_index[1]] == 'object' and alt_data['old_new_resp'][temp_index[0]] == 'new' :
            alt_data['Rearrange_OB'][temp_index[0]] = 1
            alt_data['Rearrange_OB'][temp_index[1]] = 1       
        elif alt_data['old_new_resp'][temp_index[0]] == 'new' and alt_data['old_new_resp'][temp_index[1]] == 'new':
            alt_data['Forget'][temp_index[0]] = 1
            alt_data['Forget'][temp_index[1]] = 1
        else:
            alt_data['Rearrange_BG'][temp_index[0]] = 1
            alt_data['Rearrange_BG'][temp_index[0]] = 1
    
    # Remove duplicate rows
    # BEWARE reaction times for test data is no longer accurate 
    alt_data = alt_data.drop_duplicates(subset='sc_code', keep="first")
    # clean up new measures by replacing NAN with 0
    
    alt_data['Intact'] = alt_data['Intact'].fillna(0)
    alt_data['Rearrange_OB'] = alt_data['Rearrange_OB'].fillna(0)
    alt_data['Rearrange_BG'] = alt_data['Rearrange_BG'].fillna(0)
    alt_data['Forget'] = alt_data['Forget'].fillna(0)
    alt_data.loc[(alt_data['old_new'] == 'old') & (alt_data['study_success_resp'] == "na"),'study_success_resp']='view'
    
    # Rearrange measure
    decrease_negative_OB = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'decrease'), 'Rearrange_OB'].sum()/ 60
    
    success_OB = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'success'), 'Rearrange_OB'].sum()/ alt_data['study_success_resp'].value_counts()[1]
    failure_OB =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'failure'), 'Rearrange_OB'].sum()/ alt_data['study_success_resp'].value_counts()[2]
    view_negative_OB =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'view'), 'Rearrange_OB'].sum()/ 60
    view_neutral_OB = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['study_instruction'] == 'view'), 'Rearrange_OB'].sum()/ 60
      
     # INTACT measure
    decrease_negative_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'decrease'), 'Intact'].sum() / 60
    
    success_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'success'), 'Intact'].sum()/ alt_data['study_success_resp'].value_counts()[1]
    failure_OBBG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'failure'), 'Intact'].sum() / alt_data['study_success_resp'].value_counts()[2]
    view_negative_OBBG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'view'), 'Intact'].sum() / 60
    view_neutral_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['study_instruction'] == 'view'), 'Intact'].sum() / 60

    alt_counts_BG = alt_data.groupby(['scene_valence','study_success_resp'])['Rearrange_BG'].value_counts()
    
    decrease_negative_BG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'decrease'), 'Rearrange_BG'].sum() / 60
    success_BG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'success'), 'Rearrange_BG'].sum() / alt_data['study_success_resp'].value_counts()[1]
    failure_BG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'failure'), 'Rearrange_BG'].sum() / alt_data['study_success_resp'].value_counts()[2]
    view_negative_BG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'view'), 'Rearrange_BG'].sum() / 60
    view_neutral_BG = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['study_instruction'] == 'view'), 'Rearrange_BG'].sum() / 60
    
    #Forgot measure
 
    decrease_negative_F = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'decrease'), 'Forget'].sum() / 60
    success_F = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'success'), 'Forget'].sum() / alt_data['study_success_resp'].value_counts()[1]
    failure_F =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_resp'] == 'failure'), 'Forget'].sum() / alt_data['study_success_resp'].value_counts()[2]
    view_negative_F =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_instruction'] == 'view'), 'Forget'].sum() / 60
    view_neutral_F = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['study_instruction'] == 'view'), 'Forget'].sum() / 60

    # alt_data.loc[(alt_data['old_new'] == 'old') & (alt_data['study_success_resp'] == "na"),'study_success_resp']='view'

    # Step 4
    lme_data = beh_data[lme_col_names]
    #clean up study_success_resp variable to include view trials 
    lme_data.loc[(lme_data['old_new'] == 'old') & (lme_data['study_success_resp'] == "na"),'study_success_resp']='view'
    # Update long data
    lme_test_data = lme_test_data.append(lme_data)

    # Step 5 update dataframes with new measures
    
    # Step 6 save csv files