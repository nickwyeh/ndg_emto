# -*- coding: utf-8 -*-
"""
Created on Mon Mar  7 15:43:12 2022

@author: nyeh
"""
# Need to add code for 100-success/0-failure individuals, since table extraction gets messed up
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
analyses_dir = data_dir / 'analyses_py' 
data_files_dir = analyses_dir / 'data_files_py'

# set up data files

memory_melt_col_names          = ['id', 'cb', 'list', 'study_condition', 'scene_component', 'valence', 'hit_rate' ]
cr_melt_col_names              = ['id', 'cb', 'list', 'study_condition', 'scene_component', 'valence', 'corrected_hr' ]

memory_col_names               =  ['participant', 'study_cb' ,'list' , "dec_ob_neg", "dec_bg_neg", "view_ob_neg", "view_bg_neg", "view_ob_neutral", "view_bg_neutral", "success_ob_neg", "success_bg_neg", "failure_ob_neg", "failure_bg_neg"]
#reappraisal_success_col_names = ['participant', 'success_object_hit', 'success_background_hit' ,'success_total', 'failure_object_hit', 'failure_background_hit', 'failure_total']
#arousal_col_names             = ['participant', 'study_cb' ,'list' ,'study_condition' ,'arousal_ratings']
lme_col_names                  = ['id', 'list', 'cb' ,'item_acc' ,'sc_type' ,'sc_valence', 'scene_valence', 'old_new', 'instruction', 'study_success_rating', 'study_arousal_rating', 'test_item_resp', 'original_scene', 'sc_image' ,'sc_code']
hit_cols                       = ['participant', 'study_cb' ,'list' , "dec_ob_neg", "dec_bg_neg", "view_ob_neg", "view_bg_neg", "view_ob_neutral", "view_bg_neutral", "success_ob_neg", "success_bg_neg", "failure_ob_neg", "failure_bg_neg", "fa_ob_neg", "fa_ob_neutral", "fa_bg_neutral"]
tradeoff_col_names  = ['participant', 'study_cb' ,'list' , "dec_neg_intact", "view_neg_intact", "view_neutral_intact", "success_neg_intact", "failure_neg_intact", "dec_neg_emto", "view_neg_emto" ,"view_neutral_emto",  "success_neg_emto" ,  "failure_neg_emto" , "dec_neg_reverse" , 
                                 "view_neg_reverse", "view_neutral_reverse", "success_neg_reverse", "failure_neg_reverse", "dec_neg_forget", "view_neg_forget", "view_neutral_forget", "success_neg_forget", "failure_neg_forget" ]
combined_alt_to                = ['participant', 'study_cb', 'list', 'study_condition', 'intact', 'emto', 'reverse', 'forget']

#hit_fa_data                   = pd.DataFrame(columns = hit_col_names)
#hit_fa_datagraphs             = pd.DataFrame(columns = hit_graphs_col_names)
cr_list                        = pd.DataFrame(columns = memory_col_names)
to_list                        = pd.DataFrame(columns = tradeoff_col_names)
#tradeoff_datagraphs           = pd.DataFrame(columns = memory_acc_datagraphs)
#reappraisal_strategy_success  = pd.DataFrame(columns = reappraisal_success_col_names)
#arousal_data                  = pd.DataFrame(columns = arousal_col_names)
lme_test_data                  = pd.DataFrame(columns = lme_col_names) 
hit_list                       = pd.DataFrame(columns = hit_cols) 
memory_melt                    = pd.DataFrame(columns = memory_melt_col_names) 
cr_melt                        = pd.DataFrame(columns = cr_melt_col_names) 
combined_alt                   = pd.DataFrame(columns = combined_alt_to) 

# Get study Subject List
sub_list = os.listdir(data_files_dir)

#loop through participants
for sub in sub_list:
    
    beh_file = data_files_dir / sub / f'{sub}_task-studytest_beh.tsv'
    beh_data = pd.read_csv(beh_file,sep = ',' )      
    # assign cb and list information
    study_cb = beh_data['cb'][1]
    studylist = beh_data['list'][1]
    
    # STEP 2 
    #old_resp = beh_data['old_new_resp'].value_counts()[1]
    #beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[1]
    
    fa   = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[0]
    cr   = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[1]
    hit  = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[2]
    miss = beh_data.groupby(['old_new'])['old_new_resp'].value_counts()[3]
    
    # confirm trial counts 
    check_totals = fa + cr + hit + miss
    if check_totals !=520:
        print(f"test data for {sub} has wrong number of trials/rows")
    else:
        print(f" test data for {sub} has correct rows")
    
    # compute hit rates as function of study instructions x  scene component x valence
    old_beh = beh_data.loc[(beh_data['old_new'] == 'old') & (beh_data['old_new_resp'] == "old")]
    hits_sc_valence_means = old_beh.groupby(['old_new','sc_type','sc_valence', 'scene_valence', 'instruction'])['old_new_resp'].value_counts()
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
    
    total_success = beh_data['success_resp_keys'].value_counts()[1]/2
    total_failure = 60 - total_success
    old_reappraisal = beh_data.loc[(beh_data['old_new'] == 'old') & (beh_data['old_new_resp'] == "old") & (beh_data['instruction'] == "decrease") & (beh_data['scene_valence'] == "negative")]
    hits_sc_valence_success_means = old_reappraisal.groupby(['old_new','sc_type','sc_valence', 'scene_valence', 'success_resp_keys'], as_index=False)['old_new_resp'].count()

    #check for missing combinations of data
    #no hits for successful objects
    option2a = beh_data.loc[(beh_data.success_resp_keys == 1) & (beh_data.old_new_resp == 'old') & (beh_data.sc_type == 'object')]['old_new_resp'].value_counts()
    option2b = beh_data.loc[(beh_data.success_resp_keys == 1) & (beh_data.old_new_resp == 'old')] ['old_new_resp'].value_counts()
    # no hits for faiolure backgrounds
    option3a = beh_data.loc[(beh_data.instruction == 'decrease') & (beh_data.old_new_resp == 'old') & (beh_data.sc_type == 'background')]['old_new_resp'].value_counts()
    option3b = beh_data.loc[(beh_data.success_resp_keys == 1) & (beh_data.old_new_resp == 'old') & (beh_data.sc_type == 'background')]['old_new_resp'].value_counts()
    
    if len(hits_sc_valence_success_means.index) == 3 : 
         if option2a[0] == option2b[0] :
            temp_success_bg = {"old_new" : "old", "sc_type" : "background", "sc_valence" : "neutral", "scene_valence" : "negative","success_resp_keys": 1, "old_new_resp": 0}  
            hits_sc_valence_success_means = hits_sc_valence_success_means.append(temp_success_bg,ignore_index=True)
            hits_sc_valence_success_means = hits_sc_valence_success_means.reindex([0,3,1,2])
            hits_sc_valence_success_means.reset_index(drop=True, inplace=True)
            
         elif option3a[0] == option3b[0] :
            temp_success_bg = {"old_new" : "old", "sc_type" : "background", "sc_valence" : "neutral", "scene_valence" : "negative","success_resp_keys": 0, "old_new_resp": 0}  
            hits_sc_valence_success_means = hits_sc_valence_success_means.append(temp_success_bg,ignore_index=True)
            hits_sc_valence_success_means = hits_sc_valence_success_means.reindex([3,0,1,2])
            hits_sc_valence_success_means.reset_index(drop=True, inplace=True)
            
         else:
            print("problem")
            
    elif len(hits_sc_valence_success_means.index) == 2 and  total_failure == 0:
        
        temp_failure_bg = {"old_new" : "old", "sc_type" : "background", "sc_valence" : "neutral", "scene_valence" : "negative","success_resp_keys": float("NaN"), "old_new_resp": float("NaN")}
        temp_failure_ob = {"old_new" : "old", "sc_type" : "object", "sc_valence" : "negative", "scene_valence" : "negative","success_resp_keys": float("NaN"), "old_new_resp": float("NaN")}
        hits_sc_valence_success_means.loc[-1] = temp_failure_bg
        hits_sc_valence_success_means.index = hits_sc_valence_success_means.index + 1
        hits_sc_valence_success_means = hits_sc_valence_success_means.sort_index()   
        hits_sc_valence_success_means = hits_sc_valence_success_means.append(temp_failure_ob,ignore_index=True)
        hits_sc_valence_success_means = hits_sc_valence_success_means.reindex([0,1,3,2])
        hits_sc_valence_success_means.reset_index(drop=True, inplace=True)
    elif len(hits_sc_valence_success_means.index) == 4:
        print("Good hit rate distribution")
    else:
        print("big problem")
    # Calculate hit rates (old response to old items) for success/failure objects and backgrounds 
    
    hit_success_decrease_object_negative = hits_sc_valence_success_means['old_new_resp'][3]/total_success
    hit_success_decrease_background_negative = hits_sc_valence_success_means['old_new_resp'][1]/total_success
    hit_failure_decrease_object_negative = hits_sc_valence_success_means['old_new_resp'][2]/total_failure
    hit_failure_decrease_background_negative = hits_sc_valence_success_means['old_new_resp'][0]/total_failure
    
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
    CR_view_object_neutral = (hit_view_object_neutral - FA_objects_neutral )
    CR_view_background_neutral = (hit_view_background_neutral - FA_backgrounds_neutral)

    # success condition for decrease object/backgrounds
    CR_success_decrease_object_negative = (hit_success_decrease_object_negative - FA_objects_negative)
    CR_success_decrease_background_negative = (hit_success_decrease_background_negative - FA_backgrounds_neutral)

    # failure condition for decrease object/backgrounds
    CR_failure_decrease_object_negative = (hit_failure_decrease_object_negative - FA_objects_negative)
    CR_failure_decrease_background_negative = (hit_failure_decrease_background_negative - FA_backgrounds_neutral)
    
    # Step 3
    # subset only old data
    alt_data = beh_data.loc[beh_data['old_new'] == 'old']
    # add additional columns for new measures
    alt_data = alt_data.reindex(alt_data.columns.tolist() + ['Intact','Forget','Rearrange_OB','Rearrange_BG'], axis=1) 
    
    # score measures
    numbers = range(1, 181) # total of 180 scene codes
   
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
    alt_data.loc[(alt_data['old_new'] == 'old') & (alt_data['study_success_rating'] == "na"),'study_success_rating']='view'
    
    # Handle when there are no reappraisal failures
    if total_failure == 0:
        failure_OB = float("NaN")
        failure_OBBG = float("NaN")
        failure_BG = float("NaN")
        failure_F = float("NaN")
    else:
        failure_OB =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'failure'), 'Rearrange_OB'].sum()/ alt_data['study_success_rating'].value_counts()[2]
        failure_OBBG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'failure'), 'Intact'].sum() / alt_data['study_success_rating'].value_counts()[2]
        failure_BG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'failure'), 'Rearrange_BG'].sum() / alt_data['study_success_rating'].value_counts()[2]
        failure_F =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'failure'), 'Forget'].sum() / alt_data['study_success_rating'].value_counts()[2]

    # Rearrange measure
    decrease_negative_OB = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'decrease'), 'Rearrange_OB'].sum()/ 60    
    success_OB = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'success'), 'Rearrange_OB'].sum()/ alt_data['study_success_rating'].value_counts()[1]  
    view_negative_OB =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'view'), 'Rearrange_OB'].sum()/ 60
    view_neutral_OB = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['instruction'] == 'view'), 'Rearrange_OB'].sum()/ 60
    
     # INTACT measure
    decrease_negative_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'decrease'), 'Intact'].sum() / 60 
    success_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'success'), 'Intact'].sum()/ alt_data['study_success_rating'].value_counts()[1]
    view_negative_OBBG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'view'), 'Intact'].sum() / 60
    view_neutral_OBBG = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['instruction'] == 'view'), 'Intact'].sum() / 60
  
    #alt_counts_BG = alt_data.groupby(['scene_valence','study_success_rating'])['Rearrange_BG'].value_counts()
    
    decrease_negative_BG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'decrease'), 'Rearrange_BG'].sum() / 60
    success_BG = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'success'), 'Rearrange_BG'].sum() / alt_data['study_success_rating'].value_counts()[1]
    view_negative_BG =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'view'), 'Rearrange_BG'].sum() / 60
    view_neutral_BG = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['instruction'] == 'view'), 'Rearrange_BG'].sum() / 60
    
    #Forgot measure
    decrease_negative_F = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'decrease'), 'Forget'].sum() / 60
    success_F = alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['study_success_rating'] == 'success'), 'Forget'].sum() / alt_data['study_success_rating'].value_counts()[1]
    view_negative_F =  alt_data.loc[(alt_data['scene_valence'] == 'negative') & (alt_data['instruction'] == 'view'), 'Forget'].sum() / 60
    view_neutral_F = alt_data.loc[(alt_data['scene_valence'] == 'neutral') & (alt_data['instruction'] == 'view'), 'Forget'].sum() / 60

    # alt_data.loc[(alt_data['old_new'] == 'old') & (alt_data['study_success_resp'] == "na"),'study_success_resp']='view'

    # Step 4
    lme_data = beh_data[lme_col_names]
    #clean up study_success_resp variable to include view trials 
    lme_data.loc[(lme_data['old_new'] == 'old') & (lme_data['study_success_rating'] == "na"),'study_success_rating']='view'
    # Update long data
    lme_test_data = lme_test_data.append(lme_data)
    print(sub)
    
    # Step 5 update dataframes with new measures
    
    # wide 
    
    hit_list_temp = [{
    'participant'                 : sub,
    'study_cb'                    : study_cb,
    'list'                        : studylist,
    "dec_ob_neg"                  : hit_decrease_object_negative,  
    "dec_bg_neg"                  : hit_decrease_background_negative,
    "view_ob_neg"                 : hit_view_object_negative,
    "view_bg_neg"                 : hit_view_background_negative,
    "view_ob_neutral"             : hit_view_object_neutral, 
    "view_bg_neutral"             : hit_view_background_neutral,
    "success_ob_neg"              : hit_success_decrease_object_negative,
    "success_bg_neg"              : hit_success_decrease_background_negative,
    "failure_ob_neg"              : hit_failure_decrease_object_negative,
    "failure_bg_neg"              : hit_failure_decrease_background_negative,
    "fa_ob_neg"                   : FA_objects_negative,
    "fa_ob_neutral"               : FA_objects_neutral,
    "fa_bg_neutral"               : FA_backgrounds_neutral
    }]
    
    hit_list_temp = pd.DataFrame(hit_list_temp)
        
    cr_list_temp = [{
    'participant'                 : sub,
    'study_cb'                    : study_cb,
    'list'                        : studylist,
    "dec_ob_neg"                  : CR_decrease_object_negative,  
    "dec_bg_neg"                  : CR_decrease_background_negative,
    "view_ob_neg"                 : CR_view_object_negative,
    "view_bg_neg"                 : CR_view_background_negative,
    "view_ob_neutral"             : CR_view_object_neutral, 
    "view_bg_neutral"             : CR_view_background_neutral,
    "success_ob_neg"              : CR_success_decrease_object_negative,
    "success_bg_neg"              : CR_success_decrease_background_negative,
    "failure_ob_neg"              : CR_failure_decrease_object_negative,
    "failure_bg_neg"              : CR_failure_decrease_background_negative 
    }]      
    cr_list_temp = pd.DataFrame(cr_list_temp)
    
    tradeoff_temp = [{
    'participant'                 : sub,
    'study_cb'                    : study_cb,
    'list'                        : studylist,
    "dec_neg_intact"              : decrease_negative_OBBG,  
    "view_neg_intact"             : view_negative_OBBG,
    "view_neutral_intact"         : view_neutral_OBBG,  
    "success_neg_intact"          : success_OBBG,  
    "failure_neg_intact"          : failure_OBBG,
    "dec_neg_emto"                : decrease_negative_OB,  
    "view_neg_emto"               : view_negative_OB,
    "view_neutral_emto"           : view_neutral_OB,  
    "success_neg_emto"            : success_OB,  
    "failure_neg_emto"            : failure_OB,
    "dec_neg_reverse"             : decrease_negative_BG,  
    "view_neg_reverse"            : view_negative_BG,
    "view_neutral_reverse"        : view_neutral_BG,  
    "success_neg_reverse"         : success_BG,  
    "failure_neg_reverse"         : failure_BG,
    "dec_neg_forget"              : decrease_negative_F,  
    "view_neg_forget"             : view_negative_F,
    "view_neutral_forget"         : view_neutral_F,  
    "success_neg_forget"          : success_F,  
    "failure_neg_forget"          : failure_F
    }]
    tradeoff_temp = pd.DataFrame(tradeoff_temp)
    # long for graphs
    
    # hit rates
    hit_list           = pd.concat([hit_list, hit_list_temp])
    
    hit_result         = hit_list_temp
    hit_result.columns = [['id','cb','list','dec','dec','view','view','view','view','success','success','failure','failure','fa','fa','fa'],
                       ['id','cb','list','object','background','object','background','object','background','object','background','object','background','object','object','background'],
                       ['id','cb','list','neg','neg','neg','neg','neutral','neutral','neg','neg','neg','neg','neg','neutral','neutral']]
    
    hit_long_melted_df                    = hit_result.melt(id_vars = ['id','cb','list'], col_level = 0, value_name = 'hit_rate', var_name = 'study_condition')
    hit_long_melted_df['scene_component'] = hit_result.melt(id_vars = ['id','cb','list'], col_level = 1)['variable']
    hit_long_melted_df['valence']         = hit_result.melt(id_vars = ['id','cb','list'], col_level = 2)['variable']
    hit_long_melted_df.sort_values('id', inplace=True)
    #combine dataframes
    memory_melt = pd.concat([memory_melt, hit_long_melted_df])
    
    # corrected hit rates
    cr_list            = pd.concat([cr_list, cr_list_temp])
    
    cr_result          = cr_list_temp
    cr_result.columns = [['id','cb','list','dec','dec','view','view','view','view','success','success','failure','failure'],
                       ['id','cb','list','object','background','object','background','object','background','object','background','object','background'],
                       ['id','cb','list','neg','neg','neg','neg','neutral','neutral','neg','neg','neg','neg']]
    
    cr_list_melted_df                    = cr_result.melt(id_vars = ['id','cb','list'], col_level = 0, value_name = 'corrected_hr', var_name = 'study_condition')
    cr_list_melted_df['scene_component'] = cr_result.melt(id_vars = ['id','cb','list'], col_level = 1)['variable']
    cr_list_melted_df['valence']         = cr_result.melt(id_vars = ['id','cb','list'], col_level = 2)['variable']
    cr_list_melted_df.sort_values('id', inplace=True)
    #combine dataframes 
    cr_melt = pd.concat([cr_melt, cr_list_melted_df])
    
    # Trade-off
    to_list     = to_list.append(tradeoff_temp, ignore_index=True) 
    to_list_df  = to_list

    intact  = pd.melt(to_list_df, id_vars = ['participant','study_cb','list'], value_vars = ["dec_neg_intact", "view_neg_intact", "view_neutral_intact", "success_neg_intact", "failure_neg_intact"], var_name = "study_condition", value_name = "intact")
    emto    = pd.melt(to_list_df, id_vars = ['participant','study_cb','list'], value_vars = ["dec_neg_emto", "view_neg_emto", "view_neutral_emto", "success_neg_emto", "failure_neg_emto"], var_name = "study_condition", value_name = "emto")
    reverse = pd.melt(to_list_df, id_vars = ['participant','study_cb','list'], value_vars = ["dec_neg_reverse", "view_neg_reverse", "view_neutral_reverse", "success_neg_reverse", "failure_neg_reverse"], var_name = "study_condition", value_name = "reverse")
    forget  = pd.melt(to_list_df, id_vars = ['participant','study_cb','list'], value_vars = ["dec_neg_forget", "view_neg_forget", "view_neutral_forget", "success_neg_forget", "failure_neg_forget"], var_name = "study_condition", value_name = "forget")
    
    intact['study_condition']  = intact['study_condition'].str.replace(r'_intact', '')
    emto['study_condition']    = emto['study_condition'].str.replace(r'_emto', '')
    reverse['study_condition'] = reverse['study_condition'].str.replace(r'_reverse', '')
    forget['study_condition']  = forget['study_condition'].str.replace(r'_forget', '')
    
    results_ie  = pd.merge(intact, emto, on = ["study_condition",'participant','study_cb','list'])
    results_ier = pd.merge(results_ie, reverse, on = ["study_condition",'participant','study_cb','list'])
    results_to  = pd.merge(results_ier, forget, on = ["study_condition",'participant','study_cb','list']) 
    
    combined_alt = pd.concat([combined_alt,results_to])
    combined_alt.sort_values('participant', inplace=True)
    # Step 6 save csv files
 
lme_data_file = analyses_dir / 'lme_data.csv'
lme_test_data.to_csv(lme_data_file, index=False)

hit_list_data_file = analyses_dir / 'hit_fa_data.csv'
hit_list.to_csv(hit_list_data_file, index=False)

hit_long_data_file = analyses_dir / 'hit_fa_data_longgraphs.csv'
hit_long_melted_df.to_csv(hit_long_data_file, index=False)   

cr_list_data_file = analyses_dir / 'memory_measures_data.csv'
cr_list.to_csv(cr_list_data_file, index=False)

cr_list_melt_data_file = analyses_dir / 'memory_measures_data_longgraphs.csv'
cr_list_melted_df.to_csv(cr_list_melt_data_file, index=False)

to_list_data_file = analyses_dir / 'tradeoff_data.csv'
to_list.to_csv(to_list_data_file, index=False)

combined_alt_data_file = analyses_dir / 'tradeoff_data_longgraphs.csv'
combined_alt.to_csv(combined_alt_data_file, index=False)