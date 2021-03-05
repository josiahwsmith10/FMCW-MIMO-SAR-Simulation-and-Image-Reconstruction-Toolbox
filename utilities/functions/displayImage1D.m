function displayImage1D(im,x_m,xlab)
% Displays the reconstructed 1-D image

h = im.fig.h;

% Organize in meshgrid format
imgY = im.imXYZ;

% Normalize Image
imgY = imgY/max(imgY(:));
imgY_dB = db(imgY);
clear imgXYZ imgZXY

plot(h,x_m,imgY_dB)
xlabel(xlab,'fontsize',im.fontSize)
ylabel('dB','fontsize',im.fontSize)
xlim(h,[im.y_m(1),im.y_m(end)])
ylim(h,[im.dBMin 0])
title("Reconstructed Image",'fontsize',im.fontSize)

end