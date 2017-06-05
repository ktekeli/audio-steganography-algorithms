function out = iss_enc(signal, text, L_min, alpha, beta, gama)
%ISS_ENC is the function to hide data within audio using Improved
%   Spread Spectrum technique in time domain. 
%
%   INPUTS VARIABLES
%       signal : Cover signal
%       text   : Message to hide
%       L_min  : Minimum segment length
%       alpha  : Embedding parameter 1
%       beta   : Embedding parameter 2
%       gama   : Embedding parameter 3
%
%   OUTPUTS VARIABLES
%       out    : Stego signal
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)


if nargin < 3
    L_min = 1024;  % Setting a minimum value for segment length
end

if nargin < 4
    alpha = 0.005; beta = 1; gama = 0.5;
end

[s.len,s.ch] = size(signal);

bit = getBits(text);             
L2  = floor(s.len/length(bit)); 
L   = max(L_min, L2);              %Length of segments 
n   = floor(s.len/L);
N   = n - mod(n, 8);               %Number of segments
 
if (length(bit) > N)
    warning('Message is too long, being cropped...');
    bits=bit(1:N);
else
    bits=[bit, num2str(zeros(N-length(bit),1))'];
end

r = ones(L,1);
%r  = prng('password123',L);
pr = reshape(r*ones(1,N),N*L,1);
u  = alpha * pr;

out = signal;
ss = mixer(L,bits,-1,1);
iss = iss_improve(signal, N, L, alpha, r);

%%%%%%%%%%%%%%%%%%%%%%% EMBEDDING MESSAGE... %%%%%%%%%%%%%%%%%%%%%%%%
stego = signal(1:N*L,1) + (beta*ss - gama*iss).*u;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out(:,1) = [stego; signal(N*L+1:s.len,1)];
end

function out = prng( key, L )
    pass = sum(double(key).*(1:length(key)));
    rand('seed', pass);
    out = 2*(rand(L, 1)>0.5)-1;
end