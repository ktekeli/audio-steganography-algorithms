function out = phase_enc(signal, text, L)
%PHASE_ENC Phase Coding Technique to hide text messages within wav files.
%
%   INPUT VARIABLES
%       signal : Cover signal
%       text   : Message to hide
%       L      : Length of frames
%
%   OUTPUT VARIABLES
%       out    : Stego signal
%
%   This function code is based on the paper "Techniques for data hiding"
%   by Bender et al. (1996).
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin < 3
	L = 1024;
end

plain = signal(:,1);
data = getBits(text);
I = length(plain);
m = length(data);      % Length of bit sequence to hide
N = floor(I/L);        % Number of frames (for 8 bit)

s = reshape(plain(1:N*L,1), L, N);  % Dividing audio file into segments

w = fft(s);            % FFT of each segment
Phi = angle(w);        % Phases matrix including each segments
A = abs(w);            % Amplitude matrix including each segments

% Calculating phase differences of adjacent segments
DeltaPhi = zeros(L,N);
for k=2:N
	DeltaPhi(:,k)=Phi(:,k)-Phi(:,k-1); 
end

% Binary data is represented as {-pi/2, pi/2} and stored in PhiData
PhiData = zeros(1,m);
for k=1:m
	if data(k) == '0'
        PhiData(k) = pi/2;
    else
        PhiData(k) = -pi/2;
	end
end

% PhiData is written onto the middle of first phase matrix
Phi_new(:,1) = Phi(:,1);
Phi_new(L/2-m+1:L/2,1) = PhiData;             % Hermitian symmetry
Phi_new(L/2+1+1:L/2+1+m,1) = -flip(PhiData);  % Hermitian symmetry

% Re-creating phase matrixes using phase differences
for k=2:N
	Phi_new(:,k) = Phi_new(:,k-1) + DeltaPhi(:,k);
end

% Reconstructing the sound signal by applying the inverse FFT
z = real(ifft(A .* exp(1i*Phi_new)));    % Using Euler's formula
snew = reshape(z, N*L, 1);
out  = [snew; plain(N*L+1:I)];           % Adding rest of signal

end