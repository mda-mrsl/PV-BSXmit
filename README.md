# PV-BSXmit

# What is this repository for?
This repository contains the necessary method file and supplementary materials for (nonproton) transmit gain calibration on the Bruker (Paravision) platform.

Please note, this method has only been tested using the CentOS 5.11 operating system and Parvision V6.0.1 (PV6.0.1).

# How do I get set up?
* *bsSinglePulse* is the name of the Bloch-Siegert transmit gain pulse sequence. Import *bsSinglePulse_6.0.1.PvUserSrcMethod* in PV6.0.1 to **${PVHOME}/prog/curdir/${USER}/ParaVision/methods/src**.
* A MATLAB analysis script can be implemented as a standalone executable function (macro) that can be called automatically following data acquisition. Compile the files in the *BlochSiegert_TGCalibration* folder using PV6.0.1. The *BlochSiegert_TGCalibration* folder contains: *TransmitGain_BlochSiegert.m*, *readBrukerHeader.m*, *recoBrukerKSpace.m*, *readBrukerFid.m*, *rfCalBruker.m*, and *ifftdim.m*.
* Copy compiled file to **${PVHOME}/prog/curdir/${USER}/ParaVision/macros**
* *FERMI_Bloch Siegert.txt* contains an optimized Fermi shaped RF pulse for off-resonant Bloch-Siegert pulse generation. Copy *FERMI_Bloch Siegert.txt* to **${PVHOME}/prog/curdir/${USER}/ParaVision/exp/lists/wave**. 

# Who do I talk to?
Collin J. Harlan\
CJHarlan@mdanderson.org\
Graduate Research Assistant\
The University of Texas MD Anderson Cancer Center\
Graduate School of Biomedical Sciences\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory

Jim Bankson\
JBankson@mdanderson.org\
Professor\
The University of Texas MD Anderson Cancer Center\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory
