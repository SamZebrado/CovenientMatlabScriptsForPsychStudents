function mp_handle = GenerateManiPanel(plot_fc,para,f,h)
new_pos = [10 30 500 30];
n_para = length(para);
Children = cell(n_para,1);
figure(f);
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
        if ismember('Pool',para_info)
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
        new_pos(2) = new_pos(2) +50;
    end
% use nested functions to manipulate varaible "para"
    function replot()
        axes(h);% switch to to specified axes
        exc_para = cellfun(@(c)c{1},para,'UniformOutput',false);
        plot_fc(exc_para{:});
    end
    function box_update(source,callbackdata)
        idx = get(source,'UserData');
        value = get(source,'string');
        if ischar(para{idx}{1})% char
            para{idx}{1}=value;
        else% number
            para{idx}{1}=str2double(value);
        end
        replot();
    end
    function range_update(source,callbackdata)
        idx = get(source,'UserData');
        value = get(source,'Value');
        para{idx}{1}=value;
        replot();
    end
    function pool_update(source,callbackdata)
        idx = get(source,'UserData');
        display(['Previous: ' callbackdata.OldValue.String]);
        display(['Current: ' callbackdata.NewValue.String]);
        display('------------------');
        if ischar(para{idx}{1})% char
            para{idx}{1}=callbackdata.NewValue.String;
        else% number
            para{idx}{1}=str2double(callbackdata.NewValue.String);
        end
        replot();
    end
end