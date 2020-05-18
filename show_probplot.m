function pt = show_probplot(xys)
[row col] = size(xys);

output_path = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\cluster_analysis\';
for i = 1:row
    name = table2array(xys(i,1));
    data = table2array(xys(i,2:col-1));
% %     this line puts clusters in correct order
%     data_new = [data(6) data(5) data(2) data(1) data(3) data(4)]
    
    p_bar = bar(data)
%     p_bar.FaceColor = '#0072BD';
%     p_bar.EdgeColor = '#0072BD';
    set(gca,'xticklabel',{[]})
    bjff3;
    ylim([0 0.8])
    camroll(-90);
    
    saveas(gca,fullfile(output_path,name),'png')

    
end
close all
end 
    
    