function [ w_sig, m_sig ] = mixer( L, bits, lower, upper, K )
%MIXER is the mixer signal to smooth data and spread it easier.
%
%   INPUTS VARIABLES
%       L     : Length of segment
%       bits  : Binary sequence (1xm char)
%       K     : Length to be smoothed
%       upper : Upper bound of mixer signal
%       lower : Lower bound of mixer signal
%
%   OUTPUTS VARIABLES
%       m_sig : Mixer signal to spread data
%       w_sig : Smoothed mixer signal
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if (nargin < 4)
    lower = 0;
    upper = 1;
end

if (nargin < 5) || (2*K > L)
	K = floor(L/4) - mod(floor(L/4), 4);
else
    K = K - mod(K, 4);                       %Divisibility by 4
end

N = length(bits);                            %Number of segments
encbit = str2num(reshape(bits, N, 1))';      %char -> double
m_sig  = reshape(ones(L,1)*encbit, N*L, 1);  %Mixer signal
c      = conv(m_sig, hanning(K));            %Hann windowing
wnorm  = c(K/2+1:end-K/2+1) / max(abs(c));   %Normalization
w_sig  = wnorm * (upper-lower)+lower;        %Adjusting bounds
m_sig  = m_sig * (upper-lower)+lower;        %Adjusting bounds

end

function out = hanning(L)
%HANNING() is a manual implentation of hanning window HANN() to be used
%   without Signal Processing Toolbox in MATLAB. Input must be a numeric 
%   greater than zero, so that a hanning window will be generated using  
%   input value as window length.
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if isnumeric(L)
    L = round(L);
    if L == 1
        out = 1;
    elseif L>1 || L==0
        n   = (0:L-1)';
        out = .5*(1-cos((2*pi*n)/(L-1)));
    else
        error('Input must be greater than zero!');
    end
else
    error('Input must be numeric!');
end
    
end