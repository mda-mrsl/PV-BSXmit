# Bloch-Siegert Transmit Gain Calibration for Paravision: PV-BSXmit

# What is this repository for?
This repository contains the necessary files to peform transmit gain calibration on the Bruker (Paravision) platform. Specifically, this method can be used for fast and automated TG calibration of nonproton (13C, 129Xe) nuclei on a 7T small animal MRI.

*This method has only been tested using the CentOS 5.11 operating system and Parvision V6.0.1 (PV6.0.1)*

# How do I get set up?
* Import *bsSinglePulse_6.0.1.PvUserSrcMethod* in PV6.0.1 to **${PVHOME}/prog/curdir/${USER}/ParaVision/methods/src**. *bsSinglePulse* is the name of the Bloch-Siegert transmit gain pulse sequence. 
* A MATLAB (The Mathworks) analysis script can be implemented as a standalone executable function (macro) that can be called automatically following data acquisition using *bsSinglePulse*. The *BlochSiegert_TGCalibration* folder contains: *TransmitGain_BlochSiegert.m* and *readBrukerHeader.m*, *recoBrukerKSpace.m*, *readBrukerFid.m*, *rfCalBruker.m*, and *ifftdim.m*. *TransmitGain_BlochSiegert.m* is the main analysis script, with the others being necessary supporting scripts. Compile the files in the *BlochSiegert_TGCalibration* folder using PV6.0.1 and copy the compiled file to **${PVHOME}/prog/curdir/${USER}/ParaVision/macros**.
* *FERMI_Bloch Siegert.txt* contains an optimized Fermi shaped RF pulse that can be used for off-resonant Bloch-Siegert pulse generation. Copy *FERMI_Bloch Siegert.txt* to **${PVHOME}/prog/curdir/${USER}/ParaVision/exp/lists/wave**.

# Who do I talk to?
Collin J. Harlan\
CJHarlan@mdanderson.org\
Graduate Research Assistant\
The University of Texas MD Anderson Cancer Center\
Graduate School of Biomedical Sciences\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory

James A. Bankson\
JBankson@mdanderson.org\
Professor\
The University of Texas MD Anderson Cancer Center\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory
