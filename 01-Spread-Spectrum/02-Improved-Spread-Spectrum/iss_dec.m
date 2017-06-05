function str = iss_dec(signal, L_msg, L_min)
%ISS_DEC decoding function for Improved Spread Spectrum.
%
%   INPUTS VARIABLES
%       signal : Stego audio signal
%       L_msg  : Length of message
%       L_min  : Minimum value for segment length
%
%   OUTPUTS VARIABLES
%       str    : Retrieved text message
%
%   20170420 - Kadir Tekeli (kadir_tekeli@hotmail.com)

if nargin < 3
    L_min = 1024;
end

s.data = signal(:,1);          %First channel of stego audio file
s.len  = length(s.data);
L2 = floor(s.len/L_msg);
L  = max(L_min, L2);
nframe = floor(s.len/L);
N = nframe - mod(nframe, 8);

xsig = reshape(s.data(1:N*L,1), L, N);  %Divide audio signal into segments

r = ones(L,1);
%r = prng('password123', L);       %Generating same pseudo random sequence

data = num2str(zeros(N,1))';
for k=1:N  
    c(k)=sum(xsig(:,k).*r)/L;   %Linear correlation
    if c(k)<0
        data(k) = '0';
    else
        data(k) = '1';
    end      
end

bin = reshape(data(1:N), 8, N/8)';
str = char(bin2dec(bin))';
end

function out = prng( key, L )
    pass = sum(double(key).*(1:length(key)));
    rand('seed', pass);
    out = 2*(rand(L, 1)>0.5)-1;
end
