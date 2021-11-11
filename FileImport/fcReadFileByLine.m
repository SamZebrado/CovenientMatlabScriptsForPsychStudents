function input_lines = fcReadFileByLine(filename)
% read file line-by-line and return the data in cell of string lines
% 
% Significance:
% avoid bothering fopen etc. when willing to read file contents (by using
% them in this function)
% 
% Created and commented by
% samzebrado@foxmail.com 
% 7.9.2021
% 
    input_lines = {};
    fid = fopen(filename);
    tline = fgetl(fid);
    input_lines{end+1,1} = tline;
    while ischar(tline)
%         disp(tline)
        tline = fgetl(fid);
        input_lines{end+1,1} = tline;
    end
    fclose(fid);
    input_lines(end) = [];% get rid of -1
end