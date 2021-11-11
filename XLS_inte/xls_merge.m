function r = xls_merge(r,flist,Key_List)
%% function r = xls_merge(r,flist,Key_List); merge all records in all
% files listed in cellstr flist into r, add if new, skip if same
% two records belong to same id if one of the keys in key_list are same.
% % % % 数据结构
% % % % 	主id
% % % % 	与主id对应的各个主键
% % % % 	子表
% % % % 		每条记录给每个文件夹下的表格设定一个单独的子标
% % % % 		子id（同一个问卷、量表中各个记录的主id）
% % % % 		与子id对应的数据
% % % % 流程
% % % % 	excel读入
% % % % 	按照给定优先次序，核对主键
% % % % 	是否已有主键
% % % % 		Y
% % % % 			是否已有记录
% % % % 				如果有
% % % % 					对应子表是否已有记录
% % % % 						Y
% % % % 							记录是否相同
% % % % 								Y
% % % % 									跳过
% % % % 								N
% % % % 									追加数据副本
% % % % 										子表数据
% % % % 										子id
% % % % 						N（或子表为空）
% % % % 							更新
% % % % 								子表数据
% % % % 								子id
% % % % 				如果没有
% % % % 					更新
% % % % 						子表数据
% % % % 						子id
% % % % 						主id
% % % % 						主键
% % % % 					下一个主键是否有记录
% % % % 						为了避免嵌套，最后一个主键再判断是否有重复主键即可
% % % % 		N
% % % % 			下一个主键

%% Initialize r
if isempty(r)
    r.prim_id = 0;
    r.prim_id_cols = Key_List;% initial primary id columns
end
%% Updating
for itr = 1:length(flist)
    fname = flist{itr};
    [f_fpath,f_fname] = fileparts(fname);
    [~,folder_name] = fileparts(f_fpath);% get folder name, which would be the field name of corresponding data
    
    fprintf('Start: Docking File %s into dataset\n',fname)
    [~,~,crdata] = xlsread(fname);% current data
    head = cellfun(@num2str,crdata(1,:),'UniformOutput',false);
    data = cellfun(@num2str,crdata(2:end,:),'UniformOutput',false);%trans all number into string
    if size(r.prim_id_cols,1)==1
        r.prim_id_cols = [r.prim_id_cols;repmat({'ini_rid'},size(Key_List))];% then nothing could be old and all are supposed to be added
        display 'Initialize prim_id'
    end
    rid_head = r.prim_id_cols(1,:);
    rid_cols = r.prim_id_cols(2:end,:);% id_columns in r
    if ~isfield(r,folder_name)% table initialization: create an empty field if it does not exist
        r = setfield(r,folder_name,struct('id',[],'data',[]));
    end
    sub_table  = getfield(r,folder_name);% sub table for current folder
    
    n_id_cols = size(rid_cols,2);
    lgth_key = length(Key_List);
    id_cols = cellfun(@num2str,num2cell(nan(size(data,1),size(Key_List,2))),'UniformOutput',false);% related id columns if existed, nan if unexisted
    
    for itr_key=1:lgth_key
        id_key = Key_List{itr_key};
        
        idx = strfind(head,id_key);% try to find position of the identifier(key) if exists
        pos_key = find(~cellfun(@isempty,idx));% position of the key
        
        if isempty(pos_key)% this identifier does not exist in current file
            continue;% could be put at the start of the loop since if no key word exists in head, script will break at previous loop
        end% identifier exists
        
        if length(pos_key)>1% if more than one of same id name
            fprintf('Caution:\n duplicate identifier "%s" in file %s\n at Columns: %i and %i\n'...
                ,id_key,fname,pos_key)
            % **grammar:input of more pos_key than %i is legal and all will be
            % printed in multiple lines with same %s and other parameters
            display '...The first one will be used'
            pos_key = pos_key(1);
        end
        id_cols(:,itr_key) = data(:,pos_key);% fill in the valuse
        %% Step A. Whether exist same record in the current sub table
        
        %*****Data Structure*****    var with same row Number:
        %       data, id_col, id_cols
        %       r.prim_id-1, rid_col, rid_cols
        %       sub_id, sub_rid_col,sub_data
    end
    for itr_key=1:lgth_key
        
        id_key = Key_List{itr_key};   
        idx = strfind(head,id_key);% try to find position of the identifier(key) if exists          
        pos_key = find(~cellfun(@isempty,idx));% position of the key
        if isempty(pos_key)% this identifier does not exist in current file
            continue;% could be put at the start of the loop since if no key word exists in head, script will break at previous loop
        end% identifier exists
        if isempty(data)% all data proced or no data detected
            fprintf('Finish because all data have beenappended: Docking Key word "%s"\n',id_key)
            break;
        end
        fprintf('Start: Docking Key word %s\n',id_key)
        id_col = id_cols(:,itr_key);% column of the current identifier
        r_pos_key = ~cellfun(@isempty,strfind(rid_head,id_key));% column of corresponding identifier in recorded data, only one column.
        rid_col = rid_cols(:,r_pos_key);
        % get ids if in record, create ids if not in record
        
        % records with known id
        if ~isempty(rid_col)% for empty rid_col, function intersect will fail
            [~,ia,ib] = intersect(id_col,rid_col);% index of repeated ids;
        else
            ia = [];
        end
        if ia% exist intersected records based on this Primary Key
            sub_id = sub_table.id;
            sub_data = sub_table.data;
            if ~isempty(sub_id)%
                sub_rid_col = rid_cols(sub_id,r_pos_key);% Column of Values in Primary Key from current sub table
                [~,ias,ibs] = intersect(id_col,sub_rid_col);
                
                if ias%existing repeated ids
                    % Step 1. skip repeated ones (do nothing)
                    
                    % Step 2. add non-repeated lines into sub_table
                    [data_add,iad] = setdiff(data(ias,:),sub_data(ibs,:),...
                        'rows','stable');% records with same id but different contents
                    
                    id_add = sub_id(ibs(iad));% fetch ids that appear in new data but not in old sub_data
                    sub_table.id = [sub_id;id_add];% Step 2. Append sub_id
                    sub_table.data = [sub_data;data_add];% Step 1. Append Data into sub_table
                    data(ias,:) = [];
                    id_cols(ias,:) = [];% clear proced records
                    id_col = id_cols(:,itr_key);% renew column of the current identifier
                    [~,ia,ib] = intersect(id_col,rid_col);% recompute index of repeated ids;
                end
            end% no records in sub_table || no repeating id
            % Step 1. append data to sub_table
            if ia% maybe it's new
                data_add = data(ia,:);
                id_add = r.prim_id(ib + 1);% 1st id stand for init value
                sub_table.id = [sub_id;id_add];% Step 2. Append sub_id
                sub_table.data = [sub_data;data_add];% Step 1. Append Data into sub_table
                data(ia,:)=[];
                id_cols(ia,:) = [];% clear proced records
                id_col = id_cols(:,itr_key);% renew column of the current identifier
            end
        end
        ex = strjoin(Key_List(itr_key+1:lgth_key),'|');%regular expression for finding remaining key words
        rx = find(~cellfun(@isempty,regexp(head,ex)),1);% whether existing remaining key words in head
        %% in the last loop/ no remaining key words in var head-- existing data are all-new
        if isempty(rx)
            [~,iad] = setdiff(id_col,rid_col,'stable');% new records: value not recorded in primary key
            if iad% if exist, this should be with a new rid, update primary key and id
                n_add = length(iad);
                id_cols_add = id_cols(iad,:);
                id_add = (r.prim_id(end)+1 : r.prim_id(end)+n_add)';
                data_add = data(iad,:);
                data(iad,:) = [];
                id_cols(iad,:) = [];
                id_col = id_cols(:,itr_key);% renew column of the current identifier
                
                %end of the loop so there is no need to clear it
                rid_cols = [rid_cols;id_cols_add];% Step 4. Update Primary Keys
                r.prim_id_cols = [rid_head;rid_cols];% because this block only runs at the last loop, r.prim_id_cols could be updated here
                
                r.prim_id = [r.prim_id;id_add];% append new increased ids primary id. Step 3. Update Primary Ids
                
                sub_table.id = [sub_table.id;id_add];% Step 2. Update secondary Ids
                
                sub_table.data = [sub_table.data;data_add];% Step 1. Update secondary data
                
                r = setfield(r,folder_name,sub_table);
            end
            break
        end
        fprintf('End: Docking Key word "%s"\n',id_key)
    end
    fprintf('End: Docking file "%s"\n',f_fname)
end