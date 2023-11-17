# PV-BSXmit: Bloch-Siegert Transmit Gain Calibration for Paravision 

*README.md is currently a work in progress (last updated 11/17/2023)*.

# What is this repository for?
This repository contains the necessary files to peform transmit gain calibration on the Bruker (Paravision) platform. Specifically, this method can be used for fast and automated TG calibration for 13C and HP 129Xe MRI on a preclinical 7T scanner.

*This method has only been tested using the CentOS 5.11 operating system and Parvision V6.0.1 (PV6.0.1)*.

# How do I get set up?
* *bsSinglePulse* is the name of the Bloch-Siegert transmit gain pulse sequence. Copy *bsSinglePulse_6.0.1.PvUserSrcMethod* to **${PVHOME}/prog/curdir/${USER}/ParaVision/methods/src** and import the method file using PV6.0.1. 
* A MATLAB (The Mathworks) analysis script can be implemented as a standalone executable function that can be called automatically following data acquisition using *bsSinglePulse*. The *BlochSiegert_TGCalibration* folder contains: *TransmitGain_BlochSiegert.m* and *readBrukerHeader.m*, *recoBrukerKSpace.m*, *readBrukerFid.m*, *rfCalBruker.m*, and *ifftdim.m*. *TransmitGain_BlochSiegert.m* is the main analysis script, with the others being necessary supporting scripts. Compile the files in the *BlochSiegert_TGCalibration* folder using MATLAB (2013a) and copy the compiled executable file to **${PVHOME}/prog/curdir/${USER}/ParaVision/macros**.
* *FERMI_Bloch Siegert.exc* contains an optimized Fermi shaped RF pulse that can be used for off-resonant Bloch-Siegert pulse generation. Copy *FERMI_Bloch Siegert.exc* to **${PVHOME}/prog/curdir/${USER}/ParaVision/exp/lists/wave**.

# Who do I talk to?
Please feel free to contact us with questions, comments, imporovments, or concerns:

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

# Acknowledgements 
This work was supported by funding from the National Cancer Institute of the National 
Institutes of Health (R21CA280799, T32CA196561) and the shared instrumentation grant (S10OD027038). The content is solely the responsibility of the 
creators and does not necessarily represent the official views of the sponsors.