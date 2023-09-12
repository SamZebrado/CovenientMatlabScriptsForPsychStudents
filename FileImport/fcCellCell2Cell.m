function CellOut = fcCellCell2Cell(CellCell)
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
% Update:
%   Each cell in CellLine can contain multiple lines; the parallel
%   processing option for nRow>1000 was removed
%   Maybe it should be renamed as fcCellCell2Cell(CellCell), lol
% 9.12.2023

nCol = cellfun(@(c)size(c,2),CellCell,'UniformOutput',true);% if number of columns differ across rows, use empty cell to pad up the columns

maxNcol = max(nCol);
CellCell = cellfun(@(c)[c,repmat({''},size(c,1),maxNcol-size(c,2))],CellCell,'UniformOutput',false);

nCell = length(CellCell);
n_row = cellfun(@(c)size(c,1),CellCell);
nRow = sum(n_row);
row_ind_st = [1;cumsum(n_row(:))+1];
row_ind_ed = row_ind_st(2:end)-1;
CellOut = cell(nRow,maxNcol);
for i_cell = 1:nCell
        st = row_ind_st(i_cell);
        ed = row_ind_ed(i_cell);
        content = CellCell{i_cell};
        CellOut(st:ed,:) = content;
end
end