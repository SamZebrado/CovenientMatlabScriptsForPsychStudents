% % % % 流程
% % % % 	excel读入
% % % % 	按照给定优先次序，核对主键
% % % % 	是否已有记录
% % % % 		如果有
% % % % 			对应子表是否已有记录
% % % % 				Y
% % % % 					记录是否相同
% % % % 						Y
% % % % 							跳过
% % % % 						N
% % % % 							追加数据副本
% % % % 								子表数据
% % % % 								子id
% % % % 				N
% % % % 					更新
% % % % 						子表数据
% % % % 						子id
% % % % 		如果没有
% % % % 			更新
% % % % 				子表数据
% % % % 				子id
% % % % 				主id
% % % % 				主键
function r = xls_merge(r,flist,Key_List)
%% function r = xls_merge(r,flist,Key_List); merge all records in all
% files listed in cellstr flist into r, add if new, skip if same
% two records belong to same id if one of the keys in key_list are same.
%% Initialize r
if isempty(r)
    r.prim_id = [0];
    r.prim_id_col = {Key_List;nan(1,length(Key_List))};% initial primary id columns
end
%% Updating
for itr = 1:length(flist)
    fname = flist{itr};
    [f_fpath,f_fname] = fileparts(fname);
    [~,folder_name] = fileparts(f_fpath);% get folder name, which would be the field name of corresponding data
    if ~isfield(r,folder_name)% table initialization: create an empty field if it does not exist
        r = setfield(r,folder_name,struct('id',[],'data',[]));
    end
    fprintf('Start: Docking File %s into dataset',fname)
    [~,~,crdata] = xlsread(fname);% current data
    head = crdata(1,:);
    data = crdata(2:end,:);
    rid_head = r.prim_id_col{1};
    rid_cols = cell2mat(r.prim_id_col{2});% id_columns in r
    n_id_cols = size(rid_cols,2);
    lgth_key = length(Key_List);
    for itr_key=1:lgth_key
        if isempty(data)% all data proced or no data detected
            fprintf('Finish: Docking Key word "%s"\n',id)
            break;
        end        
        id = Key_List{itr_key};        
        idx = strfind(head,id);% try to find position of the identifier(key) if exists
        pos_key = find(~cellfun(@isempty,idx));% position of the key
        
        if isempty(pos_key)% this identifier does not exist in current file
            continue;
        end% identifier exists
        
        if length(pos_key)>1
            fprintf('Caution:\n duplicate identifier "%s" in file %s\n at Columns: %i and %i\n'...
                ,id,fname,pos_key)
            % **grammar:input of more pos_key than %i is legal and all will be
            % printed in multiple lines with same %s and other parameters
            display '...The first one will be used'
            pos_key = pos_key(1);
        end
            id_col = data(:,pos_key);% column of the current identifier
            r_pos_key = ~cellfun(@isempty,strfind(rid_head,id));% column of corresponding identifier in recorded data, only one column.
            rid_col = rid_cols(:,r_pos_key);
            % get ids if in record, create ids if not in record

            % records with known id
            [~,ia,ib] = intersect(id_col,rid_col);% index of repeated ids;
            
            %   Step 1. intersected records should be merged: added if new; skipped if
            %     repeated
            [rdata_add,ibd] = setdiff(data(ib,:),rdata(ia,:),'rows','stable');% add records with same id but unique contents
            rdata = [rdata;rdata_add];
            % simultaneously update the id columns
            % Problem : what if not all id columns exist in current dataset? eg.
            % Column Name does not exist in all tables
            rid_cols = [rid_cols;id_cols(ibd,:)];
            % nothing is needed to skip repeated records
            %     Step 2. remove docked rows
            data(ibd,:) = [];
            %     Step 3. non intersected records should be added in the last loop
            
            idn = setdiff(1:size(data,1),ib);% index of non-intersected records
            rdata = [rdata;data(idn,:)];
            rid_cols = [rid_cols;id_cols(idn,:)];% update id columns
           %% in the last loop -- existing data are all-new
            if itr_key==lgth_key
                [~,iad] = setdiff(id_col,rid_col);% new records: value not recorded in primary key
                if iad% if exist, this should be with a new rid, update primary key and id
                    n_add = length(iad);
                    id_cols_add = nan(n_add,n_id_cols);
                    id_cols_add(:,pos_key) = id_col(iad);% put values in
                    
                    id_add = [r.prim_id(end)+1 : r.prim_id(end)+n_add]';
                    data_add = data(iad,:);
                    
                    rid_cols = [rid_cols;id_cols_add];% Step 4. Update Primary Keys
                    r.prim_id_cols = rid_cols;% because this block only runs at the last loop, r.prim_id_cols could be updated here
                    
                    r.prim_id = [r.prim_id(end);id_add];% append new increased ids primary id. Step 3. Update Primary Ids
                    
                    sub_struct  = getfield(r,folder_name)% sub table for current folder
                    
                    sub_struct.id = [substruct.id;id_add];% Step 2. Update secondary Ids
                    
                    sub_struct.data = [sub_struct.data;data_add];% Step 1. Update secondary data
                    
                    r = setfield(r,folder_name,sub_struct);
                end
            end
    end
end
fprintf('End: Docking Key word "%s"',id)
end
fprintf('End: Docking file "%s"',fname)
end