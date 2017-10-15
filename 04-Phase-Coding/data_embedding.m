close all; clear all; clc;

[FileName,PathName] = uigetfile('*.wav', 'Select audio file.');
[~,audio.name] = fileparts(FileName);
[audio.data, audio.fs] = audioread([PathName FileName]);

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

out = phase_enc(audio.data, text);
audiowrite([audio.name,'_stego.wav'], out, audio.fs);

disp(['Stego signal is saved in ', PathName, audio.name, '_stego.wav']);