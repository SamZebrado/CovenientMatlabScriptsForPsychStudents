function [TrialOutputs,rerun_trial_container] = ...
    fc_run_triallist_with_rerun(...
    fc_run_a_trial,...
    i_trial_list,...
    fc_rerun_criteria ...
    )
%%
% Run a list of trials and rerun a trial if it satisfies a criteria for being reran.
% If a trial is to be reran, it will be randomly inserted among other
% trials later.
% If it's already the last trial, it will be ran again immediately.
%
% Inputs:
%   fc_run_a_trial(ii): function running trial ii;
%           all necessary variables
%           are expected to be saved in this function handle (check
%           https://www.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
%           for how to do this);
%           the output should be a structure containing at least a field
%           "response" and any other outputs that need to be recorded
%
%   i_trial_list: the indices of trials to run (a vector of doubles or booleans).
%           each elements will passed to fc_run_a_trial(ind_current_trial)
%           as ind_current_trial
%
%   fc_rerun_criteria: a function taking the response as input and
%       determine whether the current trial should be reran
%
%   rerun_trial_container: a structure matrix marking whether the current
%       trial should be reran and whether there are any trial(s) to be
%       reran after the current trial
%
%   vInGlobal: variables that have the same value for all trials
%
%   vInTrialwise: a structure:
%       vInTrialwise.var_name_list: list of variables that can have
%          different values for different trials
%       vInTrialwise.(var_name{ii}).Val: value of the variables
%       vInTrialwise.(var_name{ii}).get_trial(Val,i_trial): how to get
%           value for trial number "i_trial" from the variable's value
%
%   TrialOutputs: a cell collection of the outputs from fc_run_a_trial(ii)
%
%       TrialOutputs{ii}.response: a container of the response for trial ii; it
%                     will be passed to fc_rerun_criteria(response) as response
%                     determine whether the current trial should be reran
%
% last edited by Sam Z. Shan Jun 23, 2022

len_trial_list = length(i_trial_list(:));

TrialOutputs = cell(len_trial_list,1);
rerun_trial_container = repmat(struct('qAppend',false,'trialsToAppend',{[]},'outputHistory',{{}}),len_trial_list,1);

for ii_trial = 1:len_trial_list
    % the current trial
    ind_cur_trial = i_trial_list(ii_trial);
    num_trial_ran = 0;% including the current trial
    % use while loop instead of nested function
    while num_trial_ran<=length(rerun_trial_container(ind_cur_trial).trialsToAppend)% also run when num_trial_ran==0: run at least the current trial itself

        if num_trial_ran% trials to be reran after the current trial
            ind_to_run = rerun_trial_container(ind_cur_trial).trialsToAppend(num_trial_ran);% be careful for the index
        else
            ind_to_run = ind_cur_trial;
        end
        %         for debugging
        %         fprintf('\nCurrent trial No: %i\n\n',ind_cur_trial)
        %         fprintf('trialsToAppend:\n[')
        %         fprintf('%i\t',rerun_trial_container(ind_cur_trial).trialsToAppend)
        %         fprintf(']\n[')
        %         fprintf('%i\t',1:length(rerun_trial_container(ind_cur_trial).trialsToAppend)==num_trial_ran)
        %         fprintf(']\nRunning trial = trialsToAppend(%i) = %i\n',num_trial_ran,ind_to_run)
        %% run the trial
        TrialOutputs{ind_to_run}= fc_run_a_trial(ind_to_run);
        %% judge and save the rerun list
        if fc_rerun_criteria(TrialOutputs{ind_to_run}.response)% if the current trial needs to be reran
            % save the response history: it might not be the first time that
            % the current trial was reran; and all outputs should be recorded
            rerun_trial_container(ind_to_run).outputHistory(end+1) = TrialOutputs(ind_to_run);% it's a cell

            % decide when to rerun:
            ind_trial_to_rerun_after = i_trial_list(...
                randi([min(ii_trial+1,len_trial_list),...% the last trial will be repeated immediately after itself
                len_trial_list]));

            rerun_trial_container(ind_trial_to_rerun_after).qAppend = true;
            rerun_trial_container(ind_trial_to_rerun_after).trialsToAppend = [rerun_trial_container(ind_trial_to_rerun_after).trialsToAppend,ind_to_run];% faster than a(end+1) = new_element
        end
        num_trial_ran = num_trial_ran + 1;
    end
end
TrialOutputs = cell2mat(TrialOutputs);
end