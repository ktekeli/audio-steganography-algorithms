close all; clear all; clc;

[FileName,PathName] = uigetfile('*.wav', 'Select audio file.');
audio.data = audioread([PathName FileName]);

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

msg = phase_dec(audio.data, length(text));

err = BER(text,msg);
nc  = NC(text, msg);

fprintf('Text: %s\n', msg); fprintf('BER : %d\n', err);
fprintf('NC  : %d\n', nc);