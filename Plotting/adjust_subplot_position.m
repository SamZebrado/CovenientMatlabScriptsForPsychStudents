function adjust_subplot_position(x_offset, y_offset)
    % adjust_subplot_position - Adjust the position of the current subplot
    %
    % Syntax: adjust_subplot_position(x_offset, y_offset)
    %
    % Inputs:
    %   x_offset - Horizontal offset for the subplot
    %   y_offset - Vertical offset for the subplot
    %
    % Written by ChatGPT 4o with instruction from Sam Zebrado by accident

    % Get the current axes

    ax = gca;
    
    % Get the position of the current subplot
    pos = get(ax, 'Position');
    
    % Adjust the position by the specified offsets
    pos(1) = pos(1) + x_offset; % Adjust x position
    pos(2) = pos(2) + y_offset; % Adjust y position
    
    % Set the new position
    set(ax, 'Position', pos);
end
