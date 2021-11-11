function OutputData = szPickData(cellData,varList,varNames,subList,subNames)
% function Output = szPickData(cellData,varList,varNames,subList,subNames)
% 
% pick data for specified variable and specified subjects, given the
% sequence of variables and subject names.
% 
% cellData: similar to standard SPSS data format,
%           each row represents a subject
%           each column represents a variable
% 
% varList: variable names for each column of cellData
% 
% varNames: variables to pick, if empty, all variables will be picked,
% sequence of it will affect the output data
% 
% subList: subject names/code names for each row of cellData
% 
% subNames: subjects to pick, if empty, all subjects will be picked
% sequence of it will affect the output data
% 
% Created and commented by
% samzebrado@foxmail.com 
% 7.9.2021

OutputData = cellData(pickMember(subList,subNames),pickMember(varList,varNames));

end
function OutputInd = pickMember(List,Names)
if isempty(Names)
    OutputInd = 1:length(List);
else
[~,OutputInd] = ismember(Names,List);
end
end