% does not work at least in matlab R2014b
function h = scatter3Alpha(varargin)
% two consecutive arguments should be 'alpha' and alpha value
var_str = Var2Str(varargin);
alpha_idx = find(ismember(var_str,{'alpha'}));
if isempty(alpha_idx)
disp 'Error: one parameter has to be ''alpha'''
pause;
end
alphaValue = varargin{alpha_idx+1};
varargin(alpha_idx+[0,1]) = [];
if ~ismember({'filled'},var_str)
varargin{end+1} = 'filled';
end
h = scatter3(varargin{:});
% h.MarkerFaceAlpha = alphaValue;
end
function s = Var2Str(var)
s = cellfun(@num2str,var,'UniformOutput',false);
end