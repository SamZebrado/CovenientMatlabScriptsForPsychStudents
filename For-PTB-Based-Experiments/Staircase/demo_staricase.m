%% Staircases settings
nStaircases = 4;
% staircases: four staircases. For any property, each column stands for one
% staircase.
Staircases.UpDown = [...
    1,2,1,2;
    2,1,2,1];% two-down-one-up and one-down-two-up
Staircases.initVal = [-3,-3,3,3];% start from left(-); start from right(+)
% StepSizes = [35;17.5;8.75;];% <double-check> this was arbitrarily set...

StepSizes = [3;2;1]; % initial step size, step sizes after one, two reversal of the direction
% only seven positions are possible... let's make the standard always at
% the center using the variable "tactileLocations"

Staircases.StepSizes = StepSizes*[1,1,1,1]; 
LowerHigherBoundaries = [-3;3];% upper and lower limits of the values
Staircases.LowerHigherBoundaries = LowerHigherBoundaries*[1,1,1,1];

%% Pick one staircase
separated_staircase = arrayfun(@(col_no)get_col_for_each_field(expSettings.Staircases,col_no),1:nStaircases,'UniformOutput',false);

cur_stair = 1;
disp(getStaircaseInfoStr(separated_staircase{cur_stair}));
%% experiment settings
n_trial = 100;
%% Simulate and plot
% init
click_history = nan(n_trial,1);
loc_history = click_history;

figure(99)
for i_trial = 1:n_trial
    touch_loc = get_next_loc(separated_staircase{cur_stair},loc_history,click_history);
    loc_history(i_trial) = touch_loc;
    plot(loc_history);
    ylabel 'Location'
    xlabel 'nTrial'
    drawnow();
    figure(gcf);
    [~,~,~,whichButton] = GetClicks();
    click_history(i_trial) = 1-2*(whichButton==1);% -1 left, +1 right; should be only one click for the current experiment
end