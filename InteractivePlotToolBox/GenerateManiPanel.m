function mp_handle = GenerateManiPanel(plot_fc,para)
mp_handle.get_output = @get_output;

mp_handle.fcn_output = 'Use the GUI once, and run mp_handle.get_output to get the updated output';
control_width = 200;
control_height = 30;
dist_width_ratio_between_controls = 1.2; % distance between center of columns / width of a control
dist_height_ratio_between_controls = 1.5; % distance between center of columns / height of a control
new_pos = [control_width*(dist_width_ratio_between_controls-1)...
    control_height*(-1) ...% one offset will be added during the first call
    control_width control_height];
n_para = length(para);
n_control_per_col = 5;% number of controls per column
Children = cell(n_para,1);
mp_handle.figure_handle = figure('Position',[50,50,new_pos(3)*dist_width_ratio_between_controls*(ceil(n_para/n_control_per_col) ...
        +dist_width_ratio_between_controls-1) ... one additional interval between the last column and the right boundary
    ,min(new_pos(4)*dist_height_ratio_between_controls*(n_control_per_col+dist_height_ratio_between_controls-1)*2,...
    new_pos(4)*dist_height_ratio_between_controls*(n_para+dist_height_ratio_between_controls-1)*2)...less than 1 column
    ]);
for i_para = 1:n_para
    cur_para = para{i_para};
    % generate controls
    % Name of Parameter
    para_info = cellfun(@num2str,cur_para(2:end),'UniformOutput',false);
    if ismember('Name',para_info)
        gen_newpos;
        NameValue = cur_para{find(ismember(para_info,'Name'))+1+1};
        Child.Name = uicontrol('Style','text',...
            'Position',new_pos,...
            'String',NameValue);
    end
    if ischar(cur_para{1})||length(cur_para{1})>1
        gen_newpos;
        
        Child.InputBox = uicontrol('Style', 'edit',...
            'String',num2str(cur_para{1}),...
            'Position', new_pos,...
            'UserData',i_para,...
            'Callback', @box_update);
    else
        if ismember('Range',para_info)
            gen_newpos;
        RangeValue = cur_para{find(ismember(para_info,'Range'))+1+1};
            Child.Slider = uicontrol('Style', 'slider',...
                'Min',RangeValue(1),'Max',RangeValue(2),'Value',cur_para{1},...
                'Position', new_pos,...
                'UserData',i_para,...
                'Callback', @range_update);
        end
        if ismember('RangeInputBox',para_info)
            gen_newpos;
            % an alternative to use box to set the value ¡¾the two controls cannot sync now¡¿
            Child.InputBox = uicontrol('Style', 'edit',...
                'String',num2str(cur_para{1}),...
                'Position', new_pos,...
                'UserData',i_para,...
                'Callback', @box_update);
            
        end
        if ismember('Pool',para_info)% bug will appear: the window size could not be correctly computed for this control
            PoolValues = cur_para{find(ismember(para_info,'Pool'))+1+1};
            Child.Pool.ButtonGroup = uibuttongroup('Visible','off',...
                'Position',new_pos,...
                'UserData',i_para,...
                'SelectionChangedFcn',@pool_update);
            for i_b = 1:length(PoolValues)
                gen_newpos;
                Child.Pool.button(i_b) = uicontrol(bg,'Style', 'radiobutton',...
                    'Value',num2str(PoolValues{i_b}),...% if string, value will not change; if number, value will be changed into str
                    'Position', new_pos,...
                    'Callback', @surfzlim);
            end
        end
    end
    Children{i_para} = Child;
end
mp_handle.Children = Children;
% generating new postions
    function gen_newpos()
        new_pos(2) = new_pos(2) + round(new_pos(4)*dist_height_ratio_between_controls);
        if new_pos(2)>=new_pos(4)*dist_height_ratio_between_controls*n_control_per_col*2 % 2x hight: one tag one control
            new_pos(2) = new_pos(4)*(dist_height_ratio_between_controls-1);
            new_pos(1) = new_pos(1)+ round(new_pos(3)*dist_width_ratio_between_controls);
        end
    end
% use nested functions to manipulate varaible "para"
    function recompute()
        mp_handle.fcn_output = plot_fc(para);
        fprintf('\n');
        cellfun(@(p)fprintf('%s: %s\n',p{3},...name
            num2str(p{1})),...value
            para)
    end
    function box_update(source,callbackdata)
        idx = get(source,'UserData');
        value = get(source,'string');
        if ischar(para{idx}{1})% char
            para{idx}{1}=value;
        else% number
            para{idx}{1}=str2double(value);
        end
        recompute();
    end
    function range_update(source,callbackdata)
        idx = get(source,'UserData');
        value = get(source,'Value');
        para{idx}{1}=value;
        recompute();
    end
    function pool_update(source,callbackdata)
        idx = get(source,'UserData');
        disp(['Previous: ' callbackdata.OldValue.String]);
        disp(['Current: ' callbackdata.NewValue.String]);
        disp('------------------');
        if ischar(para{idx}{1})% char
            para{idx}{1}=callbackdata.NewValue.String;
        else% number
            para{idx}{1}=str2double(callbackdata.NewValue.String);
        end
        recompute();
    end
    function out = get_output()
        out = mp_handle.fcn_output;
    end
recompute();
end