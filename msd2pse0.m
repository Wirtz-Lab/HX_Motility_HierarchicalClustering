function [P,S,SE,gof]=msd2pse0(msd,dt,dim)
%******************************************************
% Characterizing the msd by persistent Random walk model.
% output: persistence, speed, and positioning error, goodness of fit.
% input: msd (unit length)
%        dt ( time step (time/frame))
%*******************************************************
% written by : 
%               Pei-Hsun Wu,   PhD
%               Department of Chemical and biomolecular Engineering
%               Johns Hopkins University
% 
% Last update:  Mar, 22, 2012
%               
%*****************************************************
if nargin==1
    dt=1;
    
end
dispfres=0;
    mout=msd;
    toi=1:round(length(mout)/3);
    ti=(1:length(mout(:,1))) ;
    ti0=ti;
    ti0=ti0*dt;
    ti=ti(:);
    ti=ti(toi);

    Nt=length(ti);
    wif=(2*ti.^2+1)/3./ti./(Nt-ti+1) ;    % resolution of MSD at different time lag
    ti=ti.* dt; % convert to real unit

    s = fitoptions('Method','NonlinearLeastSquares',...
                   'Lower',[0 0 0],...
                   'Upper',[1000 20 100],...
                   'Startpoint',[10 1 1]);
               
    f=fittype([num2str(dim),'*S^2*P*(x-P*(1-exp(-x/P)))+',num2str(2*dim),'*se'],'options',s);    
    
        MSD=mout(toi);
        wt=1./wif.^2./ MSD ; 
        [c2,gof]=fit(ti,MSD,f,'weight',wt) ;            
        yfit=c2(ti);

% display fitting result 
        if dispfres==1
            figure(999);
            loglog(ti,MSD,'b.',ti,yfit,'r-','linewidth',2); bjff3
            hold on;
            loglog(ti0,mout,'b.',ti0,c2(ti0),'r-','linewidth',2); bjff3
            hold off;
        end
        
    P=c2.P;
    S=c2.S;
    SE=c2.se;
