close all; clear all; clc;

audio = audioload();

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

msg = echo_dec(audio.data);
err = BER(text,msg);
nc  = NC(text, msg);

fprintf('Text: %s\n', msg);
fprintf('BER : %d\n', err);
fprintf('NC  : %d\n', nc);