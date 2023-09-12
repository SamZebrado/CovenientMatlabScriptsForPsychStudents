function matrixBubblePlot(rs,varargin)
% function matrixBubblePlot(rs,options)
% for a given 2d matrix, plot it as matrix bubble plot, please check matrixBubblePlotDemo to see how to use it
% 
% sam zebrado created this function
[rowNumber,colNumber] = size(rs);
if isempty(varargin)
    options.rowNames = cellfun(@(x)strcat('row_',num2str(x)),num2cell((1:rowNumber)'),'UniformOutput',false);
    options.colNames = cellfun(@(y)strcat('col_',num2str(y)),num2cell((1:colNumber)'),'UniformOutput',false);

else
    options = varargin{1};
end

fc_check_para = @(options,fld_name)~isfield(options,fld_name)||isempty(options.(fld_name));
if fc_check_para(options,'rowColorCells')
    options.rowColorCells = arrayfun(@(~)rand(1,3),...only need the size
        ones(rowNumber,1),'UniformOutput',false);
end
if fc_check_para(options,'minRadius')
    options.minRadius = 1;
end
if fc_check_para(options,'radiusAmplitude')
    options.radiusAmplitude = 100;
end


color_cells = repmat(options.rowColorCells(:),1,colNumber);

fc_scale_color_cell = @(c_s,scale_factor)cellfun(@(c)c*scale_factor,c_s,'UniformOutput',false);
color_cells(2:2:end) = fc_scale_color_cell(color_cells(2:2:end),0.7);

[ys,xs] = ndgrid(1:rowNumber,1:colNumber);

normalized_rs = (rs - min(rs(:)))/(max(rs(:))-min(rs(:)))*options.radiusAmplitude+options.minRadius;% rescale the data as size

fc_draw_filled_circle = @(x,y,r,color_cell)plot(x,y,'.','Color',color_cell{1},'MarkerSize',r);
fc_text_all_data = @(x,y,n,offsets)text(x-offsets/50,y,num2str(n),'HorizontalAlignment', 'center');

figure;
hold on;
arrayfun(fc_draw_filled_circle,xs,ys,normalized_rs,color_cells);
arrayfun(fc_text_all_data,xs,ys,rs,normalized_rs*0);

set(gca,'XTick',1:colNumber,'XTickLabel',options.colNames,...
    'YTick',1:rowNumber,'YTickLabel',options.rowNames);
xlim([0,colNumber+1])
ylim([0,rowNumber+1])
end
