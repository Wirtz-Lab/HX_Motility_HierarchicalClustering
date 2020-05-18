function [dR_of_theta]=get_dR_polarity(xys,tlag,code,path_out,param)
% calculate displacement (dR) at different orientation relative to primary
% migration orientation
% 
% Syntax:
%   get_dR_polarity;
%   [dR_of_theta]=get_dR_polarity;
%   [dR_of_theta]=get_dR_polarity(xys);
%   [dR_of_theta]=get_dR_polarity(xys,tlag);
%   [dR_of_theta]=get_dR_polarity(xys,tlag,param);
% 
% input:
%   xys (optional): a N*1 cell array, Each cell contains individual cell trajectory data matrice. 
%   The format of trajectory matrice must be in the the sequence of cell id, time frame, x, y, z ;      
%   Each trajectories  must have the same time length, Nt.
%   if xys is not provided, the "get_trajfile.m" will be called to
%   select and input trajectories file. (see get_trajfile for more
%   details). 
%   tlag  (optional): frame lag for calculate displacements; 
%   if not included a default value of 1 will be used. 
%   param (optional) : parameters setting. if not included, default values of setting will be used.
%    param.dim : dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.showfig : if true, displacement-PDF result will be plotted into a figure. 
%    default: true).
%    param.markertype : Specify marker types in generated displacement-PDF graph
%    (default: 'bo').
%    param.outfigurenum : Specify figure number (postive integer) for displacement-PDF
%    graph(default : 305).
%    param.saveres : if true, displacements at differnet orienation 
%    relative to primary migration direction (dR_of_theta) will be output to a
%    user-specified excel file. (default:true). 
%    param.binnum : number of grades in angles for evaluate displacement polarity profile (default 25);
%
% output: 
%   dR_of_theta (optional): displacements at differnet orienation 
%    relative to primary migration direction. A param.binnum by 2 matrix
%    where the colunms are orientations (relative to primary migration direction ) 
%    and their corresponding displacements.
%   
%   
% 
% developed  by-
%  Pei-Hsun Wu, Ph.D. 
%  Johns Hopkins University
%
%%%%%%%%%%%%%%%%%%%

% main program
% check input variable% 

    if nargin==0;
        xys=get_trajfile;    
    end
    if isempty(xys)
        xys=get_trajfile;
    end
    if nargin <=1;
        tlag=1;
    end
    if nargin <=4 % set the bin size        
        param.showfig=1;
        param.saveres=1;
        param.markertype='bo';
        param.dim=2;
        param.outfigurenum=305;
        param.binnum=25;

    end
     
     dR=[]; theta=[];
     for k=1:length(xys);  
            xy=xys{k};             
            dxy=xy(1+tlag:end,1:param.dim)-xy(1:end-tlag,1:param.dim) ;   
            % identify the major axis of trajectories
            xyr=[xy(:,1)-mean(xy(:,1)),xy(:,2)-mean(xy(:,2))];  
            if param.dim==3
                xyr=[xyr, xy(:,3)-mean(xy(:,3))];
            end
            
            % singular value decomposition to identify the major migration
            % orientation.
            [~,~,rm]=svd(dxy(:,1:param.dim));      % obtain the rotational matrix  
%             [~,~,rm]=svd([xyr(:,1),xyr(:,2)]);      % obtain the rotational matrix  
            dxyr=dxy(:,1:param.dim)*rm;   % rotate the vector
         
            % only quantify the first two axis
            [thr,~]=cart2pol(dxyr(:,1),dxyr(:,2)) ;
            thr=thr/pi*180;
            thr(thr<0)=thr(thr<0)+360; 
            
            xyr=xyr*rm;            
            dR=[dR; dxyr];                     
            theta=[theta,thr(:)] ;    
     end     

        [ang,rho]=cart2pol(dR(:,1),dR(:,2));
        [angpoint]=linspace(-pi,pi,param.binnum);        
        angstep=angpoint(2:end)/2+angpoint(1:end-1)/2; 
        dR_of_theta=zeros(length(angstep),2);
        % calculate the dR at differnet orientation
        for kaa=1:length(angpoint)-1
            cc=ang >= angpoint(kaa) & ang < angpoint(kaa+1);
            dR_of_theta(kaa,:)=[angstep(kaa),mean(rho(cc))];
        end
        % normalize dR 
        axx=dR_of_theta(:,2).*cos(dR_of_theta(:,1))/mean(dR_of_theta(:,2));
        ayy=dR_of_theta(:,2).*sin(dR_of_theta(:,1))/mean(dR_of_theta(:,2));        
        
        aid0=[1:length(axx) 1];
        
     if param.showfig
        figure(param.outfigurenum);
        plot(axx(aid0),ayy(aid0),param.markertype,'Color',param.color); bjff3;
        axis equal ;
        xlim([-3 3]);
        ylim([-3 3]);
        axis off
        hold on;
        
        % plot the grade for polar plot
          ang00=linspace(0.00,2*pi,30000);          
            plot(3*cos(ang00),3*sin(ang00),'k-','linewidth',1);  
            plot(2*cos(ang00),2*sin(ang00),'k:','linewidth',1);
            plot(1*cos(ang00),1*sin(ang00),'k:','linewidth',1);
%             plot(0.5*cos(ang00),0.5*sin(ang00),'k:','linewidth',1);
            for ag00=[(0:90:270)]/180*pi;                
                
               plot([0 3*cos(ag00)],[0 3*sin(ag00)],'k:',...
                    'linewidth',1);                
               h00={'right','left'};
               a00={'top','bottom'};
               hss=round(sign(cos(ag00))/2+1.5);
               ass=round(sign(sin(ag00))/2+1.5);
               
                text(3.2*cos(ag00), 3.2*sin(ag00),...
                    num2str(ag00*180/pi),...
                    'fontsize',12,...
                    'horizontalalignment',h00{hss},...
                    'verticalalignment',a00{ass});
            end
                            
            axis equal;
            axis off
%             hold off;
     end
     saveas(gca,fullfile(path_out,[code, ' dr_theta']),'png')
     close all
     
        if param.saveres
         pathname = path_out
         filename = [code, ' dR_of_theta.xlsx']
%          [filename, pathname] = uiputfile( ...       
%              {'*.xlsx',  'excel files (*.xlsx)'; ...
%                '*.xls','excel file (*.xls)'}, ...             
%              'output dR(theta) data', 'dr_theta.xlsx');                       
            xlswrite([pathname,filename],dR_of_theta,'dR_of_theta');
            delete_extra_sheet(pathname,filename);
        end
        if nargout==0
            clear
        end
         
end