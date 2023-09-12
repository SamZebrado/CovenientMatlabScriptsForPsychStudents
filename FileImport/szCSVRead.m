function content = szCSVRead(filename)
% function content = szCSVRead(filename)
% read csv file and give output as cells of string (just as what you can
% get using [~,~,raw] = xlsread(filename).
% 
% Significance:
% the csvread function in matlab only supports csv files containing pure
% numbers, and will replace empty values as zeros
% 
% e.g try parsing these data using csvread and you will see:
% 
% file1.csv:
% 1,2,3,4,,5
% 
% file2.csv:
% a,b,1,2,
% 
% Tested matlab version:
% R2020b
% 
% Dependency:
% fcCellLine2Cell (in the same folder)
% fcReadFileByLine (in the same folder)
% 
% Created and commented by
% samzebrado@foxmail.com 
% 7.9.2021

input_lines = fcReadFileByLine(filename);
input_lines = cellfun(@(c)strrep(c,',,',',szNaN,'),input_lines,'UniformOutput',false);% keep empty elements
input_lines = cellfun(@(c)strsplit(c,','),input_lines,'UniformOutput',false);% split using comma
input_lines = cellfun(@(c)strrep(c,'szNaN',''),input_lines,'UniformOutput',false);% keep empty elements
content = fcCellLine2Cell(input_lines);
end