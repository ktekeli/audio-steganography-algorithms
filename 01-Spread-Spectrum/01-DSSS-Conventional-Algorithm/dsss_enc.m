function out = dsss_enc(signal, text, L_min, graf)
%DSSS_ENC is the function to hide data in audio using "conventional"
%   Direct Sequence Spread Spectrum technique in time domain. 
%
%   INPUTS VARIABLES
%       signal : Cover signal
%       text   : Message to hide
%       L_min  : Minimum segment length
%       graf   : Plots after processing (graf=0 not to plot)
%
%   OUTPUTS VARIABLES
%       out    : Stego signal
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin < 3
    L_min = 8*1024;  %Setting a minimum value for segment length
end

if nargin < 4
    graf = 1;
end

[s.len, s.ch] = size(signal);
bit = getBits(text);             %char -> binary sequence
L2  = floor(s.len/length(bit));  %Length of segments
L   = max(L_min, L2);            %Keeping length of segments big enough
nframe = floor(s.len/L);
N = nframe - mod(nframe, 8);     %Number of segments (for 8 bits)

if (length(bit) > N)
    warning('Message is too long, is being cropped...');
    bits = bit(1:N);
else
    bits = [bit, num2str(zeros(N-length(bit), 1))'];
end

%Note: Choose r = prng('password', L) to use a pseudo random sequence
r = ones(L,1);
%r = prng('password', L);                %Generating pseudo random sequence
pr = reshape(r * ones(1,N), N*L, 1);  %Extending size of r up to N*L
alpha = 0.005;                          %Embedding strength

%%%%%%%%%%%%%%%%%%%%%%% EMBEDDING MESSAGE... %%%%%%%%%%%%%%%%%%%%%%%%
[mix, datasig] = mixer(L, bits, -1, 1, 256);
out = signal;
stego = signal(1:N*L,1) + alpha * mix.*pr;     %Using first channel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out(:,1) = [stego; signal(N*L+1:s.len,1)];     %Adding rest of signal

if graf ~= 0
    graph(signal(:,1), out(:,1), bits, datasig, mix, N, L);
end

end

function out = prng( key, L )
    pass = sum(double(key).*(1:length(key)));
    rand('seed', pass);
    out = 2*(rand(L, 1)>0.5)-1;
end