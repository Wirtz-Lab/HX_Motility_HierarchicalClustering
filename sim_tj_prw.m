function [xyz]=sim_tj_prw(fres,tlag,N,dim)
% simulate the trajectory of correlated random motion.
% 
% 
% 

subsample=100;
dt=tlag/subsample ;

    p=fres(1);
    s=fres(2);
    epsilon=sqrt(fres(3));    
    beta=1/p;
    alpha=(s^2)*beta;
    ap=max(0,1-beta*dt);
    FR=sqrt(alpha*dt)*dt;    
    

fnum=N*subsample;
fini=fnum-1;
dr= zeros(fnum,dim);

xyz=dr;

for k=1:fnum-1
    for kd=1:dim
        dr(k+1,kd)= FR*randn(1) + ap*dr(k,kd) ;           
    end   
end

% using generated displacement to get position

for k=1:fnum
    for kd=1:dim
        xyz(k+1,kd)=xyz(k,kd)+dr(k,kd) ;    
    end
end


xyz=xyz(end-fini:subsample:end,:);
xyz=xyz-ones(size(xyz(:,1)))*xyz(1,:);

% including position noise
for kd=1:dim    
    xyz(:,kd)=xyz(:,kd) + randn(size(xyz(:,kd)))*epsilon;
end
    

% rotate the trajectory randomly
% random rotate the 3D coordintes
if dim==3
    theta=rand(1)*2*pi;
    Rx=[1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];

    theta=rand(1)*2*pi;    
    Ry=[cos(theta) 0 sin(theta); 0 1 0; -sin(theta) 0 cos(theta)];

    theta=rand(1)*2*pi;
    Rz=[cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0 ;0 0 1];

    Rm=Rz*Ry*Rx;
    xyz=xyz*Rm; % rotate xyz; 

elseif dim==2
    theta=rand(1)*2*pi;
    % theta=0; % not rotate.
    Rm=[cos(theta),-sin(theta); sin(theta),cos(theta)];
    xyz=xyz*Rm ;% random rotate the trajectoriy
end

  
end
    