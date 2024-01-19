function fcCombineFiguresGUI()
% fcCombineFiguresGUI creates a graphical user interface for combining multiple MATLAB figures into a single figure.
%
% This GUI allows users to select figures from a specified directory and combine them into a single figure
% with a customizable grid layout. The GUI supports adjusting the number of rows and columns for the layout,
% as well as scaling the font size of text within the figures to maintain readability in the combined figure.
%
% Usage:
%   - Run fcCombineFiguresGUI to open the GUI.
%   - Use the 'Folder Path' field to specify the directory containing the MATLAB figure files (*.fig).
%   - Click 'Browse' to open a folder selection dialog.
%   - Click 'Scan' to list all figure files in the specified folder.
%   - Enter the desired number of rows and columns for the combined figure layout.
%   - Specify a font size scaling factor to adjust text size in the combined figure.
%   - For each listed figure file, enter the row and column where it should appear in the combined figure.
%     Only figures with specified row and column numbers greater than zero will be included.
%   - Click 'Combine' to create the combined figure.
%
% Features:
%   - Dynamic listing of figure files from a chosen directory.
%   - Customizable grid layout for the combined figure.
%   - Font size scaling to ensure readability of text in the combined figure.
%   - Fullscreen display of the combined figure.
%
% Limitations:
%   - The combined figure is a static representation and does not retain interactivity of the original figures.
%   - Only '.fig' files are supported for combining.
%
% Authors: Sam Zebrado and ChatGPT plus
% Date: January 19, 2024

% GUI for combining figures
hFig = figure('Name', 'Combine Figures', 'NumberTitle', 'off', 'MenuBar', 'none', 'Position', [100, 100, 600, 800]);
movegui(hFig, 'center');

% Text box for folder path
uicontrol('Style', 'text', 'Position', [10, 45, 100, 20], 'String', 'Folder Path:', 'Parent', hFig);
folderBox = uicontrol('Style', 'edit', 'Position', [120, 45, 350, 20], 'String', pwd, 'Parent', hFig,'Tag','FolderBox');

% Browse button
uicontrol('Style', 'pushbutton', 'String', 'Browse', 'Position', [480, 45, 100, 20], 'Callback', {@browseFolder, folderBox}, 'Parent', hFig);

% Scan button
uicontrol('Style', 'pushbutton', 'String', 'Scan', 'Position', [10, 15, 80, 20], 'Callback', {@scanFolder, folderBox, hFig}, 'Parent', hFig);

% Text boxes for rows and columns
uicontrol('Style', 'text', 'Position', [100, 15, 50, 20], 'String', 'Rows:', 'Parent', hFig);
rowBox = uicontrol('Style', 'edit', 'Position', [150, 15, 50, 20], 'String', '2', 'Parent', hFig);
uicontrol('Style', 'text', 'Position', [210, 15, 70, 20], 'String', 'Columns:', 'Parent', hFig);
colBox = uicontrol('Style', 'edit', 'Position', [280, 15, 50, 20], 'String', '2', 'Parent', hFig);

% Font size adjustment
uicontrol('Style', 'text', 'Position', [340, 15, 120, 20], 'String', 'Font Size Scalar:', 'Parent', hFig);
fontSizeBox = uicontrol('Style', 'edit', 'Position', [460, 15, 50, 20], 'String', '0.8', 'Parent', hFig);

% Combine button
uicontrol('Style', 'pushbutton', 'String', 'Combine', 'Position', [520, 15, 70, 20], 'Callback', {@combineSelectedFigures, hFig, rowBox, colBox, fontSizeBox}, 'Parent', hFig);

% Initialize file list
scanFolder([], [], folderBox, hFig);
end


function browseFolder(src, evt, folderBox)
folderPath = uigetdir(get(folderBox, 'String'));
if folderPath ~= 0
    set(folderBox, 'String', folderPath);
end
end

function scanFolder(src, evt, folderBox, hFig)
% Clear existing checkboxes/textboxes
delete(findall(hFig, 'Type', 'uicontrol', 'Tag', 'FileName'));
delete(findall(hFig, 'Type', 'uicontrol', 'Tag', 'Row'));
delete(findall(hFig, 'Type', 'uicontrol', 'Tag', 'Column'));

folderPath = get(folderBox, 'String');
files = dir(fullfile(folderPath, '*.fig'));
fileNames = {files.name};

% Calculate positions for file list
startPos = 700;  % Starting Y position
step = 25;       % Step size for each file
for i = 1:length(fileNames)
    % Adjust panel size if needed
    if startPos - (i-1) * step < 10
        set(hFig, 'Position', [100, 100, 600, 800 + (i-1) * step]);
    end

    % Create textboxes for file names and positions
    uicontrol('Style', 'edit', 'Tag', ['FileName' num2str(i)], 'String', fileNames{i}, 'Position', [10, startPos - (i-1) * step, 280, 20], 'Enable', 'off', 'Parent', hFig);
    uicontrol('Style', 'edit', 'Tag', ['Row' num2str(i)], 'Position', [300, startPos - (i-1) * step, 40, 20], 'String', '0', 'Parent', hFig);
    uicontrol('Style', 'edit', 'Tag', ['Column' num2str(i)], 'Position', [350, startPos - (i-1) * step, 40, 20], 'String', '0', 'Parent', hFig);
end
end

function combineSelectedFigures(src, evt, hFig, rowBox, colBox, fontSizeBox)
screenSize = get(0, 'ScreenSize');
% Combine selected figures based on specified layout
numRows = str2double(get(rowBox, 'String'));
numCols = str2double(get(colBox, 'String'));
fontSizeScalar = str2double(get(fontSizeBox, 'String'));

% Gather file names and positions
figNames = {};
figPositions = [];
alluicontrol = findall(hFig, 'Type', 'uicontrol');

for i = 1:sum(contains({alluicontrol.Tag},'FileName'))
    fileNameBox = findall(hFig, 'Type', 'uicontrol', 'Tag', ['FileName' num2str(i)]);
    rowBox = findall(hFig, 'Type', 'uicontrol', 'Tag', ['Row' num2str(i)]);
    colBox = findall(hFig, 'Type', 'uicontrol', 'Tag', ['Column' num2str(i)]);
    if str2double(rowBox.String)>0&&str2double(colBox.String)>0
        figNames{end+1} = get(fileNameBox, 'String');
        figPositions(end+1, :) = [str2double(get(rowBox, 'String')), str2double(get(colBox, 'String'))];
    end
end

% Create a new figure for the combined plots
combinedFig = figure('Position', [0, 0, screenSize(3), screenSize(4)]);
movegui(combinedFig, 'center');
spacing = 0.02;
% Process each selected figure
for i = 1:length(figNames)
    if figPositions(i, 1) > 0 && figPositions(i, 2) > 0
        % Load the figure
        figFile = fullfile(get(findall(hFig, 'Type', 'uicontrol', 'Tag', 'FolderBox'), 'String'), figNames{i});
        loadedFig = openfig(figFile, 'invisible');
        axesList = findall(loadedFig, 'Type', 'axes');

        % Copy each axes to the new figure
        for ax = axesList'
                 % Get current position
                origPos = get(ax, 'Position');

                % Calculate new position within the allocated grid
                row = figPositions(i, 1);
                col = figPositions(i, 2);
                newX = (col - 1) / numCols + origPos(1) / numCols;
                newY = (numRows - row) / numRows + origPos(2) / numRows;
                newPos = [newX, newY, origPos(3) / numCols, origPos(4) / numRows];
                % Copy the axes to the new figure and adjust position
                newAx = copyobj(ax, combinedFig);
                set(newAx, 'Position', newPos);

                % Adjust font size
                allText = findall(newAx, '-property', 'FontSize');
                for txt = allText'
                    set(txt, 'FontSize', get(txt, 'FontSize') * fontSizeScalar);
                end
        end
        close(loadedFig);
    end
end
end
