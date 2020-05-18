function [outp]=fit_PRW(xys,dt,code,path_out,param)
% Analysis of trajectories using PRW model. 
% trajectories --> MSDs --> PRW model fitting --> Persistent time(P), Speed(S),
% positioning noise.
% 
% Syntax:
%   fit_PRW;
%   outp=fit_PRW;
%   outp=fit_PRW(xys);
%   outp=fit_PRW(xys,dt);
%   outp=fit_PRW(xys,dt,param);
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
%   of settting will be used.f
%    param.dim :dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.saveres : if true, fitted parameters matrix will be output to user-specified
%    excel file. Columns of fitted parameters matrix are P,S, positioning error, R-squared, RMSE. (default: true).  
%    param.showfig : if true, MSD result will be plotted into a figure. 
%    default: true)
%    param.outfigurenum : Specify figure number (postive integer) for MSD graph(default : 310)
% 
% 
% output: 
%   outp (optional): Parameter matrix from PRW model fitting. Columns are P,S, positioning error, R-squared, RMSE.
%                    Each row is fitting results from individual
%                    trajectories.
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
%         dt=1; 
    end    
    if nargin<=4;
        param.showfig=1;
        param.saveres=1;
        param.dim=2;
        param.outfigurenum=310;
    end
     outp=zeros(length(xys),5);      
     dim=param.dim;
     parfor k=1:length(xys);  
            xy=xys{k};                         
            msd=ezmsd0(xy(:,1:dim)); % get msd            
            [p0,s0,se0,gof0]=msd2pse0(msd,dt,dim);                             
            outp(k,:)=[p0,s0,se0,gof0.rsquare, gof0.rmse];            
     end     
    if param.showfig; % show historgram of fitting R-squared value;
        figure(param.outfigurenum);
        [count,bin]=hist([outp(:,4)],linspace(0,1.05,20));
        bar(bin,count/sum(count),'b')
        % show histogram of aprw model fitting
    end
        saveas(gca,fullfile(path_out,[code, ' PRW model fit']),'png')
        close all
    if param.saveres % save the fitted results;
        pathname = path_out
        filename = [code, ' PRW model fit.xlsx']
%         [filename, pathname] = uiputfile( ...       
%          {'*.xlsx',  'excel files (*.xlsx)'; ...
%            '*.xls','excel file (*.xls)'}, ...             
%             'save model fitting reuslt','PRW model fit.xlsx');   
        
       test=dir([pathname,filename]);
       if ~isempty(test) % delete exisiting excel file
           delete([pathname,filename]);
       end    
       
        xlswrite([pathname,filename],outp(:,1:5),'PRW fitting');   
        delete_extra_sheet(pathname,filename);
    end    
    if nargout==0
        clear
    end
end
    