
nTrials = 5;
i_trial_list = 1:nTrials;



fc_rerun_criteria = @(response)isempty(response);

additional_constant_variables = {'hahaha','heeheehee'};
additional_trialwise_variables = {@(ii)randi(ii)};
fc_run_a_trial = @(ii)fc_run_a_trial_demo([{ii},additional_constant_variables,cellfun(@(c)c(ii),additional_trialwise_variables,'UniformOutput',false)]);

[TrialOutputs,rerun_trial_container] = ...
    fc_run_triallist_with_rerun(...
    fc_run_a_trial,...
    i_trial_list,...
    fc_rerun_criteria ...
    );

function vOut = fc_run_a_trial_demo(vIn)
[trialNo,msg1,msg2,a_cell_of_a_random_number] = deal(vIn{:});
resp_instruction = sprintf('Enter something as your response for trial No. %i\n',trialNo);
vOut.response = input(resp_instruction,'s');
fprintf('Your response is "%s"\n\n',vOut.response);
fprintf('And we have access to the following variables:\n')
disp(msg1)
disp(msg2)
disp(a_cell_of_a_random_number)
fprintf('\n\n\n')
end