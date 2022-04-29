%% Data Analysi
% ADD HELP INFO NICK

%% Clear workspace
clear all;
clc;

%% Define main directories
% Directories
%% Define main directories
directories.top        = 'C:\Users\nyeh\Desktop\fall_2021\NDG\exp1\data';
directories.raw        = fullfile(directories.top, 'raw');
directories.analyses   = fullfile(directories.top, 'analyses');
directories.data_files = fullfile(directories.analyses, 'data_files');

%% Get participant list to analyze
% Read in participants.tsv file from data_files
% par_log_file = fullfile(directories.raw, 'participants.tsv');
% par_log_opts = detectImportOptions(par_log_file, 'FileType', 'text' );
% par_log      = readtable( par_log_file, par_log_opts );

% Read all in source data
participant_list = dir(fullfile(directories.data_files,'sub-*'));
participant_list = {participant_list.name};

% Create an empty cell arrays to store data. Data will be in long format
hit_fa_data                  = {'participant' 'study_cb' 'list' 'study_condition' 'proportion'};
hit_fa_datagraphs            = {'participant' 'study_cb' 'list' 'study_condition' 'sc' 'valence' 'proportion'};
memory_acc_data              = {'participant' 'study_cb' 'list' 'study_instruction_condition' 'corrected_recognition'};
memory_acc_datagraphs        = {'participant' 'study_cb' 'list' 'study_instruction_condition' 'scene_component' 'valence' 'corrected_recognition'};
tradeoff_datagraphs          = {'participant' 'study_cb' 'list' 'study_instruction_condition' 'tradeoff_index' 'intact' 'OB' 'BG' 'F'};
reappraisal_strategy_success = {'participant' 'success_object_hit' 'success_background_hit' 'success_total' 'failure_object_hit' 'failure_background_hit' 'failure_total'};
arousal_data                 = {'participant' 'study_cb' 'list' 'study_condition' 'arousal_ratings' 'arousal_intact' 'arousal_ob' 'arousal_bg' 'arousal_f'};

lme_test_data = array2table(zeros(0,20), 'VariableNames',{'id' 'list' 'cb' 'item_acc' 'sc_type' 'sc_valence' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp' 'test_item_resp' 'test_type_rt' 'original_scene' 'sc_image' 'sc_code' 'test_trial' 'study_trial' 'block_trial' 'block_number'});
lme_180       = array2table(zeros(0,20), 'VariableNames',{'id' 'list' 'cb' 'item_acc' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp'  'original_scene' 'sc_code' 'test_trial' 'memory_type' 'Intact' 'Forget' 'Rearrange_OB' 'Rearrange_BG' 'study_trial' 'block_trial' 'block_number'});
%% Loop through participants
for pari = 1:length(participant_list)
    
    %% Step 1: Gather Participant ID and make directories
    % Convert participant to char type
    participant = participant_list{pari};
    
    % Print info to screen
    fprintf('\n\nProcessing data for %s:\n\n',participant);
    
    % Make directory structure in data
    directories.par_analysis = fullfile(directories.data_files, participant);
    
    % Load behavioral data
    data_file = fullfile(directories.par_analysis,sprintf('%s_task-studytest_beh.tsv',participant));
    opts       = detectImportOptions(data_file, 'FileType', 'text');
    test_data  = readtable(data_file, opts);
    
    % Assign counterbanacing information
    study_cb = cell2mat(test_data.cb(1));
    list = test_data.list(1);
    %% Step 2: get responses: old/new, scene component, valence, study instructions and success
    
    old_resp = ismember(test_data.test_item_resp,1);
    new_resp = ismember(test_data.test_item_resp,0);
    old_trial  = ismember(test_data.old_new,'old');
    new_trial = ismember(test_data.old_new,'new');
    
    %check hit/fa/miss/cr
    hit = sum(old_resp & old_trial);
    miss = sum(~old_resp & old_trial);
    cr = sum(~old_resp & new_trial);
    fa = sum(old_resp & new_trial);
    
    check_total = (hit + miss + cr + fa);
    if check_total ~= 520
        error('There should be 520 responses %s',participant)
        
    end
    
    success = ismember(test_data.study_success_resp, 'success');
    failure = ismember(test_data.study_success_resp, 'failure');
    reappraisal = ismember(test_data.study_instruction, 'decrease');
    view = ismember(test_data.study_instruction,'view');
    object = ismember(test_data.sc_type,'object');
    background = ismember(test_data.sc_type,'background');
    % Valence of the scene component (object, background)
    negative = ismember(test_data.sc_valence, 'negative');
    neutral = ismember(test_data.sc_valence, 'neutral');
    %scene valence (negative or neutral)
    scene_negative = ismember(test_data.scene_valence,'negative');
    scene_neutral = ismember(test_data.scene_valence,'neutral');
    
    %% Step 3 compute hit rates for objects/backgrounds and negative and neutral scenes for success and failure
    
    hit_decrease_object_negative = (sum(old_trial & old_resp & reappraisal & object & negative)/60);
    d_o_n = sum(old_trial & old_resp & reappraisal & object & negative);
    
    hit_decrease_background_negative = (sum(old_trial & old_resp & reappraisal & background & scene_negative)/60);
    d_b_n = sum(old_trial & old_resp & reappraisal & background & neutral);
    
    hit_view_object_negative = (sum(old_trial & old_resp & view & object & negative)/60);
    v_o_n = sum(old_trial & old_resp & view & object & negative);
    
    hit_view_background_negative = (sum(old_trial & old_resp & view & background & scene_negative)/60);
    v_b_n = sum(old_trial & old_resp & view & background & scene_negative );
    
    hit_view_object_neutral = (sum(old_trial & old_resp & view & object & neutral)/60);
    v_o_neu = sum(old_trial & old_resp & view & object & neutral);
    
    hit_view_background_neutral = (sum(old_trial & old_resp & view & background & scene_neutral)/60);
    v_b_neu = sum(old_trial & old_resp & view & background & scene_neutral);
    
    % check old hits match up with study instructions x valence x SC
    old_hit = sum(old_trial & old_resp);
    hit = sum(old_resp & old_trial);
    old_hit_2 = sum(old_trial & ismember(test_data.old_new_resp,'old')) ;
    total = d_o_n + d_b_n + v_o_n + v_b_n  + v_o_neu + v_b_neu;
    
    %check if hits are matching up
    if old_hit ~= old_hit_2 | old_hit ~= total
        error('participant responses dont match response totals %s',participant)
        
    end
    
    % success and failure hit rates
    hit_success_decrease_object_negative = ...
        (sum(old_trial & old_resp & reappraisal & object & scene_negative & success)/(sum(success)/2));
    hit_success_decrease_background_negative = ...
        (sum(old_trial & old_resp & reappraisal & scene_negative & background & success)/(sum(success)/2));
    
    hit_failure_decrease_object_negative = ...
        (sum(old_trial & old_resp & reappraisal & object & scene_negative & failure)/(sum(failure)/2));
    hit_failure_decrease_background_negative = ...
        (sum(old_trial & old_resp & reappraisal & scene_negative & background & failure)/(sum(failure)/2));
    
    
    %check if hits are matching up for success/failure and reappraisal
    
    reappraisal_count1 = (sum(reappraisal & old_trial & old_resp));
    reappraisal_count2 = d_o_n + d_b_n;
    if reappraisal_count1 ~= reappraisal_count2
        error('participant success and failure counts dont match reappraisal trails %s',participant)
        
    end
    %% step 4 compute false alarms
    
    FA_objects_negative = (sum(new_trial & old_resp & object & negative)/60);
    FA_objects_neutral = (sum(new_trial & old_resp & object & neutral)/20);
    FA_backgrounds_neutral = (sum(new_trial & old_resp & background & neutral)/80);
    
    %% step 5 corrected recognition
    
    % decrease condition for negative objects/backgrounds
    CR_decrease_object_negative = (hit_decrease_object_negative - FA_objects_negative);
    CR_decrease_background_negative = (hit_decrease_background_negative - FA_backgrounds_neutral);
    
    % view condition for negative objects/backgrounds
    CR_view_object_negative = (hit_view_object_negative - FA_objects_negative);
    CR_view_background_negative = (hit_view_background_negative - FA_backgrounds_neutral);
    % view condition for neutral object/backgrounds
    CR_view_object_neutral = (hit_view_object_neutral-FA_objects_neutral );
    CR_view_background_neutral = (hit_view_background_neutral - FA_backgrounds_neutral);
    
    % success condition for decrease object/backgrounds
    CR_success_decrease_object_negative = (hit_success_decrease_object_negative-FA_objects_negative);
    CR_success_decrease_background_negative = (hit_success_decrease_background_negative-FA_backgrounds_neutral);
    
    % failure condition for decrease object/backgrounds
    CR_failure_decrease_object_negative = (hit_failure_decrease_object_negative-FA_objects_negative);
    CR_failure_decrease_background_negative = (hit_failure_decrease_background_negative-FA_backgrounds_neutral);
    
    
    
    %% Check different Trade-off approach (R OB/BG, R OB/ F BG, F OB/BG, F OB, R BG)
    old_test_data = test_data;
    old_test_data(ismember(old_test_data.old_new,'new'),:)=[];
    old_test_data.Intact       = nan(size(old_test_data,1),1);
    old_test_data.Forget       = nan(size(old_test_data,1),1);
    old_test_data.Rearrange_OB = nan(size(old_test_data,1),1);
    old_test_data.Rearrange_BG = nan(size(old_test_data,1),1);
    
    for trli = 1:180
        test_idx = find(old_test_data.sc_code == trli);
        if ismember(old_test_data.old_new_resp(test_idx(1)), 'old') & ismember(old_test_data.old_new_resp(test_idx(2)), 'old') % Remember Object and background
            old_test_data.Intact(test_idx(1)) = 1;
            old_test_data.Intact(test_idx(2)) = 1;
        elseif ismember(old_test_data.old_new_resp(test_idx(1)), 'old') &  ismember(old_test_data.sc_type(test_idx(1)), 'object') & ismember(old_test_data.old_new_resp(test_idx(2)), 'new') % Remember Object forget background
            old_test_data.Rearrange_OB(test_idx(1)) = 1;
            old_test_data.Rearrange_OB(test_idx(2)) = 1;
        elseif ismember(old_test_data.old_new_resp(test_idx(2)), 'old') &  ismember(old_test_data.sc_type(test_idx(2)), 'object') & ismember(old_test_data.old_new_resp(test_idx(1)), 'new') % Remember Object forget background
            old_test_data.Rearrange_OB(test_idx(1)) = 1;
            old_test_data.Rearrange_OB(test_idx(2)) = 1;
        elseif ismember(old_test_data.old_new_resp(test_idx(1)), 'new') & ismember(old_test_data.old_new_resp(test_idx(2)), 'new') % forget object and background
            old_test_data.Forget(test_idx(1)) = 1;
            old_test_data.Forget(test_idx(2)) = 1;
        else %Remember Background forget Object
            old_test_data.Rearrange_BG(test_idx(1)) = 1;
            old_test_data.Rearrange_BG(test_idx(2)) = 1;
        end
    end
    %remove duplicate rows
    A = old_test_data.sc_code;
    [~,idx]=unique(A,'rows','first');
    old_test_data_180 =old_test_data(sort(idx),:);
    old_test_data_180.Intact(isnan(old_test_data_180.Intact))=0; % reduced trade-off
    old_test_data_180.Rearrange_OB(isnan(old_test_data_180.Rearrange_OB))=0; %trade-off
    old_test_data_180.Rearrange_BG(isnan(old_test_data_180.Rearrange_BG))=0; %reverse trade-off?
    old_test_data_180.Forget(isnan(old_test_data_180.Forget))=0; % miss
    
    % add in memory type variable
    old_test_data_180.memory_type = cell(size(old_test_data_180,1),1);
    for m = 1:size(old_test_data_180,1)
        if old_test_data_180.Intact(m) == 1;
            old_test_data_180.memory_type{m} = 'intact';
        elseif old_test_data_180.Rearrange_OB(m) == 1;
            old_test_data_180.memory_type{m} = 'Rearrange_OB';
        elseif old_test_data_180.Rearrange_BG(m) == 1;
            old_test_data_180.memory_type{m}= 'Rearrange_BG';
        elseif old_test_data_180.Forget(m) == 1;
            old_test_data_180.memory_type{m}= 'Forget';
        else
            old_test_data_180.memory_type{m}= 'ERROR';
        end
    end
    
    
    negative_180  = ismember(old_test_data_180.scene_valence, 'negative');
    success_180   = ismember(old_test_data_180.study_success_resp, 'success');
    decrease_180  = ismember(old_test_data_180.study_instruction,'decrease');
    failure_180   = ismember(old_test_data_180.study_success_resp, 'failure');
    view_180      = ismember(old_test_data_180.study_instruction,'view');
    neutral_180   = ismember(old_test_data_180.scene_valence, 'neutral');
    
    decrease_negative_OB = sum(old_test_data_180.Rearrange_OB & negative_180 & decrease_180)/60;
    decrease_negative_OBBG = sum(old_test_data_180.Intact & negative_180 & decrease_180)/60;
    decrease_negative_BG = sum(old_test_data_180.Rearrange_BG & negative_180 & decrease_180)/60;
    decrease_negative_F = sum(old_test_data_180.Forget & negative_180 & decrease_180)/60;
    
    success_OB = sum(old_test_data_180.Rearrange_OB & negative_180 & success_180)/sum(success_180);
    success_OBBG = sum(old_test_data_180.Intact & negative_180 & success_180)/sum(success_180);
    success_BG = sum(old_test_data_180.Rearrange_BG & negative_180 & success_180)/sum(success_180);
    success_F = sum(old_test_data_180.Forget & negative_180 & success_180)/sum(success_180);
    
    failure_OB = sum(old_test_data_180.Rearrange_OB & negative_180 & failure_180)/sum(failure_180);
    failure_OBBG = sum(old_test_data_180.Intact & negative_180 & failure_180)/sum(failure_180);
    failure_BG = sum(old_test_data_180.Rearrange_BG & negative_180 & failure_180)/sum(failure_180);
    failure_F = sum(old_test_data_180.Forget & negative_180 & failure_180)/sum(failure_180);
    
    view_negative_OB = sum(old_test_data_180.Rearrange_OB & negative_180 & view_180)/60;
    view_negative_OBBG = sum(old_test_data_180.Intact & negative_180 & view_180)/60;
    view_negative_BG = sum(old_test_data_180.Rearrange_BG & negative_180 & view_180)/60;
    view_negative_F = sum(old_test_data_180.Forget & negative_180 & view_180)/60;
    
    view_neutral_OB = sum(old_test_data_180.Rearrange_OB & neutral_180 & view_180)/60;
    view_neutral_OBBG = sum(old_test_data_180.Intact & neutral_180 & view_180)/60;
    view_neutral_BG = sum(old_test_data_180.Rearrange_BG & neutral_180 & view_180)/60;
    view_neutral_F = sum(old_test_data_180.Forget & neutral_180 & view_180)/60;
    
    % Check trade-off index
    index_decrease     = CR_decrease_object_negative - CR_decrease_background_negative;
    index_success      = CR_success_decrease_object_negative - CR_success_decrease_background_negative;
    index_failure      = CR_failure_decrease_object_negative - CR_failure_decrease_background_negative;
    index_view_neg     = CR_view_object_negative - CR_view_background_negative;
    index_view_neutral = CR_view_object_neutral - CR_view_background_neutral;
    % graphs
    
    %         tradeoff_datagraphs = vertcat(tradeoff_datagraphs, ...
    %         horzcat({participant},{study_cb},{list},{'decrease'},{'intact'},decrease_negative_OBBG), ...
    %         horzcat({participant},{study_cb},{list},{'decrease'},{'OB'},decrease_negative_OB), ...
    %         horzcat({participant},{study_cb},{list},{'decrease'},{'BG'},decrease_negative_BG), ...
    %         horzcat({participant},{study_cb},{list},{'decrease'},{'F'},decrease_negative_F), ...
    %         horzcat({participant},{study_cb},{list},{'view_negative'},{'intact'},view_negative_OBBG), ...
    %         horzcat({participant},{study_cb},{list},{'view_negative'},{'OB'},view_negative_OB), ...
    %         horzcat({participant},{study_cb},{list},{'view_negative'},{'BG'},view_negative_BG), ...
    %         horzcat({participant},{study_cb},{list},{'view_negative'},{'F'},view_negative_F), ...
    %         horzcat({participant},{study_cb},{list},{'view_neutral'},{'intact'},view_neutral_OBBG), ...
    %         horzcat({participant},{study_cb},{list},{'view_neutral'},{'OB'},view_neutral_OB), ...
    %         horzcat({participant},{study_cb},{list},{'view_neutral'},{'BG'},view_neutral_BG), ...
    %         horzcat({participant},{study_cb},{list},{'view_neutral'},{'F'},view_neutral_F), ...
    %         horzcat({participant},{study_cb},{list},{'success'},{'intact'},success_OBBG), ...
    %         horzcat({participant},{study_cb},{list},{'success'},{'OB'},success_OB), ...
    %         horzcat({participant},{study_cb},{list},{'success'},{'BG'},success_BG), ...
    %         horzcat({participant},{study_cb},{list},{'success'},{'F'},success_F), ...
    %         horzcat({participant},{study_cb},{list},{'failure'},{'intact'},failure_OBBG), ...
    %         horzcat({participant},{study_cb},{list},{'failure'},{'OB'},failure_OB), ...
    %         horzcat({participant},{study_cb},{list},{'failure'},{'BG'},failure_BG), ...
    %         horzcat({participant},{study_cb},{list},{'failure'},{'F'},failure_F));
    
    
    %% Step save and organize data for LME analysis
    LME_vars_keep = { 'id' 'list' 'cb' 'item_acc' 'sc_type' 'sc_valence' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp' 'test_item_resp' 'test_type_rt' 'original_scene' 'sc_image' 'sc_code' 'test_trial' 'study_trial' 'block_trial' 'block_number'};
    LME_data = old_test_data_180;
    LME_data = LME_data( :, ismember(LME_data.Properties.VariableNames, LME_vars_keep) );
    % Move them in the data table
    LME_data = movevars(LME_data,{'list' 'cb' 'item_acc' 'sc_type' 'sc_valence' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp' 'test_item_resp' 'test_type_rt' 'original_scene' 'sc_image' 'sc_code' 'test_trial' 'study_trial' 'block_trial' 'block_number'},'After','id');
    tt = ismember(LME_data.study_success_resp, 'na') & ismember(LME_data.old_new,'old');
    LME_data.study_success_resp(tt) = {'view'};
    lme_test_data = [lme_test_data; LME_data];
    
    
    LME180_vars_keep = { 'id' 'list' 'cb' 'item_acc' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp' 'original_scene' 'sc_code' 'test_trial' 'memory_type' 'Intact' 'Forget' 'Rearrange_OB' 'Rearrange_BG' 'study_trial' 'block_trial' 'block_number'};
    LME180_data = old_test_data_180;
    LME180_data = LME180_data( :, ismember(LME180_data.Properties.VariableNames, LME180_vars_keep) );
    % Move them in the data table
    LME180_data = movevars(LME180_data,{'list' 'cb' 'item_acc' 'scene_valence' 'old_new' 'study_instruction' 'study_success_resp' 'study_arousal_resp'  'original_scene' 'sc_code' 'test_trial' 'memory_type' 'Intact' 'Forget' 'Rearrange_OB' 'Rearrange_BG' 'study_trial' 'block_trial' 'block_number'},'After','id');
    tt180 = ismember(LME180_data.study_success_resp, 'na') & ismember(LME180_data.old_new,'old');
    LME180_data.study_success_resp(tt180) = {'view'};
    lme_180 = [lme_180; LME180_data];
    
    %sum(success_OB +failure_OB  + success_OBBG +failure_OBBG+success_BG+failure_BG+success_F+failure_F );
    %% Step 6 store data
    hit_fa_data = vertcat(hit_fa_data, ...
        horzcat({participant},{study_cb},{list},{'decrease_objects_negative'},hit_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'decrease_background_negative'},hit_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view_objects_negative'},hit_view_object_negative), ...
        horzcat({participant},{study_cb},{list},{'view_background_negative'},hit_view_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view_objects_neutral'},hit_view_object_neutral), ...
        horzcat({participant},{study_cb},{list},{'view_background_neutral'},hit_view_background_neutral), ...
        horzcat({participant},{study_cb},{list},{'success_decrease_objects_negative'},hit_success_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'success_decrease_background_negative'},hit_success_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'failure_decrease_objects_negative'},hit_failure_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'failure_decrease_background_negative'},hit_failure_decrease_background_negative),...
        horzcat({participant},{study_cb},{list},{'FA_negative_object'},FA_objects_negative),...
        horzcat({participant},{study_cb},{list},{'FA_neutral_object'},FA_objects_neutral),...
        horzcat({participant},{study_cb},{list},{'FA_neutral_background'},FA_backgrounds_neutral));
    % Store hit and FA data
    hit_fa_datagraphs = vertcat(hit_fa_datagraphs, ...
        horzcat({participant},{study_cb},{list},{'decrease'},{'objects'},{'negative'},hit_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'decrease'},{'background'},{'negative'},hit_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'objects'},{'negative'},hit_view_object_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'background'},{'negative'},hit_view_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'objects'},{'neutral'},hit_view_object_neutral), ...
        horzcat({participant},{study_cb},{list},{'view'},{'background'},{'neutral'},hit_view_background_neutral), ...
        horzcat({participant},{study_cb},{list},{'success'},{'objects'},{'negative'},hit_success_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'success'},{'background'},{'negative'},hit_success_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'failure'},{'objects'},{'negative'},hit_failure_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'failure'},{'background'},{'negative'},hit_failure_decrease_background_negative),...
        horzcat({participant},{study_cb},{list},{'FA'},{'objects'},{'negative'},FA_objects_negative),...
        horzcat({participant},{study_cb},{list},{'FA'},{'objects'},{'negative'},FA_objects_neutral),...
        horzcat({participant},{study_cb},{list},{'FA'},{'objects'},{'negative'},FA_backgrounds_neutral));
    
    % Store HR-FAR, SM data
    memory_acc_data = vertcat(memory_acc_data, ...
        horzcat({participant},{study_cb},{list},{'decrease_objects_negative_CR'},CR_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'decrease_background_negative_CR'},CR_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view_objects_negative_CR'},CR_view_object_negative), ...
        horzcat({participant},{study_cb},{list},{'view_background_negative_CR'},CR_view_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view_objects_neutral_CR'},CR_view_object_neutral), ...
        horzcat({participant},{study_cb},{list},{'view_background_neutral_CR'},CR_view_background_neutral), ...
        horzcat({participant},{study_cb},{list},{'success_decrease_objects_negative_CR'},CR_success_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'success_decrease_background_negative_CR'},CR_success_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'failure_decrease_objects_negative_CR'},CR_failure_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'failure_decrease_background_negative_CR'},CR_failure_decrease_background_negative));
    % graphs
    memory_acc_datagraphs = vertcat(memory_acc_datagraphs, ...
        horzcat({participant},{study_cb},{list},{'decrease'},{'objects'},{'negative'},CR_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'decrease'},{'background'},{'negative'},CR_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'objects'},{'negative'},CR_view_object_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'background'},{'negative'},CR_view_background_negative), ...
        horzcat({participant},{study_cb},{list},{'view'},{'objects'},{'neutral'},CR_view_object_neutral), ...
        horzcat({participant},{study_cb},{list},{'view'},{'background'},{'neutral'},CR_view_background_neutral), ...
        horzcat({participant},{study_cb},{list},{'success'},{'objects'},{'negative'},CR_success_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'success'},{'background'},{'negative'},CR_success_decrease_background_negative), ...
        horzcat({participant},{study_cb},{list},{'failure'},{'objects'},{'negative'},CR_failure_decrease_object_negative), ...
        horzcat({participant},{study_cb},{list},{'failure'},{'background'},{'negative'},CR_failure_decrease_background_negative));
    
    tradeoff_datagraphs = vertcat(tradeoff_datagraphs, ...
        horzcat({participant},{study_cb},{list},{'decrease'},index_decrease, decrease_negative_OBBG, decrease_negative_OB, decrease_negative_BG, decrease_negative_F), ...
        horzcat({participant},{study_cb},{list},{'view_negative'},index_view_neg, view_negative_OBBG,view_negative_OB,view_negative_BG,view_negative_F), ...
        horzcat({participant},{study_cb},{list},{'view_neutral'},index_view_neutral, view_neutral_OBBG,view_neutral_OB,view_neutral_BG,view_neutral_F), ...
        horzcat({participant},{study_cb},{list},{'success'},index_success, success_OBBG,success_OB,success_BG,success_F), ...
        horzcat({participant},{study_cb},{list},{'failure'},index_failure, failure_OBBG,failure_OB,failure_BG,failure_F));
    
    % arousal ratings
    arousal_ratings         = test_data.study_arousal_resp;
    arousal_180_ratings     = old_test_data_180.study_arousal_resp;
    
    success_180             = ismember(old_test_data_180.study_success_resp, 'success');
    failure_180             = ismember(old_test_data_180.study_success_resp, 'failure');
    reappraisal_180         = ismember(old_test_data_180.study_instruction, 'decrease');
    view_negative_180       = (ismember(old_test_data_180.study_instruction,'view') & ismember(old_test_data_180.scene_valence,'negative'));
    view_neutral_180        = (ismember(old_test_data_180.study_instruction,'view') & ismember(old_test_data_180.scene_valence,'neutral'));
    intact                  = ismember(old_test_data_180.Intact,1);
    Rearrange_OB            = ismember(old_test_data_180.Rearrange_OB,1);
    Rearrange_BG            = ismember(old_test_data_180.Rearrange_BG,1);
    Forget                  = ismember(old_test_data_180.Forget,1);
    
    arousal_data = vertcat(arousal_data, ...
        { participant study_cb list 'decrease' mean(arousal_ratings(old_trial & reappraisal & negative)) mean(arousal_180_ratings(intact & reappraisal_180)) mean(arousal_180_ratings(Rearrange_OB & reappraisal_180)) mean(arousal_180_ratings(Rearrange_BG & reappraisal_180)) mean(arousal_180_ratings(Forget & reappraisal_180))}, ...
        { participant study_cb list 'success' mean(arousal_ratings(old_trial & reappraisal & success & negative)) mean(arousal_180_ratings(intact & success_180)) mean(arousal_180_ratings(Rearrange_OB & success_180)) mean(arousal_180_ratings(Rearrange_BG & success_180)) mean(arousal_180_ratings(Forget & success_180)) }, ...
        { participant study_cb list 'failure' mean(arousal_ratings(old_trial & reappraisal & failure & negative)) mean(arousal_180_ratings(intact & failure_180)) mean(arousal_180_ratings(Rearrange_OB & failure_180)) mean(arousal_180_ratings(Rearrange_BG & failure_180)) mean(arousal_180_ratings(Forget & failure_180))}, ...
        { participant study_cb list 'view_negative' mean(arousal_ratings(old_trial & view & negative)) mean(arousal_180_ratings(intact & view_negative_180)) mean(arousal_180_ratings(Rearrange_OB & view_negative_180)) mean(arousal_180_ratings(Rearrange_BG & view_negative_180)) mean(arousal_180_ratings(Forget & view_negative_180)) }, ...
        { participant study_cb list 'view_neutral' mean(arousal_ratings(old_trial & view & neutral)) mean(arousal_180_ratings(intact & view_neutral_180)) mean(arousal_180_ratings(Rearrange_OB & view_neutral_180)) mean(arousal_180_ratings(Rearrange_BG & view_neutral_180)) mean(arousal_180_ratings(Forget & view_neutral_180))} );
    
    % create log of participants with success/failure counts.
    count_success = sum(success)/2; %divide by 2 because object/backgrounds are counted twice
    count_failure = sum(failure)/2; %divide by 2 because object/backgrounds are counted twice
    
    success_object_count_hit = sum(old_trial & old_resp & reappraisal & object & scene_negative & success);
    success_count = sum(success)/2;
    success_background_count = sum(old_trial & old_resp & reappraisal & scene_negative & background & success);
    failure_object_count = sum(old_trial & old_resp & reappraisal & object & scene_negative & failure);
    failure_background_count = sum(old_trial & old_resp & reappraisal & scene_negative & background & failure);
    failure_count = sum(failure)/2;
    
    reappraisal_strategy_success = vertcat(reappraisal_strategy_success, ...
        { participant success_object_count_hit success_background_count success_count failure_object_count failure_background_count failure_count});
end

%% Make each cell array a data table (in wide and long formats)

% Hit and FA data
hit_fa_data_long = cell2table(hit_fa_data(2:end,:),'VariableNames',hit_fa_data(1,:));
hit_fa_data_wide = unstack(hit_fa_data_long,'proportion','study_condition');
hit_fa_data_wide = movevars(hit_fa_data_wide,{'FA_negative_object'},'After','FA_neutral_background');
% Graphs
hit_fa_data_longgraphs = cell2table(hit_fa_datagraphs(2:end,:),'VariableNames',hit_fa_datagraphs(1,:));

% Accuracy Measure Data
memory_acc_data_long = cell2table(memory_acc_data(2:end,:),'VariableNames',memory_acc_data(1,:));
memory_acc_data_wide = unstack(memory_acc_data_long,{'corrected_recognition'},'study_instruction_condition');
%graphs
memory_acc_data_long_graphs = cell2table(memory_acc_datagraphs(2:end,:),'VariableNames',memory_acc_datagraphs(1,:));

%trade-off
tradeoff_datagraphs_data_long = cell2table(tradeoff_datagraphs(2:end,:),'VariableNames',tradeoff_datagraphs(1,:));

% Study RT Data
% study_rt_data_long = cell2table(study_rt_data(2:end,:),'VariableNames',study_rt_data(1,:));
% study_rt_data_wide = unstack(study_rt_data_long,'median_rt','study_condition');
% study_rt_data_wide = unstack(study_rt_data_wide,{'informed' 'uninformed'},'subsequent_memory');
% study_rt_data_wide.Properties.VariableNames(2:end) = ...
%     cellfun(@(x) strcat(x,'_median_studyrt'), study_rt_data_wide.Properties.VariableNames(2:end), 'UniformOutput', false);

% Study RT Data
arousal_data_long = cell2table(arousal_data(2:end,:),'VariableNames',arousal_data(1,:));
arousal_data_wide = unstack(arousal_data_long,{'arousal_ratings', 'arousal_intact' ,'arousal_ob', 'arousal_bg', 'arousal_f'},'study_condition');

reappraisal_strategy_success_wide = cell2table(reappraisal_strategy_success(2:end,:),'VariableNames',reappraisal_strategy_success(1,:));

%% Write data tables to file
writetable(hit_fa_data_longgraphs,fullfile(directories.analyses,'hit_fa_data_longgraphs.csv'));
writetable(memory_acc_data_long_graphs,fullfile(directories.analyses,'memory_measures_data_longgraphs.csv'));
writetable(hit_fa_data_wide,fullfile(directories.analyses,'hit_fa_data_wide.csv'));
writetable(tradeoff_datagraphs_data_long,fullfile(directories.analyses,'tradeoff_datagraphs.csv'));
writetable(memory_acc_data_wide,fullfile(directories.analyses,'cr_data_wide.csv'));
writetable(arousal_data_wide,fullfile(directories.analyses,'arousal_data_wide.csv'));
writetable(arousal_data_long,fullfile(directories.analyses,'arousal_data_long.csv'));
writetable(reappraisal_strategy_success_wide,fullfile(directories.analyses,'reappraisal_strategy_success.csv'));
writetable(lme_test_data,fullfile(directories.analyses,'lme_data.csv'));
writetable(lme_180,fullfile(directories.analyses,'lme180_data.csv'));