close all; clear all; clc;

audio = audioload();

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

out = echo_enc_single(audio.data, text);
audiosave(out, audio);