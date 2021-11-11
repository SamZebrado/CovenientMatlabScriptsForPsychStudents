function CellOut = fcCellLine2Cell(CellLine)
% This function parses {{line1};{line2}} as {line1;line2} 
% (each of line1, line2, ... is a 1*n cell) 
% 
% If number of column differs across lines, extra space will be padded up
% by empty cells
% 
% Tested matlab version:
% R2020b
% 
% Created and commented by
% samzebrado@foxmail.com 
% 7.9.2021

nCol = cellfun(@length,CellLine,'UniformOutput',true);% if number of columns differ across rows, use empty cell to pad up the columns

maxNcol = max(nCol);
CellLine = cellfun(@(c)[c,repmat({''},1,maxNcol-length(c))],CellLine,'UniformOutput',false);

nRow = length(CellLine);
CellOut = cell(nRow,maxNcol);
if nRow>1000
    parfor i_row = 1:nRow
        CellOut(i_row,:) = CellLine{i_row};
    end
else
    for i_row = 1:nRow
        CellOut(i_row,:) = CellLine{i_row};
    end
    
end
end