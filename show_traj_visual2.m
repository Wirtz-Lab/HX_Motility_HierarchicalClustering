function show_traj_visual2(xys,code,path_out,param)
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
%     NC=min(Nc,25);
    si=randperm(Nc);
    xys=xys(si); % permutated.
    % set up grid display
    dxx=200; % distance in x, or y between two adjcent trajectory;
    xgridnumber=4;
    ygridnumber=4;
    [gx,gy]=meshgrid([1:xgridnumber]*dxx,[1:ygridnumber]*dxx);    
    
    %cidk=jet(length(gx(:))); % generate different colors for different trajectoreis. 
    
      for k=1:1:length(gx(:));  
         xy=xys{k};             
         xy=[xy(:,1)-mean(xy(:,1))+gx(k), xy(:,2)-mean(xy(:,2 ))+gy(k)];           
         
         plot(xy(:,1),xy(:,2), 'Color',param.color,'linewidth',1.5); hold on; 
         
%          plot(xy(:,1),xy(:,2),'-','color',cidk(k,:),'linewidth',1.5); hold on;     
      end
      hold off;
%       axis equal;
      xlim([0 1000])
      ylim([0 1000])
      pbaspect([1 1 1])
      set(gca,'xtick',[],'ytick',[]);
      saveas(gca,fullfile(path_out,[code, ' traj_v2']),'png')
      
%       close all
      