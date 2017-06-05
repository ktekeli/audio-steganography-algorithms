function str = dsss_dec(signal, L_msg, L_min)
%DSSS_DEC is the function to retrieve hidden text message back.
%
%   INPUTS VARIABLES
%       signal : Stego signal
%       L_msg  : Length of message
%       L_min  : Minimum value for segment length
%
%   OUTPUTS VARIABLES
%       str    : Retrieved message
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin < 3
    L_min = 8*1024;
end

s.len  = length(signal(:,1));
L2 = floor(s.len/L_msg);
L  = max(L_min, L2);           %Length of segments
nframe = floor(s.len/L);
N = nframe - mod(nframe, 8);   %Number of segments

xsig = reshape(signal(1:N*L,1), L, N);  %Divide signal into N segments

%Note: Choose r = prng('password', L) to use a pseudo random sequence
r = ones(L,1);
%r = prng('password', L);       %Generating same pseudo random sequence

data = num2str(zeros(N,1))';
c = zeros(1,N);
for k=1:N  
    c(k)=sum(xsig(:,k).*r)/L;   %Correlation
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
