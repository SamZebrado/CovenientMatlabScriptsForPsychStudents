function fcExportCellstr2CSV(filename,c)
% function fcExportCellstr2CSV(filename,c)
% prints cellstring into specified file using fprintf(fid,'%s')
% 
% c: a cell mat, every element contains a string
% 
% Created and commented by
% samzebrado@foxmail.com 
% 7.9.2021
% 

    fid = fopen(filename,'w+');
    for ii = 1:size(c,1)
        fprintf(fid,'%s,',c{ii,:});
        fprintf(fid,'\n');
    end
    fclose(fid);
end