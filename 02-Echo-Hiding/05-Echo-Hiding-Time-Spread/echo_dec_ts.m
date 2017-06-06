function out = echo_dec_ts(signal, L, d0, d1, len_msg)
%ECHO_DEC_TS Decoding function for Time-Spread Echo Hiding Technique
%
%   INPUT VARIABLES
%       signal  : Stego signal
%       L       : Length of frames
%       d0      : Delay rate for bit0
%       d1      : Delay rate for bit1
%       len_msg : Length of hidden message
%
%   OUTPUT VARIABLES
%       out     : Retrieved message
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin < 2
    L = 8*1024;   %Length of frame
end

if nargin < 4
    d0 = 150;     %Delay rate for bit0
    d1 = 200;     %Delay rate for bit1
end

if nargin < 5
    len_msg = 0;
end

N = floor(length(signal)/L);             %Number of frames
xsig = reshape(signal(1:N*L,1), L, N);

password = 'mypassword123';   %Password for pseudorandom sequence
Lp = 512;                     %Length pseudorandom sequence
pr = prng(password, Lp);      %Pseudorandom sequence

data = ts_dec(xsig, d0, d1, pr);  %Decoding process

m   = floor(N/8);
bin = reshape(data(1:8*m), 8, m)';   %Retrieved message in binary
out = char(bin2dec(bin))';           %bin=>char

if (len_msg~=0)
	out = out(1:len_msg);
end
end

function out = prng( key, L )
%PRNG Pseudorandom number generator
pass = sum(double(key).*(1:length(key)));
rand('seed', pass);
out = (rand(L, 1)>0.5);
end