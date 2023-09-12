%% Data import/preparation
data = magic(5);
%% Plotting options
options.rowNames = {'A','B','C','D','E'};% row labels
options.colNames = {'aha','oho','hhh','cool','happy'};% column labels

% if you want automatically assigned colors, comment these lines out
rowColorCells = [...];% colors for each row, value from 0 to 1, columns are [r g b]
    1 0 0;
    0 1 0;
    0 0 1;
    1 1 0;
    0 1 1;
    ];
options.rowColorCells = num2cell(rowColorCells,2);
% if you want automatically assigned radius range, comment these lines out
options.minRadius = 1;
options.radiusAmplitude = 100;
%% call the function
matrixBubblePlot(data,options)
    
