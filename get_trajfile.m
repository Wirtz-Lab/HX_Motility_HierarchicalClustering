function [xys]=get_trajfile(xlsfile)
% load cell trajectory from a excel file or a .mat file 
% 
% input:
%   xlsfile : filename or filepath to trajectory data file.
%   Trajectory data in this file must be a matrice in which  
%   columns are cell id, time id, x,y,(z) sequentially. Position in z-dir
%   is optional. 
% 
%   Example:
% 
%    cell ID,    t,    x,      y,
%       1        1       0.5    0.5
%       1        2       0.3    0.5
%       2        1       20.1   19.1
%       2        2       21.1   19.5 
%       .        .        .      .
%       .        .        .      .
%       .        .        .      .
% 
% output: 
%   xys : A Nc*1 cell array, where Nc is number of trajectoires 
%   Each cell contains individual cell trajectory data matrice.
%   The format of trajectory matrice is in the the sequence of cell id, time frame, x, y, z ;      
%   All trajectories have the same time length, Nt, which is determined by 
%   minimum time length among all trajectories data.  
% 
% developed  by-
%  Pei-Hsun Wu, Ph.D. 
%  Johns Hopkins University
%
%
%%%%%%%%%%

% check input variables
if nargin==0
    [filename, pathname] = uigetfile( ...
    {'*.xlsx;*.xls;*.mat','trajectory Files (*.xlsx,*.xls,*.mat,)';
       '*.xlsx',  'excel files (*.xlsx)'; ...
       '*.xls','excel file (*.xls)'; ...
       '*.mat','MAT-files (*.mat)'; ...  
       '*.*',  'All Files (*.*)'}, ...
       'select cell trajectory file');
     xlsfile=[pathname,filename];
else
    k=strfind(xlsfile,'\');
    filename=xlsfile(k+1:end); % update filename     
end

% read trajectory data from file 
if ~isempty(strfind(filename,'.xlsx')) || ~isempty(strfind(filename,'.xls'));
    [num,~,~]=xlsread(xlsfile); 
elseif ~isempty(strfind(filename,'.mat')) ;
    num=importdata(xlsfile);
else
    ss=sprintf('\n incorrect file format !! \n'); % output error message if the data is not 
    errordlg(ss);
end

% identify number of trakced cell 
ui=unique(num(:,1));
tlength=zeros(size(ui));
xys=cell(size(ui));

% check the trajectories length
for k=1:length(ui)
    col=num(:,1)==ui(k);
    tlength(k)=sum(col); % length of trajectories
end
Nmin=min(tlength); % obtain the minimun trajectory length among all samples

%  place individual trajectoreis into cell array, with length of
%  trajectories equal to the minimum of the dataset
 for k = 1:length(ui);     
    col=num(:,1)==ui(k);    
    xytemp=num(col,1:end);
    % sort for time
    [~,sid]=sort(xytemp(:,2),'ascend'); % ensure the time elapse in right order
    xytemp=xytemp(sid,3:end); % only obtain the trajectory locations.
    xytemp=xytemp(1:Nmin,:); % only collect the minimum time frame length
    xys{k}=xytemp ;   % trajectories of cells.  
 end
 
 
