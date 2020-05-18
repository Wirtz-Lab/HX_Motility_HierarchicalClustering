function rsq=get_rsq(ye,yf,W)

if nargin<=2;
    W=1;
end
% calculate r-squared value
sstot=sum((ye-mean(ye)).^2);
% ssreg=sum((yf-mean(ye)).^2);
ssres=sum((ye-yf).^2);

% rsq=ssres/sstot;
% rsq = sqrt(mean((ye-yf).^2));  % root mean square error
% rsq = mean(abs((ye-yf)./mean(ye)));  % relative error 
rsq=1-ssres/sstot; % rsquare value
