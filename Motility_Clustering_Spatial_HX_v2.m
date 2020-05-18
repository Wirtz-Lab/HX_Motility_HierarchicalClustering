clear,clc

path = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\matlab output\';
files = dir([path, '\*.xlsx']);

filenames = {files(:).name}.';

data_composite = table();
M0_code = ['xy076','xy080','xy120','xy116'];
M1_code = ['xy092','xy104','xy096'];
M2_code = ['xy088','xy108','xy112'];
KPC1_code = ['xy017','xy029','xy065'];
KPC2_code = ['xy021','xy072','xy025'];

for file = 1:length(files)
% for file = length(files):-1:1
    
    data_perfile = [];
    name_i = files(file).name;
    name_str = name_i(1:5);

    if contains(name_i,"APRW model fit")
        P = readmatrix([path name_i],'Sheet','APRW fitting-p');
        Pp = P(:,1);
        Sp = P(:,2);
        Dp = Pp.^2 .* Sp.^2/4;
        
        NP = readmatrix([path name_i],'Sheet','APRW fitting-np');
        Pnp = NP(:,1);
        Snp = NP(:,2);
        Dnp = Pnp.^2 .* Snp.^2/4;
        
        Dtot = Dnp + Dp;
        
        Psi = Dp./Dnp;
        
        table_part2 = table(Pp,Pnp,Dp,Dnp,Dtot,Psi);
        
    
    elseif contains(name_i,"MSD")

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
        
        M = readmatrix([path name_i],'Sheet','individual cell msd');
        ind_msd10 = M(:,1) == 10;
        ind_msd60 = M(:,1) == 60;
        msd10 = M(ind_msd10,2:end);
        msd60 = M(ind_msd60,2:end);
        
        conditions = repmat(convertCharsToStrings(condition), length(msd10),1);
        FOVs = repmat(convertCharsToStrings(name_str), length(msd10),1);

        table_part1 = table(conditions,FOVs,msd10.',msd60.');
        table_part1.Properties.VariableNames = {'Condition','File','MSD10','MSD60'};
%         data_perfile = [data_perfile table_part1];

        data_perfile = [table_part1 table_part2]; 
        data_composite = [data_composite; data_perfile];
    end 
%         break
        
end 

data_array = table2array(data_composite(1:end,3:end));
% data_array_log = log10(data_array);
data_array_log = log(data_array);
variable_names = [data_composite.Properties.VariableNames].';
parameters = variable_names(3:end,1);

data_composite_z = data_composite(:,1:2);
z_array = [];
for k = 1:length(parameters)
    column_data = data_array_log(:,k);
    avg = mean(column_data);
    stdev = std(column_data);
    z = (column_data - avg)/stdev;
    z_array = [z_array z];

    z_test_mean = mean(z);
    z_test_std = std(z);
    
    assert((-0.01 < z_test_mean) && ( z_test_mean < 0.01), "z-score failed: mean is not 0")
    assert((0.99 < z_test_std) && (z_test_std < 1.01), "z-score failed: st dev is not 1")

end 
data_composite_z = [data_composite_z array2table(z_array)];
data_composite_z.Properties.VariableNames = {'Condition','File','MSD10_z','MSD60_z','Pp_z','Pnp_z','Dp_z','Dnp_z','Dtot_z','Psi_z'};

                        
% pdist_method = {'euclidean','seuclidean','mahalanobis','cityblock','minkowski','chebychev','cosine','correlation','hamming','jaccard','spearman'}
% linkage_method = {'average','centroid','complete','median','single','ward','weighted'}
% for m = 1:length(pdist_method)
%     pdist_method{m}
%     eucD = pdist(z_array,pdist_method{m});
%     % % eucZ = squareform(eucD)
%     clustTreeEuc = linkage(eucD,'average');
%     c=cophenet(clustTreeEuc,eucD)
%     % assert((0.95 < c)&&(c < 1.05), 'Dissimilarity fail to verify: cophenet coefficient is not 1')
% end 

% for m = 1:length(linkage_method)
%     eucD = pdist(z_array,'cityblock');
%     clustTreeEuc = linkage(eucD,linkage_method{m});
%     linkage_method{m}
%     c=cophenet(clustTreeEuc,eucD)
% end 

eucD = pdist(z_array,'cosine');
clustTreeEuc = linkage(eucD,'ward');
I = inconsistent(clustTreeEuc);
% T = cluster(clustTreeEuc,'cutoff',1.154682)

T = cluster(clustTreeEuc, 'maxclust', 6);
cluster_num = length(unique(T));
data_composite_z = [data_composite_z array2table(T)];
data_composite_z.Properties.VariableNames{'T'} = 'cluster_ID';

%This section figure out the occurance of each cluster per condition
unique_condition_count = [];
for cluster = 1:cluster_num
    idx = find(T == cluster);
    M0_counter = 0;
    M1_counter = 0;
    M2_counter = 0;
    KPC1_counter = 0;
    KPC2_counter = 0;
    for cluster_idx = 1:length(idx)
        if contains(table2array(data_composite_z(idx(cluster_idx),1)),'M0')
            M0_counter = M0_counter + 1;
        elseif contains(table2array(data_composite_z(idx(cluster_idx),1)),'M1')
            M1_counter = M1_counter + 1;
        elseif contains(table2array(data_composite_z(idx(cluster_idx),1)),'M2')
            M2_counter = M2_counter + 1;
        elseif contains(table2array(data_composite_z(idx(cluster_idx),1)),'KPC1')
            KPC1_counter = KPC1_counter + 1;
        elseif contains(table2array(data_composite_z(idx(cluster_idx),1)),'KPC2')
            KPC2_counter = KPC2_counter + 1;
        else disp(['Error: index' num2str(idx(cluster_idx)) ' is not in table'])
        end 
        
    end
    counter_array = [M0_counter; M1_counter; M2_counter; KPC1_counter; KPC2_counter;];
    unique_condition_count = [unique_condition_count counter_array];
    
end 

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
%     saveas = ['sp0' num2str(clusterno) '_coor_spatial cluster.xlsx'];
%     xlswrite([path,saveas],cluster_traj,'cluster_coor');
%     
%     delete_extra_sheet(path,saveas)
% end 
%     


% This section figure out the occurance per cluster per file

unique_file_count = table(unique(data_composite_z.File));
unique_file_count.Properties.VariableNames = {'file'};

for cluster2 = 1:cluster_num
    idx2 = find(T == cluster2);
    table_idx2 = data_composite_z(idx2,:);
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
%     occurance_file_count(p_row,1)= unique_file_count(p_row,1);
%     occurance_file_count{p_row,2:9} = unique_file_count{p_row,2:9}./unique_file_count{p_row,10};
%     pi_val = nonzeros(table2array(occurance_file_count(p_row,2:9)));
%     shannon_e = -sum(pi_val.*log(pi_val));
%     occurance_file_count(p_row,10) = num2cell(shannon_e);
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

% [H,T,outperm] = dendrogram(clustTreeEuc,0, 'orientation','top','colorthresh',6.5);

% figure(); 
% %[h,nodes] = dendrogram(clustTreeEuc,0);
% %[h,nodes] = dendrogram(clustTreeEuc,11,'orientation','top','colorthresh','default');
% [h,nodes] = dendrogram(clustTreeEuc,0,'orientation','right','colorthresh', 'default');
% %h = dendrogram(clustTreeEuc,0,'orientation','left','colorthresh','default');
% % h_gca = gca;
% % h_gca.TickDir = 'out';
% % h_gca.TickLength = [.02 0];
% %h_gca.XTickLabel = [];lin_s4
% leafOrder = optimalleaforder(clustTreeEuc,eucD);
% 
% [H,T,outperm] = dendrogram(clustTreeEuc,0, 'orientation','top','colorthresh','default');
% % set(H,'LineWidth',1.5)
% % bjff3;

% 
% cg = clustergram(z_array,'ColumnLabels', parameters,...
%                             'RowPdist',  'cityblock',...
%                             'ColumnPdist', 'cityblock',...
%                             'DisplayRatio',[0.1;0.2],...
%                             'Linkage','ward',...
%                             'OptimalLeafOrder', true,...
%                             'Dendrogram', 40,...
%                             'Colormap',redbluecmap,...
%                             'DisplayRange', 2.5,...
%                             'Standardize',  3);
cg2 = clustergram(z_array,'ColumnLabels', parameters,...
                            'RowPdist',  'cosine',...
                            'ColumnPdist', 'cosine',...
                            'Linkage','ward',...
                            'OptimalLeafOrder', true,...
                            'DisplayRatio',[0.1;0.2],...
                            'Dendrogram', 4.5,...
                            'Colormap',redbluecmap,...
                            'DisplayRange', 2.5,...
                            'Standardize',  3);
                        
cg3 = clustergram(z_array,'ColumnLabels', parameters,...
                            'RowPdist',  'cosine',...
                            'ColumnPdist', 'cosine',...
                            'Linkage','ward',...
                            'OptimalLeafOrder', true,...
                            'DisplayRatio',[0.1;0.2],...
                            'Dendrogram', 9,...
                            'Colormap',redbluecmap,...
                            'DisplayRange', 2.5,...
                            'Standardize',  3);

% cg_figure = plot(cg)
% colorbar('east')

