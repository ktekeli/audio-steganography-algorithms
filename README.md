# audio-steganography-algorithms

A library of audio steganography & watermarking algorithms written in Matlab. 

## Index of Plan

#### 1. Spread Spectrum
  - Conventional Algorithm for DSSS
  - Improved Spread Spectrum
  
#### 2. Echo Hiding
  - Echo Hiding - Single Echo Kernel
  - Echo Hiding - Negative and Positive Echo Kernels
  - Echo Hiding - Backward and Forward Echo Kernels
  - Echo Hiding - Mirrored Echo Kernels
  - Time Spread Echo Hiding
  
#### 3. Least Significant Bit (LSB) Coding 

#### 4. Phase Coding

#### 5. Parity Coding

#### 6. Quantization Index Modulation

## About

Audio steganography is probably one of most challenging tasks. I was seeking for source codes of existing techniques some time ago, but I could not find enough information. It was a very good experience for me to dig into DSP as a mathematician. I have decided to open my library up for those who are also seeking for audio steganography methods. I guess this project will be the first comprehensive repository about source codes of audio steganography methods, since I could not find anything on my own. Data hiding in transform domain such as DWT, DCT and using decompositions like SVD and QR were also studied and implented in MATLAB. So, I will keep updating this repository in time. Conventional approaches of each method are being shared openly, but improvements are added in pcodes for tests and compressions. A tutorial is planned to be added describing basics of methods.

This library was coded in MATLAB R2015a under Windows 10. For any qustions, e-mail me directly at: kadir.tekeli@outlook.com.

 ## Usage
 
 - All algorithms were built as functions so they can be called from outside. Parameters of each functions is explained brifly in the description of each.
 - A combination of several existing audio reader and writer functions were added to simplify type conversions. If audioload.m, audiosave.m and mp3bin folder do not exist in the path, it can be copied into the directory manually.
 - Example scripts  "data_embedding.m" and "data_extracting.m" were added in each method for a quick trial.
 - A mixer signal generator has been implented for Spread Spectrum and Echo Hiding in order to smooth discontinuities between adjacent segments using sinusoidal modulation via convolution sum.
 - In order to make each algorithm most blind, critical information such as message length, frame size etc can be embedded as well adding up to data to be hidden.
