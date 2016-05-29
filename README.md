
![alt tag](https://www.dropbox.com/s/kuagdh0ddndpmlt/photo-example.jpg?raw=1)

# Description

In this project I designed a system that shows DSP opportunities of FPGA solutions. The FPGA design consist of:<br />
1) Finite-state machine for configuration an audio codec via I2C.<br />
2) I2S receiver for acquiring data from the audio codec.<br />
3) 6-order low-pass IIR filter to demonstrate filtering capabilities of FPGA.<br />
4) 4096-point FFT megacore from Altera to get the signal spectrum.<br />
5) VGA module with video RAM to display the spectrum.<br />
All modules are written by myself except FFT megacore.<br />
<br />
The design is intended for Terasic DE2-115 board with Cyclone IV FPGA chip.<br />
<br />
KEY[0] - reset<br />
SW[2:0] - background color<br />
SW[17] - 1: filter off, 0: filter on<br />
SW[16] - mic left/right channel<br />
<br />
VGA: VESA 1024x768@70 Hz<br />
FFT range: 0 - 1/4 Fs<br />
Fs: 48 828.125 Hz

# Block diagram

![alt tag](https://www.dropbox.com/s/bg2g003zykzvpz0/BlockDiagram.png?raw=1)

# Example

[Watch the video of working](https://www.dropbox.com/s/856fmr8i4wgyl42/video-example.webm?raw=1)
