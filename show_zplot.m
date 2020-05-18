koi = 485

% y = z_array(koi, :)

c485 = readmatrix(['C:\Users\Wirtz\Desktop\For APRW\' 'xy_c485.xlsx'],'Sheet','Sheet1')
x = c485(:,1)
y = c485(:,2)
z = []
for i = 1:length(y)
%     x = [x i]
    z_color = 1 + (20-1)/length(y)*i
    z = [z z_color]
end 

% Plot data:
surf([x(:) x(:)], [y(:) y(:)], [z(:) z(:)], ...  % Reshape and replicate data
     'FaceColor', 'none', ...    % Don't bother filling faces with color
     'EdgeColor', 'interp', ...  % Use interpolated color for edges
     'LineWidth', 2);            % Make a thicker line

xlim([200 600])
% xlabel('Elapsed Time (10 min)')
% ylabel(['z-score' newline 'Displacement'])
set(gca,'xtick',[],'ytick',[])

ylim([-400 400])
bjff3;
box off
set(gca,'XColor', 'none','YColor', 'none')
view(2);   % Default 2-D view
% colorbar;  % Add a colorbar