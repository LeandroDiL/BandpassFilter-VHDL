# BandpassFilter-VHDL
Desing and development of a sixth order bandpass filter using VHDL

## Goal
VHDL implementation of a IIR digital filter on FPGA board with the following specs :
- Class : elliptic filter of sixth order
- Bandwith : 200-5000 Hz
- Ripple : 0.5 dB in bandwith
- Attenuation : 40dB in stopband
- Structure : lattice-ladder
The structure to follow is reported here : 
![image](https://user-images.githubusercontent.com/102248925/214392928-c749a5dc-2119-44c7-bdf5-c565c4539205.png)

## Tools
The tools used to reach the goal are :
- Matlab : used to calculate coefficients of the lattice-ladder structure and to approximate coefficients
- Simulink : used to simulate the filter and determine internal signals size
- VHDL : used for testbench and for the implementation of the filter
- Audacity : used to analize filtered signal spectre
