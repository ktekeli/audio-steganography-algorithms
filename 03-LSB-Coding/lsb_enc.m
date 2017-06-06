function lsb_enc(wavin, wavout, text, pass)
%LSB_ENC LSB Coding technique for WAV files using one bit to hide
%
%   INPUT VARIABLES
%       wavin  : Path of cover signal (wav input)
%       wavout : Path of stego signal (wav output)
%       text   : Message to hide
%       pass   : Password for encryption
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if (nargin<2)
    wavout='stego.wav';
end

if (nargin<3)
    text = 'Text to be hidden';
end

if nargin<4
    pass = 'password123';    
end

%Header of wav = 1:40, Length of wav = 41:43, Data part = 44:end
fid = fopen(wavin,'r');
header = fread(fid,40,'uint8=>char');
dsize  = fread(fid,1,'uint32');
[cover,len_cover] = fread(fid,inf,'uint16');
fclose(fid);

bin   = d2b(double(text),8);
[m,n] = size(bin);
M     = d2b(m,40)';
len_msg = m*n;
%Encrypting message with pseudorandom sequence
bitx = 1*xor(reshape(bin,m*n,1), prng(pass, len_msg));
binx = reshape(bitx, m, n);

if (len_cover >= len_msg+48)
    %Control variable is encoded(1:8)
    control = d2b(mod(sum(double(pass)),256),8)';
    cover(1:8) = bitset(cover(1:8),1,control(1:8));
    %Length of message is encoded (9:48)
    cover(9:48) = bitset(cover(9:48),1,M(1:40));
    %Message is encoded (49:48+len)
    cover(49:48+len_msg)=bitset(cover(49:48+len_msg),1,binx(1:len_msg)');
    %Stego file is saved
    out = fopen(wavout,'w');
    fwrite(out,header,'uint8');
    fwrite(out,dsize,'uint32');
    fwrite(out,cover,'uint16');
    fclose(out);
else
    error('Message is too long!');
end
end

function b = d2b( d, n )
%D2B Minimal implentation of de2bi function
if nargin<2
    n = floor ( log (max (max (d), 1)) ./ log (p) ) + 1;
end
d = d(:);
power = ones (length (d), 1) * (2 .^ (0 : n-1) );
d = d * ones (1, n);
b = floor (rem(d, 2*power) ./ power);
end

function out = prng( key, L )
%PRNG Pseudorandom number generator for encryption/decryption
pass = sum(double(key).*(1:length(key)));
rand('seed', pass);
out = (rand(L, 1)>0.5);
end