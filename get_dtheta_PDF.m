function [dtheta_PDF]=get_dtheta_PDF(xys,tloi,code,path_out,param)
% calculate probability density function (PDF) of angular displacement   
% 
% Syntax:
%   get_dtheta_PDF;
%   [feq,bin]=get_dtheta_PDF;
%   [feq,bin]=get_dtheta_PDF(xys);
%   [feq,bin]=get_dtheta_PDF(xys,tloi);
%   [feq,bin]=get_dtheta_PDF(xys,tloi,param);
% 
% input:
%   xys (optional): a N*1 cell array, Each cell contains individual cell trajectory data matrice. 
%   The format of trajectory matrice must be in the the sequence of cell id, time frame, x, y, z ;      
%   Each trajectories  must have the same time length, Nt.
%   if xys is not provided, the "get_trajfile.m" will be called to
%   select and input trajectories file. (see get_trajfile for more
%   details). 
%   tloi  (optional): frame lag for calculate displacements and angular displacement; 
%   if not included a default vector of [1 10 40] will be used. 
%   param (optional) : parameters setting. if not included, default values of setting will be used.
%    param.dim : dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.showfig : if true, displacement-PDF result will be plotted into a figure. 
%    default: true).
%    param.markertype : Specify marker types in generated displacement-PDF graph
%    (default: '-').
%    param.outfigurenum : Specify figure number (postive integer) for displacement-PDF
%    graph(default : 304).
%    param.saveres : if true, PDF of angular displacements(dtheta_PDF) will be output to a
%    user-specified excel file. (default:true). 
%    param.binnum : bin number between 0~180 degree to assess angular displacement occurrence profiles (default 6);
%
% output: 
%   dtheta_PDF (optional): A cell array contained PDF of angular
%   displacement at different frame lag as specified in tloi. Each cell
%   contain two column matrix and columns are orientations and probabilities. 
%   
% 
% developed  by-
%  Pei-Hsun Wu, Ph.D. 
%  Johns Hopkins University
%
%%%%%%%%%%%%%%%%%%%

% main program
% check input variable  
    if nargin==0;
        xys=get_trajfile;    
    end    
    if isempty(xys)
        xys=get_trajfile;
    end
    if nargin <=1
        tloi=[1 10 40];
    end
    if nargin <=4
        param.showfig=1;
        param.saveres=1;
        param.markertype='-';
        param.outfigurenum=304;
        param.dim=2;
        param.binnum=6; % bin number between 0~180 degree
       
    end
    
    dtheta=cell(size(tloi));
    dtheta_PDF=dtheta;
     for k=1:length(xys);  
         xy=xys{k}; 
         for kt=1:length(tloi);         
             xytemp0=xy(1:tloi(kt):end,1:param.dim);
             dxyt=xytemp0(2:end,1:param.dim)-xytemp0(1:end-1,1:param.dim);
%             [~,dr]=cart2pol(dxyt(:,1),dxyt(:,2)) ; 
            dr=sqrt(sum(dxyt(:,1:param.dim).^2,2));
        % using inner dot to compute angle, check points
                dth00=acos(sum(dxyt(2:end,1:param.dim).*dxyt(1:end-1,1:param.dim),2)./ (dr(2:end).*dr(1:end-1)));
                dth00=dth00/pi*180; % convert to degree     
            dtheta{kt}=[dtheta{kt};dth00(:)];
         end  
     end         
         
        cid=jet(length(tloi));
        outc1=[];
        for kktt=1:length(tloi)
            out1=dtheta{kktt}; 
            bino=param.binnum;
            [c1,c2]=hist(abs(out1(:)),bino);
            c1=c1/sum(c1)/(c2(2)-c2(1)); % compute the probably of occurrence     
            outc1=[outc1,c1(:)];
             if param.showfig      
                 figure(param.outfigurenum);
                 plot(c2,c1,param.markertype,'color',cid(kktt,:),'linewidth',2); hold on;         
                ylim([0 1/180*2]);
                xlim([0 180]);
                xlabel('d\theta')
                ylabel('Occurrence')
                set(gca,'xtick',[0:4]*45);
                bjff3; 
                hold on

             end
             dtheta_PDF{kktt}=[c2(:),c1(:)];
             
        end          
        saveas(gca,fullfile(path_out,[code, ' PDF-dtheta']),'png')
        hold off
%         close all
     if param.saveres
         pathname = path_out
         filename = [code, ' pdf-dtheta.xlsx']        
%          [filename, pathname] = uiputfile( ...       
%              {'*.xlsx','excel files (*.xlsx)'; ...
%                '*.xls','excel file (*.xls)'}, ...             
%               'save PDF-dtheta', 'pdf-dtheta.xlsx');                            
            xlswrite([pathname,filename],[c2(:) outc1],'dtheta_PDF','A2');
            xlswrite([pathname,filename],[tloi(:)'],'dtheta_PDF','B1');
            xlswrite([pathname,filename],{'bin'},'dtheta_PDF','A1');
            
            delete_extra_sheet(pathname,filename);
        
     end
     if nargout==0
         clear
     end

end