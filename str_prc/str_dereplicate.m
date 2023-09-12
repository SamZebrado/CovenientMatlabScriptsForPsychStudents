function [d,r,ir] = str_dereplicate(s,varargin)
%% [d,r,ir] = dereplicate(s,min_l) would
% detect repliacated parts of strings
% return dereplicated in d
% replicated ones in cell array r, one element for one replicated string
% and corresponding index of replicated in cell array ir
% min_l is the minimum length of a replicated string, 2 by default
if nargin==1
    min_l = 2;
else
    min_l = varargin{1};
end
[c,~,ic] = unique(s,'stable');% transform string into numbers
l = length(ic);
r = {};
ir = {};
for i_step = 1:l
    t1 = ic(1:end-i_step);
    t2 = ic(1+i_step:end);
    ind1 = find(t1-t2);% only replicated ones generate zeros in (t1-t2)
    ind1 = [0 ind1(:)' length(t1)+1];% transpose to avoid 0-by-1 ind1
    ind2 = diff(ind1)>min_l;% only concatenated zeros generates diff>1

    % and length(zeros)>min_l will generate diff>min_l
    if sum(ind2)% replicated string exists
%         display woo!!!
        ind2 = find(ind2);
            for irp = 1:length(ind2)
                r{end+1} = s(ind1(ind2(irp))+1:ind1(ind2(irp)+1)-1);
            end
    end
end
r = unique(r);
ir = cellfun(@strfind,repmat({s},size(r)),r,'UniformOutput',false);
d = num2cell(s);
for i_r = 1:length(r)
is = ir{i_r};
is(1) = [];
for ii_r = 1:length(is)
d(is:is+length(r{i_r})-1)={''};
end
end
d = cell2mat(d);
end