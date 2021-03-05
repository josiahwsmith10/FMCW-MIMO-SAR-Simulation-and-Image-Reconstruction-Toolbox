classdef reconstructionAlgorithmTemplate_app < handle
    % reconstructionAlgorithmTemplate_app see
    % reconstructionAlgorithmTemplate documentation
    properties
        sarData
        
        nFFTx
        nFFTy
        nFFTz
        
        x_m
        y_m
        z_m
        
        imXYZ
        
        isGPU
        isAmplitudeFactor
        isFail
        
        k_vec
        z0_m
        xStep_m
        yStep_m
    end
    
    methods
        function obj = reconstructionAlgorithmTemplate_app(app,im)
            
        end
        function obj = update(obj,app,im)
            obj = getParameters(obj,app,im);
            obj = verifyParameters(obj,app);
            obj = verifyReconstruction(obj,app);
        end
        
        function obj = getParameters(obj,app,im)
            obj.nFFTx = im.nFFTx;
            obj.nFFTy = im.nFFTy;
            obj.nFFTz = im.nFFTz;
            
            obj.x_m = im.x_m;
            obj.y_m = im.y_m;
            obj.z_m = im.z_m;
            
            obj.sarData = app.target.sarData;
            
            obj.isGPU = im.isGPU;
            obj.isAmplitudeFactor = app.target.isAmplitudeFactor;
            
            obj.k_vec = app.fmcw.k;
            obj.z0_m = app.ant.tx.z0_m;
            obj.xStep_m = app.sar.xStep_m;
            obj.yStep_m = app.sar.yStep_m;
        end
        
        function [obj,imXYZ_out] = computeReconstruction(obj,app,im)
            obj = update(obj,app,im);
            if ~obj.isFail
                obj = reconstruct(obj,app);
            end
            imXYZ_out = obj.imXYZ;
        end
        
        function obj = reconstruct(obj,app)
            
        end
    end
end