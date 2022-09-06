function updated_loc = get_next_loc(staircase,loc_history,resp_history)
% staircase: staircase settings
% resp_history: -1 down, +1 up, nan indicates not collected yet
% loc_history: all location history, nan indicates not collected yet

%% load parameters
updown = staircase.UpDown;
initVal = staircase.initVal;
stepSizeList = staircase.StepSizes;
% position of the last trial
i_last_trial = find(isnan([resp_history;nan])... this way it will work even at the last trial
    ,1)-1;

if i_last_trial==0 % the first trial
    updated_loc = initVal;
else
    lower_lim = staircase.LowerHigherBoundaries(1);
    higher_lim = staircase.LowerHigherBoundaries(2);
    %% mirror if start from minus values
    if initVal<0
        updown = updown([2,1]);
        loc_history = -loc_history;
        resp_history = -resp_history;
    elseif initVal==0
        %should not reach this sentence
        fprintf('Initial value of test-standard difference should never be zero!\n')
        pause;
    end
    %% now the stimulus must start from a positive value --> going down expected
    num_for_up = updown(1);
    num_for_down = updown(2);

    if i_last_trial>=num_for_up && sum(resp_history(i_last_trial-num_for_up+1:i_last_trial))==-num_for_up% enough number of -1s
        step_sign = 1;
    elseif i_last_trial>=num_for_down && sum(resp_history(i_last_trial-num_for_down+1:i_last_trial))==num_for_down
        step_sign = -1;
    else
        step_sign = 0; % not changing
    end
    %% step size: based on the number of reversals
    % 1. is the current trial reversing or not?
    direction_history = sign(diff(loc_history(1:i_last_trial)));
    direction_history = [0;...% the 2nd trial will never be considered a reversal in the following step
        direction_history(:)];
    direction_history(end+1) = step_sign;% direction of the current trial (amplitude not computed yet) should also be within consideration while counting reversals
    num_reversals = sum(direction_history(2:end).*direction_history(1:end-1)==-1); % -1 indicate a change of direction
    stepSize = stepSizeList(min(num_reversals+1,length(stepSizeList))); % support any number of step sizes
    
     fprintf('DEBUG:\nNumber of reversals: %i\n step size: %f\n ',num_reversals, stepSize)
    %% mirror back the sign
    if initVal<0
        step_sign = -step_sign;
        loc_history = -loc_history;
%         resp_history = -resp_history; % not used
    end
    updated_loc = loc_history(i_last_trial) + step_sign*stepSize;
     fprintf('DEBUG:\nlocation last trial: %i\n step sign*size: %f\n ',loc_history(i_last_trial), step_sign*stepSize)
    if updated_loc>higher_lim
        updated_loc = higher_lim;
    elseif updated_loc<lower_lim
        updated_loc = lower_lim;
    end
end
%     fprintf('DEBUG: updated location: %f\n', updated_loc)
end