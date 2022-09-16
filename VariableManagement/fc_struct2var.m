function [varargout] = fc_struct2var(s,varargin)
% recover the value of each input variable from the structure provided,
% there must be a corresponding field for each variable, i.e., the field
% name should be the same as the variable name.
% The value of the 2nd to last inputs doesn't matter.
%
% The output sequence of the variables must be the same as the input
% sequence of the variables.
%
% This function could be used together with fc_var2struct to ease your
% variable managment, e.g. pass several variables into a function as a
% single structure, recover their value from the structure modified the
% function
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
varargout = cell(nargin-1,1);
for i_argin = 2:nargin
    varargout{i_argin-1} = s.(inputname(i_argin));
end
end