function msd=get_MSD(xys,dt,code,path_out,param)
% Calculate MSD profiles of trajectories
% 
% Syntax:
%   get_MSD;
%   msd=get_MSD;
%   msd=get_MSD(xys);
%   msd=get_MSD(xys,dt);
%   msd=get_MSD(xys,dt,param);
% 
% input:
%   xys (optional): a N*1 cell array, Each cell contains individual cell trajectory data matrice. 
%   The format of trajectory matrice must be in the the sequence of cell id, time frame, x, y, z ;      
%   Each trajectories  must have the same time length, Nt.
%   if xys is not provided, the "get_trajfile.m" will be called to
%   select and input trajectories file. (see get_trajfile for more
%   details). 
%   dt  (optional): time step size of trajectory data,
%   if not included, input the desired value through pop-up window.  
%   param (optional) : parameters setting , if not included a default value
%   of settting will be used.
%    param.dim :dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.saveres : if true, MSDs of will be output to user-specified
%    excel file. Both individual MSDs and ensemble-averaged MSD will be saved in two different sheet where . 
%    ehe first column is time lags. (default: true).  
%    param.showfig : if true, MSD result will be plotted into a figure. 
%    default: true)
%    param.markertype : Specify marker types in generated MSD graph (default: 'bo')
%    param.outfigurenum : Specify figure number (postive integer) for MSD graph(default : 301)
% 
% 
% output: 
%   msd (optional): Mean squared displacement of trajectories, a Nt-1 * N matrix;  
%   Each column is MSD profile of individual trajectories over time lag (1:Nt-1)*dt 
% 
% developed  by-
%  Pei-Hsun Wu, Ph.D. 
%  Johns Hopkins University
%
%%%%%%%%%%%%%%%%%%%

%%%% main program

% check input variables
if nargin==0;
    xys=get_trajfile;
end
if nargin<=1; % if dt is not included in input variable, use default setting
    answer=inputdlg('Trajectory time step size','input time step size');
    dt=str2double(answer);
end

if nargin<=4; % if param is not included in the input variable, use default setting
    param.showfig=1;
    param.saveres=1;
    param.markertype='bo';
    param.outfigurenum=301;
    param.dim=2;
end

% main program
    Nc=length(xys);
    [Nt,dim]=size(xys{1}); 
    
    msd=zeros(Nt-1,Nc);   
    msdz=0;
     for k=1:Nc;  
        xy=xys{k};          
        msdx=ezmsd0(xy(:,1));
        msdy=ezmsd0(xy(:,2));     
        if dim==3
            msdz=ezmsd0(xy(:,3));
        end
        msd0=msdx+msdy+msdz; 
        msd(:,k)=msd0(:);     % output the msd        
     end
     meanMSD=mean(msd,2);
     tii=[1:length(meanMSD)]'*dt;

 %%% plot ensemble average msd
     if param.showfig
        figure(param.outfigurenum);            
            loglog(tii,meanMSD,param.markertype,'Color',param.color);
%           loglog(tii,meanMSD);

                bjff3;
                xlim([1 1e4])
                set(gca,'xtick',10.^[0:4]);
                ylim([1 1e4])
                set(gca,'ytick',10.^[0:4]);
              hold on
        xlabel('Time Lag (min)')
        ylabel('MSD (\mum^2)')
        saveas(gca,fullfile(path_out,[code, ' MSD']),'png')
        
     end
%      hold off 
%      close all
 % output the msd data to the excel file
     if param.saveres
         pathname = path_out
         filename = [code, ' MSD.xlsx']
%      [filename, pathname] = uiputfile( ...       
%          {'*.xlsx',  'excel files (*.xlsx)'; ...
%            '*.xls','excel file (*.xls)'}, ...             
%            'save MSD reuslts','MSD.xlsx');          
        
        xlswrite([pathname,filename],[tii,msd],'individual cell msd');
        xlswrite([pathname,filename],[tii,meanMSD],'average msd');
        
        delete_extra_sheet(pathname,filename)
     end
          
     if nargout==0
         clear 
     end
end