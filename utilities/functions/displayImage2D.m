function displayImage2D(im,x_m,y_m,xlab,ylab)
% Displays the reconstructed 2-D image
%
% See also PLOTXYDB.

h = im.fig.h;

% Organize in meshgrid format
imgYX = im.imXYZ.';

% Normalize Image
imgYX = imgYX/max(imgYX(:));
imgYX_dB = db(imgYX);
clear imgXYZ imgZXY

mesh(h,x_m,y_m,imgYX_dB,'FaceColor','interp','EdgeColor','none')

colormap('jet')
hc = colorbar;

view(h,2)
caxis(h,[im.dBMin 0])

ylabel(hc, 'dB','fontsize',im.fontSize)
xlabel(xlab,'fontsize',im.fontSize)
ylabel(ylab,'fontsize',im.fontSize)
xlim(h,[x_m(1),x_m(end)])
ylim(h,[y_m(1),y_m(end)])
title("Reconstructed Image",'fontsize',im.fontSize)
end