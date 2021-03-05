classdef fmcwChirpParameters < handle
    % fmcwChirpParameters The chirp parameters of the FMCW radar under
    % test, adhering loosely to the TI mmWave Studio definitions
    
    properties (SetObservable)
        f0 = 77e9                   % Starting frequency in Hz
        K = 100.036e12              % Chirp slope in Hz/s
        IdleTime_s = 0              % Duration of time before starting the chirp/ramp after the previous chirp
        TXStartTime_s = 0           % Duration of time before chirp/ramp starts wherein transmitter is ON
        ADCStartTime_s = 0          % Duration of time after transmitter is ON and TXStartTime_s has passed wherein chirp/ramp is active, but samples are not being collected (acts as a guard against initial chirp non-linearities)
        RampEndTime_s = 39.98e-6    % Duration of time after transmitter is ON and TXStartTime_s has passed wherein chirp/ramp is active
        ADCSamples = 79             % Number of ADC samples
        fS = 2000e3                 % Sampling frequency in Hz
        fC = 79e9                   % Center frequency in Hz
    end
    
    properties
        ADCSampleTime_time = 0      % Duration of time during which ADC samples are taken, dictated by time parameters
        ADCSampleTime_sample = 0    % Duration of time during which ADC samples are taken, dictated by sampling parameters (ADCSamples & fS)
        B_total = 0                 % Total bandwidth used
        B_useful = 0                % Useful/actual bandwidth covered by ADC samples
        c = 3e8                     % Speed of light
        rangeMax_m = 0              % Maximum range of FMCW chirp parameters in meters
        rangeResolution_m = 0       % Range resolution in meters
        k                           % Instantaneous wavenumber vector
        lambda_m = 0                % Wavelength of center frequency
    end
    
    methods
        function obj = fmcwChirpParameters()
            % Attaches the listener to the fmcwChirpParameters object
            
            attachListener(obj);
        end
        
        function getChirpParameters(obj,savedfmcw)
            % Gets the chirp parameters from savedfmcw (used for loading)
            
            obj.f0 = savedfmcw.f0;
            obj.K = savedfmcw.K;
            obj.IdleTime_s = savedfmcw.IdleTime_s;
            obj.TXStartTime_s = savedfmcw.TXStartTime_s;
            obj.ADCStartTime_s = savedfmcw.ADCStartTime_s;
            obj.ADCSamples = savedfmcw.ADCSamples;
            obj.fS = savedfmcw.fS;
            obj.RampEndTime_s = savedfmcw.RampEndTime_s;
            obj.fC = savedfmcw.fC;
        end
        
        function computeChirpParameters(obj)
            % Compute the necessary parameters given the current parameters
            % and verify parameters
            
            obj.ADCSampleTime_time = obj.RampEndTime_s - obj.ADCStartTime_s;
            obj.ADCSampleTime_sample = obj.ADCSamples/obj.fS;
            
            obj.c = physconst('lightspeed');
            
            if obj.ADCSampleTime_sample > obj.ADCSampleTime_time
                warning("Not enough time to collect " + obj.ADCSamples + " samples at " + obj.fS*1e-3 + " ksps");
            end
            obj.B_total = obj.RampEndTime_s*obj.K;
            obj.B_useful = obj.ADCSampleTime_sample*obj.K;
            
            obj.rangeMax_m = obj.fS*obj.c/(2*obj.K);
            obj.rangeResolution_m = obj.c/(2*obj.B_useful);
            
            f0_temp = obj.f0 + obj.ADCStartTime_s*obj.K;        % This is for ADC sampling offset
            f = f0_temp + (0:obj.ADCSamples-1)*obj.K/obj.fS;    % wideband frequency
            
            obj.k = 2*pi*f/obj.c;
            obj.lambda_m = obj.c/(obj.fC);
        end
        
        function loadChirpParameters(obj,loadName)
            % Load the chirp parameters from a file
            
            if ~exist(loadName + ".mat",'file')
                warning("No file called " + loadName + ".mat to load. Parameters not loaded!");
                return;
            end
            
            load(loadName,"savedfmcw");
            
            getChirpParameters(obj,savedfmcw);
            computeChirpParameters(obj);
        end
        
        function saveChirpParameters(obj,saveName)
            % Save the chirp parameters to a file
            
            if exist(saveName,'file')
                str = input('Are you sure you want to overwrite? Y/N: ','s');
                if str ~= 'Y'
                    warning("Parameters not saved!");
                    return;
                end
            end
            
            savedfmcw = obj;
            save(saveName,"savedfmcw");
            disp("FMCW chirp parameters saved to: " + saveName);
        end
        
        function attachListener(obj)
            % Attaches the listener to the object handle
            
            addlistener(obj,{'f0','K','IdleTime_s','TXStartTime_s','ADCStartTime_s','ADCSamples','fS','RampEndTime_s','fC'},'PostSet',@fmcwChirpParameters.propChange);
        end
    end
    
    methods(Static)
        function propChange(metaProp,eventData)
            % Recompute the chirp parameters from the current values
            
            computeChirpParameters(eventData.AffectedObject);
        end
    end
end