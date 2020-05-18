clear, clc

path = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\'
files = dir([path, '\*.xlsx']);

M0_code = ['xy076','xy080','xy120','xy116'];
M1_code = ['xy092','xy104','xy096'];
M2_code = ['xy088','xy108','xy112'];
KPC1_code = ['xy017','xy029','xy065'];
KPC2_code = ['xy021','xy072','xy025'];

conditions = {M0_code, M1_code, M2_code, KPC1_code, KPC2_code};
condition_codes = {'M0___', 'M1___', 'M2___', 'KPC1_', 'KPC2_'};
for j = 1:length(conditions)
    condition = conditions(j);
    condition_code = condition_codes(j);
    
    data_percondition = [];
        for file = 1:length(files);
            data_perfile = [];
            name_i = files(file).name
            name_str = name_i(1:5);
            
            if contains(condition,name_str)
                
                M = readmatrix([path name_i],'Sheet','Sheet1');
                if length(data_percondition) == 0;
                    data_percondition = [data_percondition; M];
                else
                    pre_max = data_percondition(end,1);
                    M_new = [M(:,1)+ pre_max M(:,2:end)];
                    data_percondition = [data_percondition; M_new];
                end 
            end
        end 

        c = length(unique(data_percondition(:,1)));
        display(['Total cells tracked for' condition_code num2str(c)])
        unique_xy = unique(data_percondition(:,1));
        cell_ids = [];
        for i = 1:length(data_percondition(:,1))
            cell_id = find(unique_xy == data_percondition(i,1));
            cell_ids = [cell_ids; cell_id];
        end 
        data_percondition = [cell_ids data_percondition];
        data_percondition(:,2) = [];

        filesaveas = [char(condition_code) '.xlsx'];
        xlswrite([path,filesaveas],data_percondition,'Sheet1');
        delete_extra_sheet(path,filesaveas);
end 