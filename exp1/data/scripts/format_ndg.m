%% Clear workspace
% Description what does this script do.....
clear all;
clc;

%% Define main directories

directories.top    = 'C:\Users\nyeh\Desktop\fall_2021\NDG\exp1\data';
directories.raw        = fullfile(directories.top, 'raw');
directories.source     = fullfile(directories.top, 'sourcedata');
directories.analyses   = fullfile(directories.top, 'analyses');
directories.data_files = fullfile(directories.analyses, 'data_files');
directories.bad_data   = fullfile(directories.top, 'bad_data');
directories.og         = fullfile(directories.top, 'og');
directories.og_study   = fullfile(directories.og, 'study_data');
directories.og_test    = fullfile(directories.og, 'test_data');
directories.og_qual    = fullfile(directories.og, 'qualtrics_data');

% Make directories if needed
make_dirs({directories.og_qual directories.analyses directories.og directories.og_test directories.og_study directories.data_files});

% Make cells to store study and test participants
id_study  = {};
ts_study  = {'time_stamp' 'id'};
id_test   = {};
ts_test   = {'time_stamp' 'id'};

%% Update test data
% Read all in test data
participant_list = dir(fullfile(directories.og_test,'PARTICIPANT*'));
participant_list = {participant_list.name};

for pari = 1:length(participant_list)
    
    participant          = participant_list{pari};
    source_test_beh_file = fullfile( directories.og_test, participant );
    vars_to_remove       = {''};
    test_opts            = detectImportOptions( source_test_beh_file, 'FileType', 'text' );
    test_data            = readtable( source_test_beh_file, test_opts );
    test_data            = test_data( :, ~ismember(test_data.Properties.VariableNames, vars_to_remove) );
    
    id                   = test_data.id{1};
    id_test              = vertcat(id_test,id(12:end));
    ts_test              = vertcat(ts_test, ...
        horzcat({participant},{id}));
    
    % Make directory structure in data
    
    directories.par_source   = fullfile(directories.source, id);
    make_dirs({directories.par_source});
    
    test_beh_file            = fullfile( directories.og_test , sprintf('%s.csv',id) );
    % Save  test data file
    writetable(test_data,fullfile(directories.par_source ,sprintf('data_PARTICIPANT_test_procedure_%s.csv',id)) );
    %writetable(test_data,fullfile( directories.og_test , sprintf('data_PARTICIPANT_test_procedure_%s.csv',id) ));
   
end

%% Update study data
% Read all in study data
participant_list = dir(fullfile(directories.og_study,'PARTICIPANT*'));
participant_list = {participant_list.name};

for pari = 1:length(participant_list)
    % get study file
    participant           = participant_list{pari};
    source_study_beh_file = fullfile( directories.og_study, participant );
    
    vars_to_remove = {''};
    study_opts     = detectImportOptions( source_study_beh_file, 'FileType', 'text' );
    study_data     = readtable( source_study_beh_file, study_opts );
    study_data     = study_data( :, ~ismember(study_data.Properties.VariableNames, vars_to_remove) );
    
    % Grab id
    id             = study_data.id{1};
    
    if ismember(id(12:end),id_test)
        id_study = vertcat(id_study,id(12:end));
        ts_study = vertcat(ts_study, ...
            horzcat({participant},{id}));
        
        % Make directory structure in data
        directories.par_source   = fullfile(directories.source, id);
        make_dirs({directories.par_source});
        study_beh_file = fullfile( directories.og_study , sprintf('%s.csv',id) );
        % Save study
        writetable(study_data,fullfile(directories.par_source ,sprintf('data_PARTICIPANT_study_procedure_%s.csv',id)) );
        %writetable(study_data,fullfile( directories.og_study , sprintf('data_PARTICIPANT_study_procedure_%s.csv',id) ));
    else
    end
end

%% Check if data exist for session 1 and 2
% easier way, should just do it with ismember()
temp                                     = ts_study(2:end,:);
combo_check                              = cell2table(temp);
combo_check.Properties.VariableNames     = ts_study(1,:);
temp2                                    = ts_test(2:end,:);
test_check                               = cell2table(temp2);
test_check.Properties.VariableNames      = ts_test(1,:);

combo_check.session1                     = repmat({'true'},size(combo_check,1),1); % initialize study list vector
combo_check.session2                     = repmat({'false'},size(combo_check,1),1); % initialize study list vector
% Find test_data rows with study_trials and add new data
for trli = 1:size(combo_check,1)
    
    try
        % Find the study index
        study_idx = find(ismember(combo_check.id, test_check.id(trli)));
        combo_check.session2(study_idx)                     = {'true'};
        
    catch
        continue;
    end
    
end

%% Session 1 demographics
qual_file            = dir(fullfile(directories.og_qual,'ndg1*'));
qual_file            = {qual_file.name};
source_qual_beh_file = fullfile( directories.og_qual, qual_file );
vars_to_remove       = {''};
qual_opts            = detectImportOptions( source_qual_beh_file{1}, 'FileType', 'text' );
qual_data            = readtable( source_qual_beh_file{1}, qual_opts );
qual_data            = qual_data( :, ~ismember(qual_data.Properties.VariableNames, vars_to_remove) );

% Update variable name
qual_data.Properties.VariableNames{'Q15'} = 'end1_before_enc_sleep';
qual_data.Properties.VariableNames{'Q16'} = 'end1_awake_time';

%qual_data.Properties.VariableNames{'PROLIFIC_PID'} = 'OG_id';
qual_rows_keep = [];
Expt_code      = 'sub-ndg1e1s';
% grab only qualtrics data for people who went on to complete session 1
% update original id to work with next script

num_id =  cell2mat(cellfun(@str2num,id_study(1:end),'un',0).');
qual_data.id = num2cell(qual_data.id);
%     for i = 1:size(qual_data(:,1))
%         if ismember(qual_data.id(i),num_id) %ismember(qual_data.id(i),str2num(id_study))
%             qual_rows_keep            = vertcat(qual_rows_keep,i);
%             %qual_data.OG_id{i} = [Expt_code qual_data.id{i}];
%             qual_data.id{i}           = [Expt_code num2str(qual_data.id{i})];
%         else
%
%         end
%     end
%
for i = 1:size(qual_data(:,1))
    if ismember(qual_data.id{i},cellfun(@str2num,id_test)) % ismember(qual_data.OG_id(i),cellfun(@str2num,id_study))
        qual_rows_keep  = vertcat(qual_rows_keep,i);
        qual_data.id{i} = [Expt_code num2str(qual_data.id{i})];
    else
        
    end
end

for i = 1:size(qual_data(:,1))
    if length(qual_data.id{i}) == 16
        qual_data.location(i) = {'gsu'};
    else
        qual_data.location(i) = {'prolific'};
    end
end
qual_data = qual_data(qual_rows_keep,:);
% duplicates: sub-ndg1e1s52857, sub-ndg1e1s53311, sub-ndg1e1s53159, sub-ndg1e1s53220, sub-ndg1e1s53561
% Save updated demographics csv file
writetable(qual_data,fullfile(directories.og_qual ,sprintf('ndg1e1_demographics_gsu.csv')) );

%% End of session 1 questions
% Load data
quals1_file            = dir(fullfile(directories.og_qual,'session1*'));
quals1                 = {quals1_file.name};
source_quals1_beh_file = fullfile( directories.og_qual, quals1 );
vars_to_keep           = {'comments','id'};
quals1_opts            = detectImportOptions( source_quals1_beh_file{1}, 'FileType', 'text' );
qual1_data             = readtable( source_quals1_beh_file{1}, quals1_opts );
% Remove rows, cols 
qual1_data             = qual1_data( :, ismember(qual1_data.Properties.VariableNames, vars_to_keep) );
qual1_data             = qual1_data(ismember(qual1_data.id,cellfun(@str2num,id_test)),:);
% Convert data type
qual1_data.id = num2cell(qual1_data.id);

for i = 1:size(qual1_data(:,1))
    qual1_data.id{i}   = [Expt_code num2str(qual1_data.id{i})];
end
%% Session 2 questions
% Load data
quals2_file            = dir(fullfile(directories.og_qual,'session2*'));
quals2                 = {quals2_file.name};
source_quals2_beh_file = fullfile( directories.og_qual, quals2 );
vars_to_keep           = {'TimeSleepSession1' , 'Q15' , 'Q16' ,'id'};
quals2_opts            = detectImportOptions( source_quals2_beh_file{1}, 'FileType', 'text' );
qual2_data             = readtable( source_quals2_beh_file{1}, quals2_opts );

% remove columns and rows that are not needed
qual2_data             = qual2_data( :, ismember(qual2_data.Properties.VariableNames, vars_to_keep) );
qual2_data             = qual2_data(ismember(qual2_data.id,cellfun(@str2num,id_test)),:);

% update variable names
qual2_data.Properties.VariableNames{'TimeSleepSession1'} = 'start2_time2sleep';
qual2_data.Properties.VariableNames{'Q15'}               = 'start2_before_test_sleep';
qual2_data.Properties.VariableNames{'Q16'}               = 'start2_awake_time';
qual2_data.id          = num2cell(qual2_data.id);

for i = 1:size(qual2_data(:,1))
    qual2_data.id{i}   = [Expt_code num2str(qual2_data.id{i})];
end

%% Join demographics and survey data
qual_data_consent1  = join(qual_data,qual1_data,'Keys','id')
qual_data_consent12 = join(qual_data_consent1,qual2_data,'Keys','id')

% Save updated demographics csv file
writetable(qual_data_consent12,fullfile(directories.og_qual ,sprintf('ndg1e1_demographics.csv')) );