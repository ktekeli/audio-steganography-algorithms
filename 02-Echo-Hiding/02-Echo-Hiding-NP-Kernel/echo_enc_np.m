function out = echo_enc_np(signal, text, d0, d1, alpha, L)
%ECHO_ENC Echo Hiding with Negative and Positive Echo Kernels
%
%   INPUT VARIABLES
%       signal : Cover signal
%       text   : Message to hide
%       d0     : Delay rate for bit0
%       d1     : Delay rate for bit1
%       alpha  : Echo amplitude
%       L      : Length of frames
%
%   OUTPUT VARIABLES
%       out    : Stego signal
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin < 4
	d0 = 150;     %Delay rate for bit0
	d1 = 200;     %Delay rate for bit1
end

if nargin < 5
	alpha = 0.5;  %Echo amplitude
end

if nargin < 6
	L = 8*1024;   %Length of frames
end

[s.len, s.ch] = size(signal);
bit = getBits(text);
nframe = floor(s.len/L);
N = nframe - mod(nframe,8);      %Number of frames (for 8 bit)

if (length(bit) > N)
	warning('Message is too long, being cropped!');
	bits = bit(1:N);
else
	warning('Message is being zero padded...');
	bits = [bit, num2str(zeros(N-length(bit), 1))'];
end

[echo_zro, echo_one] = np_echo(signal, d0, d1, alpha);  %Echo signals
mix = mixer(L, bits, 0, 1, 256) * ones(1, s.ch);        %Mixer signal

%%%%%%%%%%%%%%%%%%%%%%% EMBEDDING MESSAGE... %%%%%%%%%%%%%%%%%%%%%%%
out = signal(1:N*L, :) + echo_zro(1:N*L, :) .* abs(mix-1) ...
                       + echo_one(1:N*L, :) .* mix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out = [out; signal(N*L+1:s.len, :)];   %Rest of the signal
end
