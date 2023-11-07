# audio-steganography-algorithms

> A comprehensive open source library of audio steganography and watermarking algorithms written in OCTAVE/Matlab.

## About

Audio [steganography](https://en.wikipedia.org/wiki/Steganography) is probably one of the most challenging areas. So, it is hard to find related sources for researchers. The main goal of this project was to provide basic audio steganography algorithms for everyone.

Our future scope is to publish a modular library containing *existing methods*, *signal processing attacks* and *comparison metrics*. We plan to add detailed and demystified documentation for each method containing mathematical background.

Repository will be updated in time, so please keep in touch.

For any questions please [create an issue](https://help.github.com/articles/creating-an-issue/) instead of sending an e-mail.

## Algorithms

#### 1. Spread Spectrum
- [x] Direct Sequence Spread Spectrum (DSSS) (open source)
- [x] Improved Spread Spectrum (ISS) (p-code)
- [ ] Spread Spectrum using FFT (planned)
- [ ] Spread Spectrum using DCT (planned)
- [ ] Spread Spectrum using DWT (planned)

#### 2. Echo Hiding
- [x] Echo Hiding - Single Echo Kernel (open source)
- [x] Echo Hiding - Negative and Positive Echo Kernels (p-code)
- [x] Echo Hiding - Backward and Forward Echo Kernels (p-code)
- [x] Echo Hiding - Mirrored Echo Kernels (p-code)
- [x] Echo Hiding - Time Spread Echo Kernel (p-code)

#### 3. Least Significant Bit Coding
- [x] LSB Coding (open source)
- [ ] LSB Coding in DWT Domain (planned)

#### 4. Phase Coding
- [x] Phase Coding (open source)

#### 5. Parity Coding
- [ ] Parity Coding (planned)

#### 6. Quantization Index Modulation
- [ ] Quantization Index Modulation (planned)


 ## Usage & More

 - All algorithms were built as functions so they can be called from outside. Parameters are explained briefly in the description of each function.

- Example scripts "data_embedding.m" and "data_extracting.m" were added in each method for a quick trial.

- Several existing encoders and decoders have been combined in "audioload.m" and "audiosave.m" in order to simplify type conversions (i.e. WAV, FLAC, MP3, AAC and OGG).

- A mixer signal generator "mixer.m" has been implemented in order to smooth discontinuities between adjacent segments (i.e. for Echo Hiding and Spread Spectrum methods).

- Critical information such as message length, frame size etc can be embedded within the data for blind steganography. See LSB Coding for an example.

- Hidden data can be encrypted for the improved security. See LSB Coding for a basic encryption example using XOR.

## Support

If you find this repository helpful, please star and fork it to support us. If you would like to be a part of this project, submit a pull request to contribute. We will be happy to discuss and exchange state-of-the-art ideas related to audio steganography.

## Contribution

Contributions are always welcome! Please read the contribution guidelines first.

1. Fork the repository.
2. Apply your edits on your fork.
3. If you are going to add a new method, please use same syntax and structure.
4. Commit the changes to your forked repository.
5. Submit a [pull request](https://help.github.com/articles/creating-a-pull-request/) adding details about your modification.

Thank you for your suggestions!

## Author
- Kadir Tekeli [[linkedin]](https://www.linkedin.com/in/ktekeli/) [[researchgate]](https://www.researchgate.net/profile/Kadir_Tekeli)

## License
[MIT](https://github.com/ktekeli/audio-steganography-algorithms/blob/master/LICENCE) License (2016-2017)
