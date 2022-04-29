% nd2 Exp 1
% create study and test json files
root_dir = 'X:\EXPT\nd002\exp1\data';

project_label = 'raw';
task_id = '';

task_json_name = fullfile(root_dir,project_label,...
    'task-study_description.json');
% Define JSON options
json_options.indent = '    ';    


% Make task-study_beh.json (UPDATE DIRECTORY)
study_json_file = fullfile(pwd,'task-study_beh.json');
study_json                              = struct();
study_json.task.Description             = 'In This task participants made one of two judgments (manmade, shoebx) about words under two conditions: informed, uninformed. Colored circl cues or the color of the word indicated which judgment to make (red:shoebox, blue:manmade)';
study_json.id.Description               = 'Participant id code';
study_json.stim_set.Description         = 'Stimulus set used for the experiment.';
study_json.psychopyVersion.Description  = 'Version of psychopy';
study_json.word.Description             = 'Word stimuli presented';
study_json.manmade.Description          = 'Manmade judgment correct response: Y or N';
study_json.shoebox.Description          = 'Shoebox judgment correct response: Y or N';
study_json.nletters.Description         = 'Word length with levels 4-8';
study_json.freq.Description             = 'Word frequency (Ku?era & Francis, 1967) with levels 1-40';
study_json.nsyllables.Description       = 'Word syllables';
study_json.concreteness.Description     = 'Word concreteness ratings with levels 500-662';
study_json.old_new.Description          = 'Word is old or new for subsequent recognition task';
study_json.study_judgment.Description   = 'Judgment trial type: shoebox or manmade';
study_json.cue_condition.Description    = 'Informative or Uninformative trial';
study_json.study_resp_key.Description   = 'Participants judgment response: j, k, d , f , and na for no responses';
study_json.study_resp.Description       = 'Participants numeric judgment response: 1 (yes:j,f) or 2 (no:k,d), and -99 for no responses';
study_json.study_rt.Description         = 'Participants judgment reaction time, and -99 for no responses';
study_json.correct_hand.Decsription     = 'Did participant use correct hand for semantic judgment: 1 (yes), 0 (no)';
study_json.study_nr.Description         = 'Participant made no response for study judgment';
study_json.good_trial.Description       = 'Mark if trial is a good study trial (i.e., participant responded to judgment in time and with correct hand';
study_json.test_resp.Description        = 'Participant test confidence scale response (1[sure new] - 6 [6 sure old])';
study_json.test_rt.Description          = 'Participants test confidence scale response reaction time';
jsonwrite(study_json_file,study_json,json_options);


% Make task-test_beh.json (UPDATE DIRECTORY)
project_label = 'raw';
task_id = '';

task_json_name = fullfile(root_dir,project_label,...
    'task-test_description.json');
% Define JSON options
json_options.indent = '    ';    
%  task-test information
test_json_file = fullfile(pwd,'task-test_beh.json');
test_json.task_test.Description = 'Participants completed an incidental recognition test. Participants made confidence ratingss: 1(sure new), 2 (maybe new), 3 (guess new) 4(guess old), 5(maybe old), 6 (sure old)';
test_json.id.Description = 'Participant ID';
test_json.set.Description = 'Stimulus file set that was randomly generated (1-64)';
test_json.psychopyVersion.Description = 'Version of psychopy';
test_json.word.Description   ='Word stimuli presented';
test_json.manmade.Description = 'Manmade judgment correct response: Y or N';
test_json.shoebox.Description = 'Shoebox judgment correct response: Y or N';
test_json.nletters.Description =  'Word length with levels 4-8';
test_json.freq.Description = 'Word frequency (Ku?era & Francis, 1967) with levels 1-40';
test_json.nsyllables.Description = 'Number of word syllables';
test_json.concreteness.Description = 'Word concreteness ratings with levels 500-662';
test_json.old_new.Description = 'Word is old or new for subsequent recognition task';
test_json.study_judgment.Description = 'Study judgment trial type: manmade, shoebox or new';
test_json.cue_condition.Description = 'Study cue condition: Informed, Uninformed, or new ';
test_json.test_resp.Description = 'Participants memory response on confidence scale (6[sure old]-1[sure new])';
test_json.test_rt.Description = 'Participants memory reaction times for test response';
test_json.study_resp.Description = 'Participants study judgment response (Y:1/N:2) and -99 for no responses';
test_json.study_rt.Description = 'Participants study judgment response reaction time with -99 for no reponses';
test_json.correct_hand.Description = 'Numerically mark if participants used correct hand during study judgment: 1 (yes) , 0 (no)';
test_json.study_nr.Description = 'Participant no response for study judgment';
test_json.good_trial.Description = 'Numerically mark if trial is good (1) or bad (0) based on if participants test performance (item memory and using entire range of confidence scale), see prereg for more information ';
json_options.indent               = '    '; % this makes the json look prettier when opened in a txt editor
jsonwrite(test_json_file,test_json,json_options);
