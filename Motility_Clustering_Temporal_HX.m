clear,clc

path = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\matlab output\';
files = dir([path, '\*.xlsx']);

filenames = {files(:).name}.';

tframe = 101;

data_composite = [];
data_composite_table = table();
M0_code = ['xy076','xy080','xy120','xy116'];
M1_code = ['xy092','xy104','xy096'];
M2_code = ['xy088','xy108','xy112'];
KPC1_code = ['xy017','xy029','xy065'];
KPC2_code = ['xy021','xy072','xy025'];

for file = 1:length(files)
    name_i = files(file).name;
    name_str = name_i(1:5);
    
    if contains(name_i,"displacement over time")

%         if ~any(strcmp(M0_code, name_str))
        if contains(M0_code, name_str)
            condition = 'M0__';
        elseif contains(M1_code, name_str)
            condition = 'M1__';
        elseif contains(M2_code, name_str)
            condition = 'M2__';
        elseif contains(KPC1_code, name_str)
            condition = 'KPC1';
        elseif contains(KPC2_code, name_str)
            condition = 'KPC2';
        else condition = 'condition undefined';
        end 
        disp([name_str ' is under condition: ' condition])
        
        M = readmatrix([path name_i],'Sheet','distance over time');
        M = M(1:tframe,:);
        data_composite = [data_composite,M];
        
        [r,c] = size(M.');
        conditions = repmat(convertCharsToStrings(condition), r,1);
        FOVs = repmat(convertCharsToStrings(name_str), r,1);
        Mt = [conditions FOVs M.'];
        data_composite_table = [data_composite_table; array2table(Mt)];

    end 
    
end 

data_composite_table.Properties.VariableNames{'Mt1'} = 'Condition';
data_composite_table.Properties.VariableNames{'Mt2'} = 'File';
data_composite = data_composite.';

% data_composite_log = log(data_composite);
[r,c] = size(data_composite);

z_array = [];
for column = 1:c
    column_data = data_composite(:,column);
    avg = mean(column_data);
    stdev = std(column_data);
    z = (column_data - avg)/stdev;
    z_array = [z_array z];

    z_test_mean = mean(z);
    z_test_std = std(z);
    
    assert((-0.01 < z_test_mean) && ( z_test_mean < 0.01), "z-score failed: mean is not 0")
    assert((0.99 < z_test_std) && (z_test_std < 1.01), "z-score failed: st dev is not 1")

end 

header = data_composite_table(:,1:2);
data_composite_table_z = [header array2table(z_array)];

eucD = pdist(z_array,'cosine');
clustTreeEuc = linkage(eucD,'ward');
I = inconsistent(clustTreeEuc);
% T = cluster(clustTreeEuc,'cutoff',1.154682)

T = cluster(clustTreeEuc, 'maxclust', 3);
cluster_num = length(unique(T))

% pdist_method = {'euclidean','seuclidean','mahalanobis','cityblock','minkowski','chebychev','cosine','correlation'}
% for m = 1:length(pdist_method)
%     cg = clustergram(z_array,'RowPdist',  'cityblock',...
%                             'ColumnPdist', m,...
%                             'OptimalLeafOrder', true,...
%                             'Cluster', 1,...
%                             'Colormap',redbluecmap,...
%                             'Dendrogram', 0.05,...
%                             'DisplayRange', 2,...
%                             'Standardize',  3);
% end 

% % The following section writes the xy-coor into excel by cluster
% xy_coor = readmatrix([path 'xy_coor_composite.xlsx'],'Sheet','xy_coor');
% for clusterno = 1:cluster_num
%     cluster_list = find(T==clusterno);
%     cluster_traj = [];
%     for i = 1:length(xy_coor)
%         for j = 1:length(cluster_list)
%             if xy_coor(i,1) == cluster_list(j);
%                 cluster_traj = [cluster_traj; xy_coor(i,:)];
%             end
%         end
%     end
%     saveas = ['tp0' num2str(clusterno) '_coor_temporal.xlsx'];
%     xlswrite([path,saveas],cluster_traj,'cluster_coor');
%     
%     delete_extra_sheet(path,saveas)
% end 
    
col_label = {};
for i = 1:101
    num_list = [1,10,20,30,40,50,60,70,80,90,100];
    if ismember(i,num_list)
        col_label = [col_label ['t-' num2str(i)]];
    else col_label = [col_label " "];
    end
end 
        
% cg = clustergram(z_array,'RowPdist',  'cityblock',...
%                             'ColumnPdist', 'cityblock',...
%                             'Linkage','ward',...
%                             'ColumnLabels', col_label,...
%                             'DisplayRatio',[0.1;0.2],...
%                             'Cluster', 1,...
%                             'Colormap',redbluecmap,...
%                             'Dendrogram', 320,...
%                             'DisplayRange', 2.5,...
%                             'Standardize',  3);
cg2 = clustergram(z_array,'RowPdist',  'cosine',...
                            'ColumnPdist', 'cosine',...
                            'Linkage','ward',...
                            'ColumnLabels', col_label,...
                            'DisplayRatio',[0.1;0.2],...
                            'OptimalLeafOrder', true,...
                            'Cluster', 1,...
                            'Colormap',redbluecmap,...
                            'Dendrogram', 5,...
                            'DisplayRange', 2.5,...
                            'Standardize',  3);



                        
unique_file_count = table(unique(data_composite_table_z.File));
unique_file_count.Properties.VariableNames = {'file'};

for cluster2 = 1:cluster_num
    idx2 = find(T == cluster2);
    table_idx2 = data_composite_table_z(idx2,:);
    file_count = groupcounts(table_idx2, 'File');
    for k = 1:length(file_count.File)
       row_num = find(strcmp(unique_file_count.file, file_count.File(k)));
       unique_file_count(row_num,cluster2+1) = num2cell(file_count.GroupCount(k));
    end 
    unique_file_count.Properties.VariableNames([cluster2+1]) = {['cluster' num2str(cluster2)]};
end 

%calculating Shannon's Entropy 

unique_file_count.SumOverCluster = sum(unique_file_count{:,2:end},2);
[~,column_num] = size(unique_file_count);
for p_row = 1:length(unique_file_count.file)
    
    occurance_file_count(p_row,1)= unique_file_count(p_row,1);
    occurance_file_count{p_row,2:(column_num-1)} = unique_file_count{p_row,2:(column_num-1)}./unique_file_count{p_row,column_num};
    pi_val = nonzeros(table2array(occurance_file_count(p_row,2:(column_num-1))));
    shannon_e = -sum(pi_val.*log(pi_val));
    occurance_file_count(p_row,column_num) = num2cell(shannon_e);
end 
occurance_file_count.Properties.VariableNames([column_num]) = {'ShannonE'};

assignment = {M0_code, M1_code, M2_code, KPC1_code, KPC2_code};
shannon_array = [];
for w = 1:length(assignment)
    shannon_array_i = [];
    for q = 1:length(occurance_file_count.ShannonE)
        if contains(assignment(w),convertStringsToChars(occurance_file_count.file(q)))
            shannon_array_i = [shannon_array_i; occurance_file_count.ShannonE(q)];
        end 
    end 
    if length(shannon_array_i) == 3
        shannon_array_i = [shannon_array_i; 0];
    end
    shannon_array = [shannon_array shannon_array_i];
end 


