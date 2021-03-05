function plotXYdB(imgXY,X,Y,dBMin,xlab,ylab,titlestr,fontSize)
% PLOTXYDB     Plots a 3-D point cloud image in dB
%   PLOTXYDB(imgXY,X,Y,dBMin,xlab,ylab,titlestr,fontSize) plots the
%   image in the 2-D array imgXY along the dimensions specified in X and Y
%   where dBMin is the minimum threshold in terms of dB, xlab is the label
%   for the x-axis, ylab is the label for the y-axis, titlestr is the title
%   of the figure, and fontSize is the font size used for the axes and
%   various labels

% Organize in meshgrid format
imgYX = imgXY.';

% Normalize Image
imgYX = imgYX/max(imgYX(:));
imgYX_dB = db(imgYX);
clear imgXYZ imgZXY

% Remove voxels that are too small
imgYX_dB(imgYX_dB<dBMin) = dBMin-100;
imgYX_dB(isnan(imgYX_dB)) = dBMin-100;

% Use mesh to plot the 2-D image
mesh(X,Y,imgYX_dB,'FaceColor','interp','EdgeColor','none')
view(2)
colormap('jet')
caxis([dBMin 0])

% Set the axes and various labels
hc = colorbar;
ylabel(hc, 'dB','fontsize',fontSize)

xlabel(xlab,'fontsize',fontSize)
ylabel(ylab,'fontsize',fontSize)
xlim([X(1),X(end)])
ylim([Y(1),Y(end)])
title(titlestr,'fontsize',fontSize)