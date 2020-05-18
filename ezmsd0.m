function [msd]=ezmsd0(xyz)
%******************************************************
% calculate the 2d-MSD with input trajectory in x and y respectively.
% 
% 
%*******************************************************
% written by : 
%               Pei-Hsun Wu
%               PhD student
%               Department of Chemical Engineering
%               the University of Florida
% 
% Last update:  Feb 06, 2009
%               
%******************************************************
% easy calculat out the msd with input x,y trajectory in the unit of length(nm)
% x position as first column, y position as 2nd column of tp

[fn,~]=size(xyz); % frame number of analysis    
    msdr=zeros(fn-1,1);
    for dt= 1 : (fn-1) % loop through differnet time-lag            
            dxyz=xyz(1+dt:end,:)-xyz(1:end-dt,:);
            msdr(dt)=mean(sum(dxyz.^2,2));            
    end
msd=msdr(:);

