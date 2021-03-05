%% Include Necessary Directories
addpath(genpath("../"));

%% Create the Objects
fmcw = fmcwChirpParameters();
ant = sarAntennaArray(fmcw);
sar = sarScenario(ant);
target = sarTarget(fmcw,ant,sar);
im = sarImage(fmcw,ant,sar,target);

%% Set FMCW Parameters
% When the parameters of an fmcwChirpParameters object are changed by the
% user, the object automatically updates itself, namely the property 'k'
% and other dependencies of the changed parameters.
fmcw.f0 = 77*1e9;
fmcw.K = 100.036*1e12;
fmcw.IdleTime_s = 0*1e-6;
fmcw.TXStartTime_s = 0*1e-6;
fmcw.ADCStartTime_s = 0*1e-6;
fmcw.ADCSamples = 79;
fmcw.fS = 2000*1e3;
fmcw.RampEndTime_s = 39.98*1e-6;
fmcw.fC = 79*1e9;

%% Set Antenna Array Properties
% When the parameters of an antennaArray object are changed by the user, 
% the object automatically updates itself
ant.isEPC = false;
ant.z0_m = 0.25;
% Antenna array from xWR1x43
ant.tableTx = [
    0   0   1.5 5   1
    0.5 0   2.5 5   0
    0   0   3.5 5   0];
ant.tableRx = [
    0   0   0   0   1
    0   0   0.5 0   0
    0   0   1   0   0
    0   0   1.5 0   0];

% Display the Antenna Array
ant.displayAntennaArray();

%% Set SAR Scenario Parameters
% When the parameters of a sarScenario object are changed by the user, the
% object automatically updates itself
sar.scanMethod = 'Circular';
sar.numTheta = 256;
sar.thetaMax_deg = 360;

% Display the SAR Scenario
sar.displaySarScenario();

%% Set Target Parameters
% When the parameters of a sarTarget object are changed by the user, the
% object automatically updates itself
target.isAmplitudeFactor = false;

target.tableTarget = [
    0   0   0   1];

target.rp.numTargets = 16;
target.rp.xMin_m = -0.1;
target.rp.xMax_m = 0.1;
target.rp.yMin_m = 0;
target.rp.yMax_m = 0;
target.rp.zMin_m = -0.1;
target.rp.zMax_m = 0.1;
target.rp.ampMin = 0.5;
target.rp.ampMax = 1;

% Which to use
target.isTable = true;
target.isRandomPoints = false;

% Display the target
target.displayTarget();

%% Compute Beat Signal
target.isGPU = true;
target.computeTarget();

%% Set Image Reconstruction Parameters and Create sarImage Object
% When the parameters of a sarImage object are changed by the user, the
% object automatically updates itself
im.nFFTx = 1024;
im.nFFTz = 512;

im.xMin_m = -0.2;
im.xMax_m = 0.2;

im.zMin_m = -0.2;
im.zMax_m = 0.2;

im.numX = 128;
im.numZ = 128;

im.isGPU = false;
im.thetaUpsampleFactor = 4;
im.method = "Uniform 1-D CSAR 2-D PFA";

%% Reconstruct the Image
im.computeImage();

%% Display the Image with Different Parameters
im.dBMin = -30;
im.fontSize = 12;
im.displayImage();