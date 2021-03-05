classdef nonuniform_theta_CSAR_XZ_BPA_app < handle
    % nonuniform_theta_CSAR_XZ_BPA_app see nonuniform_theta_CSAR_XZ_BPA
    % documentation
    properties
        sarData             % Computed beat signal
        
        tx_xyz_m            % x-y-z coordinates of the transmitter antennas in the synthetic aperture
        rx_xyz_m            % x-y-z coordinates of the receiver antennas in the synthetic aperture
        vx_xyz_m            % x-y-z coordinates of the virtual elements in the synthetic aperture
        target_xyz_m        % x-y-z coordinates of the voxels in the target domain, as specified by the user
        sizeTarget          % Dimensions of the desired target, as specified by the user
        
        imXYZ               % Reconstructed image
        
        isGPU               % Boolean whether or not to use the GPU for image reconstruction
        isAmplitudeFactor   % Boolean whether or not to include the amplitude factor in the image reconstruction process
        isFail = false      % Boolean whether or not the reconstruction has failed
        isMIMO              % Boolean whether or not to use the MIMO physical element locations instead of the equivalent phase center virtual element locations
        
        k_vec               % Instantaneous wavenumber vector
        
        estTime             % Structure for holding the estimated time until completion parameters
    end
    
    methods
        function obj = nonuniform_theta_CSAR_XZ_BPA_app(app,im)
            obj = update(obj,app,im);
            obj.estTime.old = inf;
            obj.estTime.count = 0;
        end
        
        function obj = update(obj,app,im)
            % Update the reconstruction algorithm by getting the parameters
            % from the object handles and verifying the paramters
            
            obj = getParameters(obj,app,im);
            obj = verifyReconstruction(obj,app);
        end
        
        function obj = getParameters(obj,app,im)
            obj.tx_xyz_m = app.sar.tx.xyz_m;
            obj.rx_xyz_m = app.sar.rx.xyz_m;
            obj.vx_xyz_m = app.sar.vx.xyz_m;
            
            [X,Y,Z] = ndgrid(im.x_m(:),0,im.z_m(:));
            obj.sizeTarget = [im.numX,im.numZ];
            
            obj.target_xyz_m = [X(:),Y(:),Z(:)];
            
            obj.sarData = reshape(app.target.sarData,[],app.fmcw.ADCSamples);
            
            obj.isGPU = im.isGPU;
            obj.isAmplitudeFactor = app.target.isAmplitudeFactor;
            obj.isMIMO = app.sar.isMIMO;
            
            obj.k_vec = app.fmcw.k;
        end
        
        function obj = verifyReconstruction(obj,app)
            obj.isFail = false;
            
            if app.sar.method ~= "Circular"
                uiconfirm(app.UIFigure,"Must use 1-D θ Circular CSAR scan to use 1-D CSAR 2-D BPA image reconstruction method!",'SAR Scenario Error!',...
                    "Options",{'OK'},'Icon','warning');
                obj.isFail = true;
                return
            end
        end
        
        function [obj,imXYZ_out] = computeReconstruction(obj,app,im)
            obj = update(obj,app,im);
            obj = reconstruct(obj,app);
            imXYZ_out = obj.imXYZ;
        end
        
        function obj = reconstruct(obj,app)
            % Create the progress dialog
            d = uiprogressdlg(app.UIFigure,'Title','Performing XYZ BPA',...
                'Message',"Estimated Time Remaining: 0:0:0","Cancelable","on");
            
            if obj.isGPU
                reset(gpuDevice);
            end
            
            % Orient vx_xyz x target_xyz x k
            obj.sarData = reshape(obj.sarData,[],1,length(obj.k_vec));
            k = single(reshape(obj.k_vec,1,1,[]));
            
            try
                % Fast way
                obj = fastBPA(obj,k,d);
            catch
                d.Title = "Performing XYZ BPA";
                obj = mediumBPA(obj,k,d);
            end            
            
            delete(d)
            try
                obj.imXYZ = reshape(obj.imXYZ,obj.sizeTarget);
            catch
                warning("WHAT!")
            end
        end
        
        function obj = fastBPA(obj,k,d)
            obj.imXYZ = single(zeros(1,size(obj.target_xyz_m,1)));
            tocs = single(zeros(1,length(k)));
            for indK = 1:length(k)
                tic
                
                if d.CancelRequested
                    warning("Image not computed!")
                    return;
                end                
                
                if obj.isMIMO
                    Rt = pdist2(obj.tx_xyz_m,obj.target_xyz_m);
                    Rr = pdist2(obj.rx_xyz_m,obj.target_xyz_m);
                    amplitudeFactor = Rt .* Rr;
                    R_T_plus_R_R = Rt + Rr;
                else
                    R = pdist2(obj.vx_xyz_m,obj.target_xyz_m);
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
                obj.imXYZ = obj.imXYZ + sum(obj.sarData(:,:,indK) .* bpaKernel,1);
                % Update the progress dialog
                tocs(indK) = toc;
                d.Value = indK/length(k);
                d.Message = "Iteration " + indK + "/" + length(k) + ". Estimated Time Remaining: " + getEstTime(obj,tocs,indK,length(k));
            end
        end
        
        function obj =  mediumBPA(obj,k,d)
            obj.imXYZ = single(zeros(1,size(obj.target_xyz_m,1)));
            tocs = single(zeros(1,2^14));
            count = 0;
            for indTarget = 1:size(obj.target_xyz_m,1)
                for indK = 1:length(k)
                    tic
                    count = count + 1;
                    
                    if d.CancelRequested
                        warning("Image not computed!")
                        return;
                    end
                    
                    if obj.isMIMO
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
                    d.Value = count/(length(k)*size(obj.target_xyz_m,1));
                    d.Message = "Iteration " + count + "/" + length(k)*size(obj.target_xyz_m,1) + ". Estimated Time Remaining: " + getEstTime(obj,tocs,indK,length(k)*size(obj.target_xyz_m,1));
                end
            end
        end
        
        function displayImage(obj,im)
            displayImage2D(im,im.x_m,im.z_m,"x (m)","z (m)");
        end
        
        function outstr = getEstTime(obj,tocs,currentInd,totalInd)
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
    end
end