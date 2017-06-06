close all; clear all; clc;

audio = audioload();

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

out = echo_enc_np(audio.data, text);
audiosave(out(:,1), audio, '.mp3', 128);
