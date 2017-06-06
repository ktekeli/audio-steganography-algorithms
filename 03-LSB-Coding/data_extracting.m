close all; clear all; clc;

[FileName,PathName] = uigetfile({'.wav'}, 'Select stego audio:');
wavin = [PathName FileName];

password = 'mypassword123';

msg = lsb_dec(wavin, password);
fprintf('Retrieved message: %s\n', msg);