In this project I designed a system that shows DSP opportunities of FPGA solutions. The FPGA design consist of:
1) Finite-state machine for configuration an audio codec via I2C.
2) I2S receiver for acquiring data from the audio codec.
3) 6-order low-pass IIR filter to demonstrate filtering opportunities of FPGA.
4) 4096-point FFT megacore from Altera to get the signal spectrum.
5) VGA module with video RAM to display the spectrum.
All modules are written by myself except FFT megacore.

The design is intended for Terasic DE2-115 board with Cyclone IV FPGA chip.

KEY[0] - reset
SW[2:0] - background color
SW[17] - 1: filter off, 0: filter on
SW[16] - mic left/right channel

VGA: VESA 1024x768@70 Hz
FFT range: 0 - 1/4 Fs
Fs: 48 828.125 Hz