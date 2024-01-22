function [Calculated_Power_BlochSiegert] = TransmitGain_CenterFreqOff_BlochSiegert(inDir)
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
funVersion = '20240116';

%% inputs
if ~nargin,             inDir = uigetdir(); end
if isscalar(inDir),     inDir = num2str(inDir); end
if ~exist(inDir, 'dir')
    error('Specified scan directory (%s) does not exist', inDir)
end

if isdeployed
    diary(fullfile(inDir, sprintf('%s-log_%s.txt', mfilename, datestr(now, 30))));
    fprintf('Entering %s at %s\n', mfilename, datestr(now))
    funVersion
end

%%
header = readBrukerHeader(fullfile(inDir,'method')); %header information from study to determine T and omega_RF values

[spectrum,fid]= recoBrukerKspace(inDir,[],[]);
figure;

%fid 1
subplot(4,1,1)
plot(real(fid(:,1))); %real fid information here
hold on
plot(imag(fid(:,1))); %imaginary 
title('Measured FID 1')
legend('Real','Imaginary')
xlim([0,1000])

%fid 2
subplot(4,1,2)
plot(real(fid(:,2))); %real fid information here
hold on
plot(imag(fid(:,2))); %imaginary 
title('Measured FID 2')
legend('Real','Imaginary')
xlim([0,1000])

%phase difference
subplot(4,1,3)
plot(angle(fid(:,2).*conj(fid(:,1)))) %phase difference between fid 1 and fid 2
range = (header.PVM_DigShift+1:2*(header.PVM_DigShift)); %range of fid

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
%out3 = split(out2,','); %split doens't work for matlab before 2016b, cant
                            %use this because we complie on 2013a
out3 = regexp(out2,',','split');
Power_BS = str2double(out3(1)); %Watts

%% Solve for K_BS 

gyromagnetic_ratio = gyromagnetic_ratio_7T/10^6/(2*pi); %MHz/Tesla; Gyromagnetic ratio of 1H at 7T.

% Determine Bloch-Siegert pulse duration/length from header
out4 = strrep(header.CJH_BSPulse,'(','');
out5 = strrep(out4 ,')','');
%out6 = split(out5,','); %split doens't work for matlab before 2016b, cant
                            %use this because we complie on 2013a
out6 = regexp(out5,',','split');
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
%tswitch=((phi_measured_mean-phi_expected)/((2*pi*offset_frequency)*(180/pi)));
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

formatSpec = 'Phase Difference = %.4f rad = %.4f degrees; TG Reference Power = %.4f W;'; 
title(sprintf(formatSpec, Phi_BlochSiegert_Corrected_rad, Phi_BlochSiegert_Corrected_degree, Calculated_Power_BlochSiegert))
xlim([0,1000])
hold on

% Original plot
z = plot(angle(fid(:,2).*conj(fid(:,1))), '-b'); % Plot with blue line

% Extract indices for markers
idxmin = range(:,1);
idxmax = range(:,header.PVM_DigShift);

% Plot markers at specified indices
plot(idxmin, angle(fid(idxmin,2).*conj(fid(idxmin,1))), 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 10);
plot(idxmax, angle(fid(idxmax,2).*conj(fid(idxmax,1))), 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 10);

hold off

%% Solve for center frequency difference

NOP = header.PVM_SpecMatrix;
SBW = header.PVM_SpecSWH; %Hz

% FID information
realfid = fid(header.PVM_DigShift+1:end,1);
realfid_padded = zeros(NOP, 1);  % Create a new array of zeros with the desired size
realfid_padded(1:length(realfid)) = realfid;  % Copy the original realfid values

imagfid = fid(header.PVM_DigShift+1:end,2);
imagfid_padded = zeros(NOP, 1);  % Create a new array of zeros with the desired size
imagfid_padded(1:length(imagfid)) = imagfid;  % Copy the original realfid values

complexfid = realfid_padded + 1i*imagfid_padded; % Combine into a complex array

% Fourier Transform of fid yields spectrum
spectrum = fftshift(fft(complexfid));

% Determine x axis
freqAxis = (-NOP/2: (NOP/2)-1)*(SBW/NOP);

% Find the maximum value in the spectrum
[maxValue, maxIndex] = max(abs(spectrum));

% Find the corresponding frequency
peakFrequency = freqAxis(maxIndex);

% Plotting
subplot(4,1,4)
plot(freqAxis, real(abs(spectrum)));
xlabel('Frequency (Hz)');
ylabel('Intensity');
formatSpec3 = 'Peak Working Frequency = %.4f Hz from Center Frequency'; 
title(sprintf(formatSpec3, peakFrequency));

% Mark the peak with a red circle
hold on;
plot(freqAxis(maxIndex), real(abs(spectrum(maxIndex))), 'ro');
hold off;

%% PHASE CORRECTION
%
% vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
%
% %% Correct FIDs
% 
% t = (1:NOP).*(1 / SBW);
% phase_correction = exp(-1i*2*pi*peakFrequency*t);
% phase_corrected_fid = fid.*phase_correction.';
% 
% figure();
% 
% %fid 1
% subplot(4,1,1)
% plot(real(phase_corrected_fid(:,1))); %real fid information here
% hold on
% plot(imag(phase_corrected_fid(:,1))); %imaginary 
% title('Phase Corrected FID 1')
% legend('Real','Imaginary')
% xlim([0,1000])
% 
% %fid 2
% subplot(4,1,2)
% plot(real(phase_corrected_fid(:,2))); %real fid information here
% hold on
% plot(imag(phase_corrected_fid(:,2))); %imaginary 
% title('Phase Corrected FID 2')
% legend('Real','Imaginary')
% xlim([0,1000])
% 
% %phase difference
% subplot(4,1,3)
% plot(angle(phase_corrected_fid(:,2).*conj(phase_corrected_fid(:,1)))) %phase difference between fid 1 and fid 2
% 
% phi_BS_rad_measured_phase_correct = mean(angle(phase_corrected_fid(range,2).*conj(phase_corrected_fid(range,1))));
% phi_BS_rad_measured_phase_correct = (phi_BS_rad_measured_phase_correct*0.5); %phase difference value in rad
% 
% phi_BS_degree_measured_phase_correct = phi_BS_rad_measured_phase_correct*(180/pi); %phase difference value in degrees
% 
% %% Solve for Bruker Reference Power 
% 
% Phi_BlochSiegert_Corrected_degree_phase_correct = phi_BS_degree_measured_phase_correct-phi_predicted;
% Phi_BlochSiegert_Corrected_rad_phase_correct = Phi_BlochSiegert_Corrected_degree_phase_correct*pi/180;
% 
% %% Plotting phase difference vs. offset frequency
% 
% Corrected_measured_phi_rad_phase_correct = (phi_BS_degree_measured_phase_correct-phi_predicted)*(pi/180);
% B1_BS_Peak_measured_phase_correct = sqrt(((Corrected_measured_phi_rad_phase_correct)*((10^6)^2))/(K_BS*(2*pi)));
% Calculated_Power_BlochSiegert_phase_correct = (((B1_ref_90/B1_BS_Peak_measured_phase_correct)^2)*Power_BS);
% 
% formatSpec = 'Phase Difference = %.4f rad = %.4f degrees; TG Reference Power = %.4f W;'; 
% title(sprintf(formatSpec, Phi_BlochSiegert_Corrected_rad_phase_correct, Phi_BlochSiegert_Corrected_degree_phase_correct, Calculated_Power_BlochSiegert_phase_correct))
% xlim([0,1000])
% hold on
% 
% % Original plot
% z = plot(angle(phase_corrected_fid(:,2).*conj(phase_corrected_fid(:,1))), '-b'); % Plot with blue line
% 
% % Extract indices for markers
% idxmin = range(:,1);
% idxmax = range(:,header.PVM_DigShift);
% 
% % Plot markers at specified indices
% plot(idxmin, angle(phase_corrected_fid(idxmin,2).*conj(phase_corrected_fid(idxmin,1))), 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 10);
% plot(idxmax, angle(phase_corrected_fid(idxmax,2).*conj(phase_corrected_fid(idxmax,1))), 'ro', 'MarkerFaceColor', 'red', 'MarkerSize', 10);
% 
% hold off
% 
% %% Solve for center frequency difference
% 
% % FID information
% realfid_phase_correct = phase_corrected_fid(header.PVM_DigShift+1:end,1);
% realfid_padded_phase_correct = zeros(NOP, 1);  % Create a new array of zeros with the desired size
% realfid_padded_phase_correct(1:length(realfid_phase_correct)) = realfid_phase_correct;  % Copy the original realfid values
% 
% imagfid_phase_correct = phase_corrected_fid(header.PVM_DigShift+1:end,2);
% imagfid_padded_phase_correct = zeros(NOP, 1);  % Create a new array of zeros with the desired size
% imagfid_padded_phase_correct(1:length(imagfid_phase_correct)) = imagfid_phase_correct;  % Copy the original realfid values
% 
% complexfid_phase_correct = realfid_padded_phase_correct + 1i*imagfid_padded_phase_correct; % Combine into a complex array
% 
% % Fourier Transform of fid yields spectrum
% spectrum_phase_correct = fftshift(fft(complexfid_phase_correct));
% 
% % Determine x axis
% freqAxis_phase_correct = (-NOP/2: (NOP/2)-1)*(SBW/NOP);
% 
% % Find the maximum value in the spectrum
% [maxValue_phase_correct, maxIndex_phase_correct] = max(abs(spectrum_phase_correct));
% 
% % Find the corresponding frequency
% peakFrequency_phase_correct = freqAxis_phase_correct(maxIndex_phase_correct);
% 
% % Plotting
% subplot(4,1,4)
% plot(freqAxis_phase_correct, real(abs(spectrum_phase_correct)));
% xlabel('Frequency (Hz)');
% ylabel('Intensity');
% formatSpec3 = 'Peak Phase Corrected Working Frequency = %.4f Hz from Center Frequency'; 
% title(sprintf(formatSpec3, peakFrequency_phase_correct));
% 
% % Mark the peak with a red circle
% hold on;
% plot(freqAxis(maxIndex_phase_correct), real(abs(spectrum_phase_correct(maxIndex_phase_correct))), 'ro');
% hold off;
end