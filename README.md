# PV-BSXmit

# What is this repository for?
This repository contains the necessary method file and supplementary materials for (nonproton) transmit gain calibration on the Bruker (Paravision) platform.

Please note, this method has only been tested using the CentOS 5.11 operating system and Parvision V6.0.1 (PV6.0.1).

# How do I get set up?
* Import *bsSinglePulse_6.0.1.PvUserSrcMethod* in PV6.0.1 to **${PVHOME}/prog/curdir/${USER}/ParaVision/methods/src**.
* *bsSinglePulse* is the name of the Bloch-Siegert transmit gain pulse sequence.
* Compile *BlochSiegert_TGCalibration* in PV6.0.1. The *BlochSiegert_TGCalibration* folder contains: *TransmitGain_BlochSiegert.m*, *readBrukerHeader.m*, *recoBrukerKSpace.m*, *readBrukerFid.m*, *rfCalBruker.m*, and *ifftdim.m*.
* Copy compiled file to **${PVHOME}/prog/curdir/${USER}/ParaVision/macros**
* Copy *FERMI_Bloch Siegert.txt* to **NEED WAVEFORM PATH**

# Who do I talk to?
Collin J. Harlan\
CJHarlan@mdanderson.org\
The University of Texas MD Anderson Cancer Center\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory

Jim Bankson\
JBankson@mdanderson.org\
The University of Texas MD Anderson Cancer Center\
Department of Imaging Physics\
Magnetic Resonance Systems Laboratory
