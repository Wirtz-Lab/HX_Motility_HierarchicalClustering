% This is a driver function for Nature PRW and APRW motility model
% Author: HX
% Date edited: 14 Apr 2020

clear,clc

%Put your input path here, files should be in .xlsx format
path_in = 'C:\Users\Wirtz\Desktop\BMM_Manual_Tracking\2020.04.14. BMDM Motility Analysis For APRW\ByCondition\'
files = dir([path_in, '\*.xlsx']);

%Put your output path here
path_out = 'C:\Users\Wirtz\Desktop\test_pathout\'


%The following section defines motility calculation parameters
dt = 10; % minutes
tlag0 = 1; % this is used in get_voft and get_dis
tlag = 6;
tloi = [1, 10, 40];

M0_code = ['xy076','xy080','xy120','xy116','M0___'];
M1_code = ['xy092','xy104','xy096','M1___'];
M2_code = ['xy088','xy108','xy112','M2___'];
KPC1_code = ['xy017','xy029','xy065','KPC1_'];
KPC2_code = ['xy021','xy072','xy025','KPC2_'];

param.showfig=1;
param.saveres=1;
param.markertype = 'o'
param.outfigurenum=301;
param.dim=2;
param.tlag=1;
param.dxmax=50;
param.binn=70;          
param.binnum=25;
param.repN=10;


% The following section assign calculation orders
filenames = {files(:).name}.';
for file = length(files):-1:1
    name_i = files(file).name;
    name_str = name_i(1:5)

    % The following section assign specific color for different conditions
    if contains(M0_code,name_str)
        param.color = [0.9290 0.6940 0.1250]
    elseif contains(M1_code,name_str)
        param.color = [0.8500 0.3250 0.0980]
    elseif contains(M2_code,name_str)
        param.color = [0.4660 0.6740 0.1880]
    elseif contains(KPC1_code,name_str)
        param.color = [0.3010 0.7450 0.9330]
    elseif contains(KPC2_code,name_str)
        param.color = [0 0.4470 0.7410]
    else
        param.color = 'k'
    end 
    
    % xys must be run for all subsquent computations
    xys = get_trajfile([path_in,name_i]);
    
%     get_dis(xys,tlag0,name_str);
%     get_voft(xys,tlag0,name_str,path_out,param);
%     msd=get_MSD(xys,dt,name_str,path_out,param);
%     acf=get_ACF(xys,dt,name_str,path_out,param);
%     get_dR_PDF(xys,tlag,name_str,path_out,param);
%     get_dtheta_PDF(xys,tloi,name_str,path_out);
%     get_dR_polarity(xys,tlag,name_str,path_out,param)
%     fit_PRW(xys,dt,name_str,path_out)
%     fit_APRW(xys,dt,tlag,name_str,path_out)
%     show_traj(xys,name_str,path_out,param)
    show_traj_visual2(xys,name_str,path_out,param)
%     break %after one loop


end 

    


