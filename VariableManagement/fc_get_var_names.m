function var_list = fc_get_var_names(varargin)
% Return a list of the variable names for the input variables
%
% Example:
%         a = 1
%         b = 2
%         c = rand(60,1)
%         varlist = fc_get_var_names(a,b,c)
%
% Sam Z. Shan Sep 16, 2022
% Hints from
% https://www.mathworks.com/matlabcentral/answers/382503-how-can-i-get-the-name-of-a-matlab-variable-as-a-string
%
var_list = cell(nargin,1);
for i_argin = 1:nargin
    var_list{i_argin} = inputname(i_argin);
end
end