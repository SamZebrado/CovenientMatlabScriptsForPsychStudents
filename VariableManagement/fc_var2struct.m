function s = fc_var2struct(varargin)
% Save each input as a field in the output struct, and the field name will
% be the input's variable name
% Sam Z. Shan Sep 16, 2022
% Hints from
% https://www.mathworks.com/matlabcentral/answers/382503-how-can-i-get-the-name-of-a-matlab-variable-as-a-string
%
for i_argin = 1:nargin
    s.(inputname(i_argin)) = varargin{i_argin};
end
end