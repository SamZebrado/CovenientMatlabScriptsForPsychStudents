function mp = InteractivePlot(plot_fc,para,para_to_manipu)
% this function do a plot which can be replotted with new parameters by
% changing them using buttons or slides
% plot_fc: function using to plot
% para: cell including parameters to pass to function, e.g. {{para1,other_info_about_para1}, {para2,other_info_about_para2},...}
% the graph generated is equivalent to execute "plot_fc(para1,para2,...)"
% the other_info_about_paraN could include following info:
% 'Name', name of the parameter
% 'Range', range of the parameter
% 'Pool', all possible values of the parameter
% para_to_manipu: boolean vector to determine which parameter could be
% manipulated through the manipulation panel
%% parameter check
if ~islogical(para_to_manipu)
disp 'Warning: para_to_manipu must be of boolean type';
pause;
end
%% do first plotting
% exc_para = cellfun(@(c)c{1},para,'UniformOutput',false);
plot_fc(para);
% manipulation panel
mp = GenerateManiPanel(plot_fc,para);%！！！！！！！！！！！ failing to get updated ...
end