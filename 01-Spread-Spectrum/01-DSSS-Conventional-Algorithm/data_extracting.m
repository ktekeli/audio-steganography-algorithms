close all; clear all; clc;

audio = audioload();

file = 'text.txt';
fid  = fopen(file, 'r');
text = fread(fid,'*char')';
fclose(fid);

msg = dsss_dec(audio.data, 8*length(text));
err = BER(text,msg);
nc  = NC(text, msg);

fprintf('Text: %s\n', msg);
fprintf('BER : %d\n', err);
fprintf('NC  : %d\n', nc);