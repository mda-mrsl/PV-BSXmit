function [Calculated_Power_BlochSiegert] = TransmitGain_BlochSiegert(inDir)
%   Usage: [Calculated_Power_BlochSiegert] = TransmitGain_BlochSiegert(inDir)
%
%   Inputs:
%     inDir     - Integer or char of scan directory
%
%   Outputs:
%     plot      - plot of fid (real and imaginary) and phase difference
%                 between fid 1 and fid 2 (rad and degree)
%     Calculated_Power_BlochSiegert - desired transmit gain reference power
%                                     value
%
%   11/2023, Collin J. Harlan, Department of Imaging Physics, MD Anderson Cancer Center

funVersion = '20231115';

%% inputs

if ~nargin,             inDir = uigetdir(); end
if isscalar(inDir),     inDir = num2str(inDir); end
if ~exist(inDir, 'dir')
    error('Specified scan directory (%s) does not exist', inDir)
end

if isdeployed
    diary(fullfile(inDir, sprintf('%s-log_%s.txt', mfilename, datestr(now, 30))));
    fprintf('Entering %s at %s\n', mfilename, datestr(now))
    funVersion;
end

%% Bloch-Siegert phase difference calculation using measured data

header = readBrukerHeader(fullfile(inDir,'method')); %header information from study to determine pulse length (t_BS) and offset frequency (f_BS) values

[spectrum,fid]= recoBrukerKspace(inDir,[],[]);

figure();
%fid 1
subplot(3,1,1)
plot(real(fid(:,1))); %real fid information here
hold on
plot(imag(fid(:,1))); %imaginary 
title('FID 1')
legend('Real','Imaginary')
xlim([0,1000])

%fid 2
subplot(3,1,2)
plot(real(fid(:,2))); %real fid information here
hold on
plot(imag(fid(:,2))); %imaginary 
title('FID 2')
legend('Real','Imaginary')
xlim([0,1000])

%phase difference
subplot(3,1,3)
plot(angle(fid(:,2).*conj(fid(:,1)))) %phase difference between fid 1 and fid 2
range = (70:145); %range of fid

phi_BS_rad_measured = mean(angle(fid(range,2).*conj(fid(range,1))));
phi_BS_rad_measured = (phi_BS_rad_measured*0.5); %phase difference value in rad

phi_BS_degree_measured = phi_BS_rad_measured*(180/pi); %phase difference value in degrees

%% Solve for reference B1 using Bruker Calibration for a 1 ms 90 degree block pulse

% Determine gyromagnetic ratio from header
if strcmp(header.PVM_Nucleus1Enum, '1H')
    gyromagnetic_ratio_7T = 42.58;
elseif strcmp(header.PVM_Nucleus1Enum, '13C')
    gyromagnetic_ratio_7T = 10.705;   
elseif strcmp(header.PVM_Nucleus1Enum, '129Xe')
    gyromagnetic_ratio_7T = -11.777;   
end

theta = pi/2; %rad/s
gyromagnetic_ratio_7T = gyromagnetic_ratio_7T*10^6*(2*pi); %Hz/Tesla; Gyromagnetic ratio of 1H at 7T.
t_pulse = 1*10^-3; %seconds
B1_ref_90 = (theta)/(gyromagnetic_ratio_7T*t_pulse)*10^6; %uTesla

% Determine Bloch-Siegert power from header
out = strrep(header.CJH_BSPulseAmpl,'(','');
out2 = strrep(out ,')','');
out3 = split(out2,',');
Power_BS = str2double(out3(1)); %Watts

%% Solve for K_BS 

gyromagnetic_ratio = gyromagnetic_ratio_7T/10^6/(2*pi); %MHz/Tesla; Gyromagnetic ratio of 1H at 7T.

% Determine Bloch-Siegert pulse duration/length from header
out4 = strrep(header.CJH_BSPulse,'(','');
out5 = strrep(out4 ,')','');
out6 = split(out5,',');
t_BS = str2double(out6(1)); %ms

% Determine Bloch-Siegert offset frequency from header
f_BS = header.CJH_BSFreqOffset/1000; %kHz (CJH_BSFreqOffset); Frequency offset of the RF pulse from resonance frequency omega_o

%Pint from Fermi pulse
B1_normalized = 0.3769;

% Solve for K_BS
K_BS = (gyromagnetic_ratio)^2*(10^6)*t_BS*B1_normalized/(2*f_BS);

%% Solve for Bruker Reference Power 

% Determine Bloch-Siegert offset frequency from header
offset_frequency = header.CJH_BSFreqOffset;
tBS = t_BS/1000;
%tsynth=((phi_measured_mean-phi_expected)/((2*pi*offset_frequency)*(180/pi)));
tswitch = 1.038275084216035e-05;
t_corrected = tBS+tswitch; %s
phi_predicted = (2*pi*offset_frequency.*t_corrected)*180/pi; %degree
phi_predicted = mod(phi_predicted,360);
phi_predicted = phi_predicted - 360*(phi_predicted>180);

Phi_BlochSiegert_Corrected_degree = phi_BS_degree_measured-phi_predicted;
Phi_BlochSiegert_Corrected_rad = Phi_BlochSiegert_Corrected_degree*pi/180;

%% Plotting phase difference vs. offset frequency

Corrected_measured_phi_rad = (phi_BS_degree_measured-phi_predicted)*(pi/180);
B1_BS_Peak_measured = sqrt(((Corrected_measured_phi_rad)*((10^6)^2))/(K_BS*(2*pi)));
Calculated_Power_BlochSiegert = (((B1_ref_90/B1_BS_Peak_measured)^2)*Power_BS);

formatSpec = 'Phase Difference = %.4f rad = %.4f degrees; TG Reference Power = %.4f W';
title(sprintf(formatSpec, Phi_BlochSiegert_Corrected_rad, Phi_BlochSiegert_Corrected_degree, Calculated_Power_BlochSiegert))
xlim([0,1000])
hold on
idxmin = range(:,1);
idxmax = range(:,76);
z = plot(angle(fid(:,2).*conj(fid(:,1))),'-o','MarkerIndices',[idxmin idxmax],...
    'MarkerFaceColor','red',...
    'MarkerSize',10);
set(z,'color','b')

end