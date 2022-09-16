function [s,var_list] = fc_var2struct(varargin)
% Saves each input as a field in the output struct, and the field name will
% be the input's variable name
%
% Input:
%       an arbitrary number of variables with different names.
%
% Output:
%       s: a structure storing all inputs as different fields named after
%       the variable name of the inputs. 
%       var_list: list of the input variables' name  
%
% This function could be used together with fc_struct2var to ease your
% variable managment, e.g. pass several variables into a function as a
% single structure, and recover their value from the structure modified the
% function.
%
% Example:
%         a = 1
%         b = 2
%         c = rand(60,1)
%         s = fc_var2struct(a,b,c)
%         [d,e,f] = fc_struct2var(s,a,b,c)
%
% Sam Z. Shan Sep 16, 2022
% Hints from
% https://www.mathworks.com/matlabcentral/answers/382503-how-can-i-get-the-name-of-a-matlab-variable-as-a-string
%
for i_argin = 1:nargin
    s.(inputname(i_argin)) = varargin{i_argin};
end
var_list = fc_get_var_names(varargin);
end