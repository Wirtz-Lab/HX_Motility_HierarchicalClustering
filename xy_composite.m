% function output = xycomposite(path)

    path = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\';

    files = dir([path, '\*.xlsx']);

    filenames = {files(:).name}.';

    xy_data_composite = [];
    for file = 1:length(files);
        data_perfile = [];
        name_i = files(file).name
        name_str = name_i(1:5);
        
        M = readmatrix([path name_i],'Sheet','Sheet1');
        if file == 1;
            xy_data_composite = [xy_data_composite; M];
        else
            pre_max = xy_data_composite(end,1);
            M_new = [M(:,1)+ pre_max M(:,2:end)];
            xy_data_composite = [xy_data_composite; M_new];
        end
    end 
    
    c = length(unique(xy_data_composite(:,1)));
    display(['Total cells tracked: ' num2str(c)])
    unique_xy = unique(xy_data_composite(:,1));
    cell_ids = [];
    for i = 1:length(xy_data_composite(:,1))
        cell_id = find(unique_xy == xy_data_composite(i,1));
        cell_ids = [cell_ids; cell_id];
    end 
    xy_data_composite = [cell_ids xy_data_composite];
    xy_data_composite(:,2) = [];
    
    filesaveas = 'xy_coor_composite.xlsx';
    xlswrite([path,filesaveas],xy_data_composite,'xy_coor');
    delete_extra_sheet(path,filesaveas);
% end 