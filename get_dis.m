function [feq,bin]=get_dis(xys,tlag0,code,param)
% This file compute the 1-D displacement over time
% This file is written by HX based on get_voft by PW
        if nargin==0
            xys=get_trajfile;    
        end
        if isempty(xys)
            xys=get_trajfile;    
        end
       if nargin <=1
           tlag0=1;
       end
        if  nargin <=3 % set the bin size             
            param.showfig=1;
            param.saveres=1;
            param.dim=2;
            param.outfigurenum=300;
            param.markertype='b-';
        end
        d_out=[];
         for k=1:length(xys);  
                xy=xys{k};         
                dxy=xy(1+tlag0:end,1:param.dim)-xy(1:end-tlag0,1:param.dim) ;  
                [~,dr]=cart2pol(dxy(:,1),dxy(:,2)) ;
                dr=dr/tlag0;
                d_out=[d_out,dr];             
         end     
                        
            if param.saveres
                pathname = 'C:\Users\Wirtz\Desktop\For APRW\matlab output\';
                filename = [code, ' displacement over time.xlsx'];
%              [filename, pathname] = uiputfile( ...       
%                  {'*.xlsx',  'excel files (*.xlsx)'; ...
%                    '*.xls','excel file (*.xls)'}, ...             
%                    'save average velocity profile','velocity over time.xlsx');                
                
                xlswrite([pathname,filename],d_out,'distance over time');
                delete_extra_sheet(pathname,filename);
            end
             
            if param.showfig
                figure(param.outfigurenum); 
                plot(d_out,param.markertype);
                xlabel('Time Interval')
                ylabel('Distance (um)')
                bjff3;
                ylim([0 100])
                hold on;
                  saveas(gca,fullfile('C:\Users\Wirtz\Desktop\For APRW\matlab output\',[code, ' mean velocity over time']),'png')

            end
            hold off
            close all
            if nargout==0
                clear
            end
    
end