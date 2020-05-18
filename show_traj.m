function show_traj(xys,code,path_out,param)
%% 1. Plot all trajectoreis 
    if nargin==0
         xys=get_trajfile;
    end
    if nargin<=3;
        param.outfigurenum=1;
        param.repN=10;
    end    

    figure(param.outfigurenum) ; 
    Nc=length(xys); % number of cell trajectories        
    cidk=jet(Nc); % generate different colors for different trajectoreis. 
      for k=1:param.repN:Nc;  
         xy=xys{k};             
         xy=[xy(:,1)-xy(1,1), xy(:,2)-xy(1,2)];           
         plot(xy(:,1),xy(:,2),'-','color',cidk(k,:),'linewidth',1.5); hold on;    

      end
     hold off;
      axis equal;
      xlim([-200 200])
      ylim([-200 200])
      pbaspect([1 1 1])
      set(gca,'xtick',[],'ytick',[]);
      saveas(gca,fullfile(path_out,[code, ' traj']),'png')
      close all