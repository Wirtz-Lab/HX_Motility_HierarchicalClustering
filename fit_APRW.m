function [outp]=fit_APRW(xys,dt,tlag,code,path_out,param)
% Analysis of trajectory using APRW model  
% trajectories --> MSDs --> APRW model fitting 
% 
% Syntax:
%   fit_APRW;
%   outp=fit_APRW;
%   outp=fit_APRW(xys);
%   outp=fit_APRW(xys,dt);
%   outp=fit_APRW(xys,dt,tlag);
%   outp=fit_APRW(xys,dt,tlag,param);
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
%   tlag (optional) : frame lag to calculate displacements which will be
%   used to identify the primary migration direction through SVD
%   analysis.If not included, a default value of 1 will be used.
%   param (optional) : parameters setting , if not included a default value
%   of settting will be used.f
%    param.dim :dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.saveres : if true, fitted parameters matrix will be output to user-specified
%    excel file. Columns of fitted parameters matrix are P,S, positioning
%    error, R-squared, RMSE. (default: true). Fitting results at  primary migration
%    direction (p) and non-primary migration direction (np) will be
%    output to separate excel sheets.
%    param.showfig : if true, MSD result will be plotted into a figure. 
%    default: true)
%    param.outfigurenum : Specify figure number (postive integer) for MSD graph(default : 311)
% 
% 
% output: 
%   outp (optional): Parameter matrix from PRW model fitting. Columns are
%   P,S, positioning error, R-squared, RMSE for primary migration
%   direction and non-primary migration direction saperately
%   Each row is fitting results from individual trajectories.
% 
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
    if isempty(xys)
         xys=get_trajfile;
    end
    if nargin<=1;
        answer=inputdlg('Trajectory time step size','input time step size');
        dt=str2double(answer);

    end
    if nargin<=2;
        tlag=1;
    end
    if nargin<=5;
        param.showfig=1;
        param.saveres=1;
        param.dim=2;
        param.outfigurenum=311;
    end
     outp=zeros(length(xys),10); 
     dim=param.dim;
     parfor k=1:length(xys);  
            xy=xys{k}; 
            xy=xy(:,1:dim);            
            dxy=xy(1+tlag:end,:)-xy(1:end-tlag,:) ;   
            % identify the major axis of trajectories
            xyr=xy-ones(size(xy(:,1)))*mean(xy);             
            [~,~,rm]=svd(dxy);      % obtain the rotational matrix  
            xyr=xyr*rm; % rotate the x-y            

               msdp1=ezmsd0(xyr(:,1));
               msdnp1=ezmsd0(xyr(:,2));
               if dim==3
                   msdnp1=msdnp1+ezmsd0(xyr(:,2));
               end
               [p,s,se,gof]=msd2pse0(msdp1,dt,1);  % fit msd using PRW\
               [p2,s2,se2,gof2]=msd2pse0(msdnp1,dt,dim-1);  % fit msd using PRW\
               outpi=[[p,s,se,gof.rsquare,gof.rmse],[p2,s2,se2,gof2.rsquare,gof2.rmse]];    
                outp(k,:)=outpi;            
     end     

    if param.showfig; % show fitting resultt;        
         figure(param.outfigurenum);        
        for k=1:param.dim;               
            [count,bin]=hist(outp(:,(k-1)*5+4),linspace(0,1.05,20));
            subplot(param.dim,1,k)
            bar(bin,count/sum(count),'b');
        end
        % show histogram of aprw model fitting
    end
    saveas(gca,fullfile(path_out,[code, ' APRW model fit']),'png')
    close all
    if param.saveres % save the fitted results;
         pathname = path_out
         filename = [code, ' APRW model fit.xlsx']
%         [filename, pathname] = uiputfile( ...       
%          {'*.xlsx',  'excel files (*.xlsx)'; ...
%            '*.xls','excel file (*.xls)'}, ...             
%            'save model fitting reuslts','APRW model fit.xlsx');               
       test=dir([pathname,filename]);
       if ~isempty(test) % delete exisiting excel file
           delete([pathname,filename]);
       end       
        xlswrite([pathname,filename],outp(:,1:5),'APRW fitting-p');
        xlswrite([pathname,filename],outp(:,6:10),'APRW fitting-np');
        
        delete_extra_sheet(pathname,filename)
    end
    
    if nargout==0
        clear
    end
end
    