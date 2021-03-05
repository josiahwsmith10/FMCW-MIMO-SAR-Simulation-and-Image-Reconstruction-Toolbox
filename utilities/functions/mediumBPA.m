% Copyright (C) 2021 Josiah W. Smith
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

function mediumBPA(obj,k)
% Attempts to compute the Backprojection Algorithm by iterating over the
% wavenumber and target voxel domains. Usually takes an excessive amount of
% time to compute

obj.imXYZ = single(zeros(1,size(obj.target_xyz_m,1)));
tocs = single(zeros(1,2^14));
count = 0;
for indTarget = 1:size(obj.target_xyz_m,1)
    for indK = 1:length(k)
        tic
        count = count + 1;
        
        if ~obj.ant.isEPC
            Rt = pdist2(obj.tx_xyz_m,obj.target_xyz_m(indTarget,:));
            Rr = pdist2(obj.rx_xyz_m,obj.target_xyz_m(indTarget,:));
            amplitudeFactor = Rt .* Rr;
            R_T_plus_R_R = Rt + Rr;
        else
            R = pdist2(obj.vx_xyz_m,obj.target_xyz_m(indTarget,:));
            R_T_plus_R_R = 2*R;
            amplitudeFactor = R.^2;
        end
        
        if obj.isGPU
            R_T_plus_R_R = gpuArray(R_T_plus_R_R);
        end
        
        bpaKernel = gather(exp(-1j*k(indK)*R_T_plus_R_R));
        if obj.isAmplitudeFactor
            bpaKernel = bpaKernel .* amplitudeFactor;
        end
        obj.imXYZ(indTarget) = obj.imXYZ(indTarget) + sum(obj.sarData(:,:,indK) .* bpaKernel,1);
        % Update the progress dialog
        tocs(mod(count,length(tocs))+1) = toc;
        disp("Iteration " + count + "/" + length(k)*size(obj.target_xyz_m,1) + ". Estimated Time Remaining: " + getEstTime(obj,tocs,indK,length(k)*size(obj.target_xyz_m,1)));
    end
end
end

function outstr = getEstTime(obj,tocs,currentInd,totalInd)
% Estimates the time remaining given the recent time-per-iteration values.
% Returns a string containing the number of hours, number of minutes, and
% number of seconds remaining, each separated by a ":"

avgtoc = mean(tocs(tocs~=0))*(totalInd - currentInd);

if avgtoc > obj.estTime.old && obj.estTime.count < 100
    obj.estTime.count = obj.estTime.count + 1;
    avgtoc = obj.estTime.old;
else
    obj.estTime.count = 0;
    obj.estTime.old = avgtoc;
end

hrrem = floor(avgtoc/3600);
avgtoc = avgtoc - floor(avgtoc/3600)*3600;
minrem = floor(avgtoc/60);
avgtoc = avgtoc - floor(avgtoc/60)*60;
secrem = round(avgtoc);

if hrrem < 10
    hrrem = "0" + hrrem;
end
if minrem < 10
    minrem = "0" + minrem;
end
if secrem < 10
    secrem = "0" + secrem;
end
outstr = hrrem + ":" + minrem + ":" + secrem;
end