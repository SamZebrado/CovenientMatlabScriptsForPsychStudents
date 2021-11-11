% testing function InteractivePlot
plot_fc = @plot;
para = {{1,'Name','X-Value','Range',[0 100]};
    {2,'Name','Y-Value','Range',[0 100]};
    {'b*'}
    };
para_to_manipu = [true,true,true];
InteractivePlot(plot_fc,para,para_to_manipu)
