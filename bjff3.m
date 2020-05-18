%******************************************************
% set properties for axe and figure as for BJ use
% 
%*******************************************************
% written by : 
%               Pei-Hsun Wu
%               PhD student
%               Department of Chemical Engineering
%               the University of Florida
% 
% Last update:  Mar 2, 2009 ( finish main program)
%               Aug 2, 2011 - auto set line-width to 2pt. 
%******************************************************
function bjff3

lfs=20; % xylabel fontsize (14)
l=0.22;%0.25; % axe start pos  ition from left (0~1)
b=0.22;%0.425; % axe start position from bottom (0~1)
af=0.2; % margin from right 5
ab=0.1; % margin from top
k=96/96;
dpi=96*k; % digit per inch (96|72)
fwidth=4.58; %inches (3.25)
fheight=fwidth/1.33; %inches (2.75)
strx=''; % string for x label
stry=''; % string for y label
axefs=18*k; % font size of tick label (12)

hxl=get(gca,'xlabel');
hyl=get(gca,'ylabel');
%  ylabel('\fontsize{24}MSD\fontsize{18}_{33msec}\fontsize{24} (\mum\fontsize{18}^2\fontsize{24})')
%  ylabel('\fontsize{24}MSD (\mum\fontsize{18}^2\fontsize{24})')
box off
grid off

set(hyl,'fontweight','bold','fontsize',lfs);
set(hxl,'fontweight','bold','fontsize',lfs);

set(gca,'linewidth',2,'fontweight','normal','fontsize',axefs);
set(gca,'ticklength',[0.03/1 0.025/1]);
set(gca,'position',[l b 1-af-l 1-ab-b]);

set(gcf,'position',[100 100 fwidth*dpi fheight*dpi]);
set(gcf,'color',[1 1 1]);
set(gca,'tickdir','in');
set(gca,'xminortick','off');
set(gca,'yminortick','off');
grid
grid off

h=get(gca,'children');
if 1
for k=1:length(h);
    tt=get(h(k));
    if isequal(tt.Type,'image')~=1;
        set(h(k),'linewidth',2);
    end
end
end
box;

% dpi in my screen is 96; if direct copy the screen size figure; then only
% thing we can control is figure size in pixel.