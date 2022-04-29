%% Organize and Quality Control Data

% Step1: Gather Participant ID and make directories

% Step2: Load in study data, format, and check trial count

% Step3: Load in test data, format, and check trial count

% Step4: clean up data, find success trials, and check data (reappraisal and item accuracy)

% Step5: Combine study and test data structures

%% Clear workspace
clear all;
clc;

%% Define main directories

directories.top    = 'C:\Users\nyeh\Desktop\fall_2021\NDG\exp1\data';

% Directories


directories.raw        = fullfile(directories.top, 'raw');
directories.source     = fullfile(directories.top, 'sourcedata');
directories.analyses   = fullfile(directories.top, 'analyses');
directories.data_files = fullfile(directories.analyses, 'data_files');
directories.bad_data   = fullfile(directories.top, 'bad_data');

% Make directories if needed
make_dirs({directories.analyses directories.bad_data directories.data_files});

%% Get participant list to analyze
% Read all in source data
participant_list = dir(fullfile(directories.source,'sub-*'));
participant_list = {participant_list.name};

% Make participant log data table
par_log_columns = {'OG_id' 'id' 'cb' 'list' 'success' 'failure'};
par_log = cell2table( cell(length(participant_list),length(par_log_columns)), ...
    'VariableNames',par_log_columns );

%% Loop through participants
for pari = 1:length(participant_list)
    
    %% Step 1: Gather Participant ID and make directories
    participant = participant_list{pari};
    % Get a new id
    id = sprintf('%03.0f',pari);
    og_id = participant;
    % Print info to screen
    fprintf('\n\nProcessing data for %s:\n\n',participant);
    
    % Make directory structure in data
    directories.par_source   = fullfile(directories.source, participant);
    directories.par_data     = fullfile(directories.raw, sprintf('sub-%s', id) );
    directories.par_analysis = fullfile(directories.data_files, sprintf('sub-%s', id) );
    
    %     % Convert participant to char type
    %     participant = participant_list{pari};
    %
    %     % Print info to screen
    %     fprintf('\n\nProcessing data for %s:\n\n',participant);
    %
    %     % Make directory structure in data
    %     directories.par_source   = fullfile(directories.source, participant);
    %     directories.par_data     = fullfile(directories.raw, participant);
    %     direcotires.par_beh      = fullfile(directories.par_data, 'beh');
    %     directories.par_analysis = fullfile(directories.data_files, participant);
    
    %     % Make directories
    %     make_dirs({directories.par_data directories.par_beh});
    % Make directories
    make_dirs({directories.par_data});
    
    %% Step 2: Load in study data and format
    source_study_beh_file = fullfile( directories.par_source, sprintf('data_PARTICIPANT_study_procedure_%s.csv', participant) );
    study_beh_file = fullfile( directories.par_source , sprintf('%s_task-study_run-crit_beh.csv', participant) );
    vars_to_remove = { 'OS' 'instruction_image_resp_keys' 'instruction_image_resp_rt' 'confirm_image_resp_keys' 'confirm_image_resp_rt'...
        'feedback_key_resp_keys' 'feedback_key_resp_rt' 'confirm_outer_loop_thisRepN' 'confirm_outerloop_thisTrialN'...
        'confirm_outer_loop_thisN' 'confirm_outer_loop_thisTrialN' 'confirm_outer_loop_thisIndex' 'confirm_outer_loop_ran'...
        'confirm_outer_loop_order' 'confirm_inner_loop_thisRepN' 'confirm_inner_loop_thisTrialN'...
        'confirm_inner_loop_thisN' 'confirm_inner_loop_thisIndex' 'confirm_inner_loop_ran' 'confirm_inner_loop_order'...
        'confirm_questions' 'correct_answer' 'phase_instructions' 'trials_thisRepN' 'trials_thisTrialN'...
        'phases_thisRepN' 'phases_thisTrialN'  'phases_ran' 'phases_order' 'trials_thisN' ...
        'trials_ran' 'trials_order' 'success_pic_loop_thisTrialN' 'success_pic_loop_thisN' 'success_pic_loop_thisIndex'...
        'success_pic_loop_ran' 'success_pic_loop_order' 'phases_thisN'...
        'frameRate' 'study_cb' 'psychopyVersion' 'expName' 'setID' 'ran' 'order' 'instruction_cue_started' 'instruction_cue_stopped' ...
        'visual_cue_fixation_started' 'visual_cue_fixation_stopped' 'text_started' 'text_stopped' 'iti_fixation_stopped' ...
        'iti_fixation_started' 'valence_image_started' 'valence_image_stopped' 'blank_screen_started' 'blank_screen_stopped' ...
        'arousal_text_started' 'arousal_text_stopped' 'valence_text_started' 'valence_text_stopped' 'arousal_rating_scale_started'...
        'arousal_rating_scale_stopped' 'valence_rating_scale_started' 'valence_rating_scale_stopped'};
    
    study_opts = detectImportOptions( source_study_beh_file, 'FileType', 'text' );
    study_data = readtable( source_study_beh_file, study_opts );
    study_data = study_data( :, ~ismember(study_data.Properties.VariableNames, vars_to_remove) );
    
    % select experimental trials
    study_rows_keep = contains(study_data.phase_progress,'Real');
    study_data = study_data(study_rows_keep,:);
    
    % Update some variable names at study
    study_data.Properties.VariableNames{'study_arousal_resp_key'} = 'study_arousal_rating';
    study_data.Properties.VariableNames{'phases_thisIndex'} = 'block_number';
    study_data.Properties.VariableNames{'trials_thisIndex'} = 'block_trial';
    
    %check trial count is correct
    n_study_rows = sum(study_rows_keep);
    if n_study_rows ~= 180
        error('There should be 180 rows in the study data for %s',participant);
    end
    
    % Update ID in  data
    study_data.id(:) = {id};
    
    % clean up block order and trial information
    % removing study block counts
    study_data.block_number(:) = study_data.block_number(:)- 2;
    % start block trial order at 1
    study_data.block_trial(:) = study_data.block_trial(:)+ 1 ;
    % add study trial counter
    study_data.study_trial = [1:1:180]';
    
    %% step 3 Load test data
    source_test_beh_file  = fullfile( directories.par_source, sprintf('data_PARTICIPANT_test_procedure_%s.csv', participant) );
    test_opts = detectImportOptions( source_test_beh_file, 'FileType', 'text' );
    test_data = readtable( source_test_beh_file, test_opts );
    % Subselect variables for test data
    vars_to_remove = {'id' 'frameRate' 'expName' 'setID' 'psychopyVersion' 'ran' 'order' 'instructions_itemkey_resp_keys'...
        'instructions_itemkey_resp_rt' 'prac_test_resp_keys' 'prac_test_resp_rt' 'test_phase_thisRepN' 'test_phase_thisTrialN'...
        'test_phase_thisN' 'test_phase_thisIndex' 'test_phase_ran' 'test_phase_order' 'test_instructions' 'test_item_instruction_image'...
        'test_trials_thisRepN' 'test_trials_thisTrialN' 'test_trials_thisN' 'test_trials_thisIndex' 'test_trials_ran'...
        'test_trials_order' 'OS' 'study_instruction' 'study_A_instruction' 'study_instructions_A' 'study_B_instruction' 'study_instructions_B'};
    test_data = test_data( :, ~ismember(test_data.Properties.VariableNames, vars_to_remove) );
    
    % select experimental test trials
    test_rows_keep = contains(test_data.phase_name,'_crit');
    test_data = test_data(test_rows_keep,:);
    
    %check trial count is correct
    n_test_rows = sum(test_rows_keep);
    if n_test_rows ~= 520
        error('There should be 520 rows in the test data for %s',participant);
    end
    
    % Update some variable names at test
    test_data.Properties.VariableNames{'test_type_resp_key'} = 'test_item_resp';
    
    %Update test id
    % temp removed ID varaible for test and added in study ID, this is because
    % study ID is a cell and test ID was double. need to fix in python code.
    % test_data.id(:) = id{:};
    %Update test id
    test_data.id(:) = study_data.id(1);
    %% Step 4 : clean up data, find success trials, and check data (reappraisal and item accuracy)
    %find and clean up reappraisal trials
    study_nr = isempty(study_data.success_resp_keys) | ...
        isnan(study_data.success_resp_keys) | study_data.success_resp_keys == -99;
    study_data.success_resp_keys(study_nr) = -99 ; % Make all study_resp_keys -99
    study_data.success_resp_rt(study_nr)       = -99;
    study_data.study_R_trial         = double( ~study_nr ); % reappraisal trials
    
    % Find the success/failure trials
    for i = 1:sum(study_rows_keep)
        if ismember(study_data.study_success_resp_key{i},'1')
            study_data.study_success_rating{i} = 'success';
        elseif ismember(study_data.study_success_resp_key{i},'0')
            study_data.study_success_rating{i} = 'failure';
            
        else
            study_data.study_success_rating{i} = 'na';
            
        end
    end
    
    % check success and failure trials add up: 60 reappraisal trials.
    failure_count = sum(ismember(study_data.study_success_rating,'failure'));
    succes_count = sum(ismember(study_data.study_success_rating,'success'));
    
    %check trial count is correct
    R_trials = failure_count + succes_count;
    if R_trials ~= 60
        error('There should be 60 reappraisal trials in the study data for %s',participant);
    end
    %     %check time for scales
    %     success_time = mean(study_data.success_resp_rt(~study_nr))
    %     arousal_time = mean(study_data.study_arousal_rt)
    %     %check arousal ratings
    %     view_neutral = (ismember(study_data.instruction,'view') & ismember(study_data.valence,'neutral'))
    %     view_negative = (ismember(study_data.instruction,'view') & ismember(study_data.valence,'negative'))
    %     decrease_negative = ismember(study_data.instruction,'decrease')
    %     success = (ismember(study_data.instruction,'decrease') & ismember(study_data.success_resp_keys,1))
    %     failure = (ismember(study_data.instruction,'decrease') & ismember(study_data.success_resp_keys,0))
    %     arousal_view_neutral = mean(study_data.study_arousal_rating(view_neutral))
    %     arousal_view_negative = mean(study_data.study_arousal_rating(view_negative))
    %     arousal_decrease_negative = mean(study_data.study_arousal_rating(decrease_negative))
    %     arousal_s_dec_neg = mean(study_data.study_arousal_rating(success))
    %     arousal_f_dec_neg = mean(study_data.study_arousal_rating(failure))
    % Check item acc (test_item_resp_acc)
    % item_resp of 1 or 0 means an old or new response, respectively.
    test_item_resp_acc = ismember(test_data.old_new,'old') & test_data.test_item_resp == 1  | ...
        ismember(test_data.old_new,'new') &  test_data.test_item_resp == 0;
    test_data.test_resp_acc = double( test_item_resp_acc );
    A = test_data.item_acc;
    B = test_data.test_resp_acc;
    check = all(A==B);
    if check ~= 1
        error('Item acc for data is not correct in python or matlab code %s',participant);
    end
    
    % task counterbalances
    first_phase = study_data.phase_name{1};
    list = first_phase(end); % The last character is the list. Note it is a number coded as a string
    if contains(first_phase, 'neg_decrease1_study')
        study_cb = 'B';
    elseif contains (first_phase, 'neg_view1_study')
        study_cb = 'A';
    else
        study_cb = 'C';
    end
    
    % Add info to participant log
    new_data = {participant id study_cb list succes_count failure_count};
    par_log{pari,:} = new_data;
    
    % remove duplicate variables
    study_vars_to_remove = {'arousal_resp_keys','arousal_resp_rt', 'success_resp_keys','success_resp_rt'};
    study_data = study_data( :, ~ismember(study_data.Properties.VariableNames, study_vars_to_remove) );
    
    % Save study and test data file in bids
    study_beh_file = fullfile( directories.par_data , sprintf('sub-%s_task-study_beh.tsv', id) );
    test_beh_file  = fullfile( directories.par_data , sprintf('sub-%s_task-test_beh.tsv', id) );
    writetable(study_data, study_beh_file, 'FileType','text','Delimiter','\t');
    writetable(test_data, test_beh_file, 'FileType','text','Delimiter','\t');
    %% Step 5: Combine study and test data structures
    % int variables from study to test
    test_data.study_arousal_resp       = nan(size(test_data,1),1);
    test_data.study_arousal_rt         = nan(size(test_data,1),1);
    test_data.study_success_resp       = repmat({'na'},size(test_data,1),1);
    test_data.study_success_rt         = nan(size(test_data,1),1);
    test_data.testfile                 = repmat({'na'},size(test_data,1),1);
    test_data.study_instruction        = repmat({'na'},size(test_data,1),1);
    test_data.study_reappraisal        = nan(size(test_data,1),1);
    test_data.list                     = repmat({'na'},size(test_data,1),1);
    test_data.test_trial               = nan(size(test_data,1),1);
    test_data.study_trial              = nan(size(test_data,1),1);
    test_data.block_trial              = nan(size(test_data,1),1);
    test_data.block_number             = nan(size(test_data,1),1);
    
    % Find test_data rows with study_trials and add new data
    for trli = 1:size(test_data,1)
        test_data.test_trial(trli) = trli;
        if ismember(test_data.old_new(trli),'new')
            test_data.list(trli)            = {list};
            test_data.cb(trli)              = {study_cb(1)};
            continue;
            
        else
            
            % Find the study index
            study_idx = find(ismember(study_data.original_scene, test_data.original_scene(trli)));
            
            % Copy into current trial of test_data
            test_data.study_arousal_resp(trli) = study_data.study_arousal_rating(study_idx);
            test_data.study_arousal_rt(trli) = study_data.study_arousal_rt(study_idx);
            test_data.study_reappraisal(trli) = study_data.study_R_trial(study_idx);
            test_data.study_success_resp(trli) = study_data.study_success_rating(study_idx);
            test_data.study_success_rt(trli) = study_data.study_success_rt(study_idx);
            test_data.testfile(trli) = study_data.test_file(1);
            test_data.study_instruction(trli) = study_data.instruction(study_idx);
            test_data.list(trli)            = {list};
            test_data.cb(trli)              = {study_cb(1)};
            test_data.study_trial(trli)              = study_data.study_trial(study_idx);
            test_data.block_trial(trli)              = study_data.block_trial(study_idx);
            test_data.block_number(trli)             = study_data.block_number(study_idx);
        end
        
    end
    %% Make derivative directory
    make_dirs({directories.par_analysis});
    
    % Create file names and write data table to file
    combo_beh_file = fullfile( directories.par_analysis, sprintf('sub-%s_task-studytest_beh.tsv', id) );
    writetable(test_data, combo_beh_file, 'FileType','text','Delimiter','\t');
end
% %% Load in demographics data
% % add in participant log information.
% demo_data_file = fullfile( directories.source, sprintf('ndg1e1_demographics.csv') );
% demo_opts = detectImportOptions( demo_data_file, 'FileType', 'text' );
% demo_data = readtable( demo_data_file, demo_opts );
% % select variables to add to participant log
% demo_variables_to_keep = {'OG_id' 'Age' 'Gender' 'Ethnicity'};
% demo_subset_data = demo_data(:,demo_variables_to_keep);
% %Join participant log and demo_data
% par_demo_log = join(par_log,demo_subset_data);
% final_variables_to_keep ={'id' 'cb' 'list' 'success' 'failure' 'Age' 'Gender' 'Ethnicity'};
% final_par_demo_log = par_demo_log(:,final_variables_to_keep);
% %% Save the participant log to BIDS
% par_tsv_file = fullfile(directories.raw,'participants.tsv');
% writetable(final_par_demo_log,par_tsv_file,'FileType','text','Delimiter','\t');