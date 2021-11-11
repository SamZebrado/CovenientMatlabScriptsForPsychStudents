%% read xls/xlsx files
% input all in determined folder using function [num,txt,raw] = xlsread('test.xlsx');
% ***Caution***
% all xls files must be preproced to satisfy formats below:
% 1.1st Line for Key_Names, and Key_Names for same identifier, keys that
% are used to distinguish id of records, are already replaced by same 
% Key_Name, so that one element of Key_List refer to one identifier.
% 2.Data start from 2nd Line
mother_folder = 'F:\SamZebrado\Ex1_Meditation\Data\PreProc';
folder_list = cellstr(ls(fullfile(mother_folder,'*.')));
folder_list = folder_list(3:end);% get rid of . and ..
r = [];% data
Key_List = {'name','e-mail','ÊÖ»ú'}% candidate keys for records identification
file_list = {};
for itr_fldr = 1:length(folder_list)
    file_list = [file_list;fullfile(folder_list{itr_fldr},cellstr(ls(fullfile(folder_list{itr_fldr},'*.xls*'))))];
end
for ii = 1:length(file_list)
 r = xls_merge(r,file_list(ii),Key_List);% merge all records into r, add if new, skip if same
end