function s1 = get_col_for_each_field(s0,col_no)
% only keep the specified column of each field
fld_list = fieldnames(s0);
for i_fld = 1:length(fld_list)
    fld_name = fld_list{i_fld};
    tmp = s0.(fld_name);
    tmp_sz = size(tmp);
    ind = arrayfun(@(n)1:n,tmp_sz,'UniformOutput',false);
    s1.(fld_name) = tmp(ind{1},col_no,ind{3:end});
end
end