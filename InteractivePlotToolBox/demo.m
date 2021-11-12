% testing function InteractivePlot
plot_fc = @example_plot_fc;
para = {{1,'Name','X-Value','Range',[0 100]};
    {2,'Name','Y-Value','Range',[0 100]};
    {'b*','Name','PlotSpec'}
    };
para_to_manipu = [true,true,true];
InteractivePlot(plot_fc,para,para_to_manipu)

%% function could be defined at the end of a script for newer version of matlab
function f = example_plot_fc(para)
persistent k;
if isempty(k)
    k = figure;
else
    figure(k)
end
plot([0,para{1}{1}],[0,para{2}{1}],para{3}{1});
f = k;
end