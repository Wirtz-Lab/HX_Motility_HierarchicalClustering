function [simxy]=sim_PRW(outp,dt,param)
% Simulated PRW trajectories from P,S, positioning error parameters.
% 
% Syntax:
%   sim_PRW;
%   simxy=sim_PRW;
%   simxy=sim_PRW(outp);
%   simxy=sim_PRW(outp,dt);
%   simxy=sim_PRW(outp,dt,param);
% 
% input:
%   outp (optional): PRW Parameter matrix. Columns are P,S, positioning
%   error and rows are differnet PRW parameter sets which will be used to
%   simulate trajectories.
%   if not outp is not provided, select a excel file that is output from fit_APRW.m through pop-up windows.  
%   dt  (optional): time step size of trajectory data,
%   if not included, input the desired value through pop-up window. 
%   param (optional) : parameters setting , if not included a default value
%   of settting will be used.f
%    param.dim :dimensionality of trajectories (either 2 or 3) (default: 2);
%    param.saveres : if true, data matrix of simulated trajectories will be output to user-specified
%    excel file. Columns are cell id, time frame, x, y , (z).
%    param.showfig : if true, simulated trajectories will be plotted into a figure. 
%    default: true)
%    param.outfigurenum : Specify figure number (postive integer) for MSD graph(default : 310)
%    param.Nmax: total time steps in simulated trajectory  (default :500) ;
%    param.repeat:  number of simulation repeats.  (default: 20)

% output: 
%   simxy (optional): simulated trajectories in a cell array. 
%   Each cell contains individual cell trajectory data matrix.
%   The column of trajectory matrix is cell id, time frame, x, y, z ;      
% 
% cl
% developed  by-
%  Pei-Hsun Wu, Ph.D. 
%  Johns Hopkins University
%
%%%%%%%%%%%%%%%%%%%

%%%% main program

% check input variables

   if nargin==0;
        [filename, pathname] = uigetfile( ...
          {'*.xlsx;*.xls;*.mat','fitting parameter files (*.xlsx,*.xls,*.mat,)';
       '*.xlsx',  'excel files (*.xlsx)'; ...
       '*.xls','excel file (*.xls)'; ...
       '*.mat','MAT-files (*.mat)'; ...  
       '*.*',  'All Files (*.*)'}, ...
       'select PRW model fitted parameters');
     xlsfile=[pathname,filename];
     [outp,~,~]=xlsread(xlsfile);
    end
    
    if nargin<=1;
        answer=inputdlg('time step size','input time step size');
        dt=str2double(answer);
    end    
    if nargin<=2;
        param.showfig=1;
        param.saveres=1;
        param.Nmax=500;        
        param.dim=2;
        param.repeat=20;
    end                
    xys00=[];
    simxy={};
    Nmax=param.Nmax;
    dim=param.dim;
    ss=ceil(log10(param.repeat));
    ss=10^ss;
    for k=1:length(outp(:,1))     
         P=outp(k,1);
         S=outp(k,2);
         SE=outp(k,3);            
         parfor repeat=1:param.repeat;                                                                        
                [xyss0]=sim_tj_prw([P,S,SE],dt,Nmax,dim);
                xyss0=[ones(size(xyss0(:,1)))*k*ss+repeat [1:length(xyss0(:,1))]' xyss0];
                xys00 =[xys00;xyss0]; % for output to excel
                simxy = [simxy; {xyss0}]; % for output variable
         end          
    end
     
    if param.showfig; % show fitting resultt;
       
    end
    
    if param.saveres % save the fitted results;
        [filename, pathname] = uiputfile( ...       
         {'*.xlsx',  'excel files (*.xlsx)'; ...
           '*.xls','excel file (*.xls)'}, ...             
           'save simulated trajectory data','sim_traj_PRW.xlsx');               
        xlswrite([pathname,filename],xys00,'sim_traj_PRW');                 
        delete_extra_sheet(pathname,filename);
 
    end    
    if nargout==0
        clear
    end
end
    