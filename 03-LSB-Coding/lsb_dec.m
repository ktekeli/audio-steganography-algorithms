function out = lsb_dec( wavin, pass )
%LSB_DEC LSB Coding technique for WAV files using one bit to hide
%
%   INPUT VARIABLES
%       wavin : Path of stego signal (wav input)
%       pass  : Password for decryption
%
%   OUTPUT VARIABLES
%       out   : Retrieved message
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if (nargin<2)
    pass = 'password123';
end

%Header = 1:40, Length = 41:43, Data = 44:end
fid = fopen(wavin,'r'); 
header = fread(fid,40,'uint8=>char');
dsize  = fread(fid,1,'uint32');
stego  = fread(fid,inf,'uint16');
fclose(fid);
%Control variable is read (1:8)
control = bitget(stego(1:8),1)';

if b2d(control) == mod(sum(double(pass)),256)
    %Length of message is read (9:48)
    m = bitget(stego(9:48),1);
    len = b2d(m')*8;
    %Hidden message is read and decrypted (49:len)
    dat = xor(bitget(stego(49:48+len),1),prng(pass,len));
    bin = reshape(dat,len/8,8);
    out = char(b2d(bin))';
else
    warning('Password is wrong or message is corrupted!');
    out = [];
end
end

function d = b2d(b)
%B2D Minimal implentation of bi2de function
  if isempty(b)
    d = [];
  else   
    d = b * (2 .^ (0:length(b(1,:)) - 1)');
  end
end

function out = prng( key, L )
%PRNG Pseudorandom number generator for encryption/decryption
pass = sum(double(key).*(1:length(key)));
rand('seed', pass);
out = (rand(L, 1)>0.5);
end