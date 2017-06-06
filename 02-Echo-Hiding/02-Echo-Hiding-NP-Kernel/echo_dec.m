function out = echo_dec(signal, L, d0, d1, len_msg)
%ECHO_DEC Decoding function for Echo Hiding Techniques
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
xsig = reshape(signal(1:N*L,1), L, N);   %Dividing signal into frames
data = char.empty(N, 0);

for k=1:N
	rceps = ifft(log(abs(fft(xsig(:,k)))));  %Real cepstrum
	if (rceps(d0+1) >= rceps(d1+1))
        data(k) = '0';
    else
        data(k) = '1';
	end
end

m   = floor(N/8);
bin = reshape(data(1:8*m), 8, m)';   %Retrieved message in binary
out = char(bin2dec(bin))';           %bin=>char

if (len_msg~=0)
	out = out(1:len_msg);
end
