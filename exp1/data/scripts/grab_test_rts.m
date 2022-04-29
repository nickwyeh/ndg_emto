%% Rts
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
test_rt_data = {'participant' 'study_cb' 'median_rt' };
% Read all in source data
participant_list = dir(fullfile(directories.raw,'sub-*'));
participant_list = {participant_list.name};

for pari = 1:length(participant_list)
    % Convert participant to char type
    participant = participant_list{pari};
    
    % Print info to screen
    fprintf('\n\nProcessing data for %s:\n\n',participant);
    
    % Load behavioral data
    directories.rawsub        = fullfile(directories.raw, sprintf('%s'),participant);
    data_file  = fullfile(directories.rawsub,sprintf('%s_task-test_beh.tsv',participant));
    opts       = detectImportOptions(data_file, 'FileType', 'text');
    test_data  = readtable(data_file, opts);
    study_cb   = test_data.cb{1};
    
    % store test reaction times
    test_rts = test_data.test_type_rt;
    test_rt_data = vertcat(test_rt_data,...
        {participant  study_cb  median(test_rts)});
end
%test rt data 
test_rt_data_wide = cell2table(test_rt_data(2:end,:),'VariableNames',test_rt_data(1,:));
writetable(test_rt_data_wide,fullfile(directories.analyses,'test_rt_data.csv'));