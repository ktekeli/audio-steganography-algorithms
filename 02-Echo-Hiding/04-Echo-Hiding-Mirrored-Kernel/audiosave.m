function audiosave(data, file, extention, value)
%AUDIOSAVE() is a combination of several audiowriters.
%   It supports .WAV .FLAC .MP3 .M4A .OGG .OGA types. AAC files will be
%   converted into MP3 format automatically if another output extention
%   is not defined.
%
%   INPUT VARIABLES:
%       data       : Data part of audio file
%       file       : file structre readed by audioload()
%                    It must contain file.fs, file.name and file.ext
%                    file.bitrate, file.nbit, file.quality will also be
%                    needed depending on file format.
%       extention  : This input is used for type conversations.
%                    e.g. extention = '.mp3'
%       value      : Stores bitrate information for MP3, M4A and AAC,
%                    bitpersample information for WAV and FLAC,
%                    quality information for OGG and OGA formats
%
%   USAGE OF CONVERSATIONS:
%       audiosave(file.data, file, '.mp3', 128) writes data
%           in mp3 file format with 128kbit bitrate.
%       audiosave(file.data, file, '.flac', 16) writes data
%           in flac file format with 16bit quantization.
%       audiosave(file.data, file, '.ogg', 75) writes data
%           in ogg file format with %75 quality.
%
%   Kadir Tekeli (kadir.tekeli@outlook.com)

if nargin > 2
    if ~isempty(strfind('.wav.flac', extention))
        file.ext = extention; file.nbit = value;
    elseif ~isempty(strfind('.mp3.m4a.aac', extention))
        file.ext = extention; file.bitrate = value;
    elseif ~isempty(strfind('.ogg.oga', extention))
        file.ext = extention; file.quality = value;
    else
        warning('Error in output format. Being saved as default!');
    end
end

type1 = '*.wav;'; type2 = '*.flac;'; type3 = '*.mp3;';
type4 = '*.aac; *.m4a;'; type5 = '*.ogg; *.oga';
m4abrate = [96 128 160 192];

if ~exist('audio_out/')
    mkdir('audio_out');
end

sName = ['audio_out/',file.name,'_stego',file.ext];

if ~isempty(strfind(type1, file.ext))
	audiowrite(sName, data, file.fs);
elseif ~isempty(strfind(type2, file.ext))
	audiowrite(sName, data, file.fs,'BitsPerSample',file.nbit);
elseif ~isempty(strfind(type3, file.ext))
	mp3write(data, file.fs, sName, ['-b ' num2str(file.bitrate)]);       
elseif ~isempty(strfind(type4, file.ext))
	if (file.ext == '.aac')
        warning('File is being saved in .m4a format!');
        sName = ['audio_out/',file.name,'_stego', '.m4a'];
	end
	[~,ind] = min(abs(m4abrate - file.bitrate));
	audiowrite(sName, data, file.fs,'BitRate',m4abrate(ind));
elseif ~isempty(strfind(type5, file.ext))
	audiowrite(sName, data, file.fs, 'Quality', file.quality);
else
	error('File format is not supported!');
end

end


%%%%%%%%%%%%%%%%% External functions to write mp3 files %%%%%%%%%%%%%%%%%%
function mp3write(D,SR,NBITS,FILE,OPTIONS)
% MP3WRITE   Write MP3 file by use of external binary
%   MP3WRITE(Y,FS,NBITS,FILE) writes waveform data Y to mp3-encoded
%     file FILE at sampling rate FS using bitdepth NBITS.  
%     The syntax exactly mirrors WAVWRITE.  NBITS must be 16.
%   MP3WRITE(Y,FS,FILE) assumes NBITS is 16
%   MP3WRITE(Y,FILE) further assumes FS = 8000.
%
%   MP3WRITE(..., OPTIONS) specifies additional compression control 
%     options as a string passed directly to the lame encoder
%     program; default is '--quiet -h' for high-quality model.
%
%   Example: 
%   To convert a wav file to mp3 (assuming the sample rate is 
%   supported):
%     [Y,FS] = wavread('piano.wav');
%     mp3write(Y,FS,'piano.mp3');
%   To force lame to use 160 kbps (instead of default 128 kbps)
%   with the default filename extension (mp3):
%     mp3write(Y,FS,'piano','--quiet -h -b 160');
%
%   Note: The actual mp3 encoding is done by an external binary, 
%     lame, which is available for multiple platforms.  Usable
%     binaries are available from:
%     http://labrosa.ee.columbia.edu/matlab/mp3read.html
%
%   Note: MP3WRITE will use the mex file popenw, if available, to
%     open a pipe to the lame encoder.  Otherwise, it will have to
%     write a large temporary file, then execute lame on that file.
%     popenw is available at: 
%       http://labrosa.ee.columbia.edu/matlab/popenrw.html
%     This is a nice way to save large audio files as the
%     incremental output of your code, but you'll have to adapt the
%     central loop of this function (rather than using it directly).
%
%   See also: mp3read, wavwrite, popenw.

% 2005-11-10 Original version
% 2007-02-04 Modified to exactly match wavwrite syntax, and to
%   automatically find architecture-dependent binaries.
% 2007-07-26 Writing of stereo files via tmp file fixed (thx Yu-ching Lin)
% 2016-02-02 wavread is updated to audioread, added input option 
%   for bitrate saving.
%
% $Header: /Users/dpwe/matlab/columbiafns/RCS/mp3write.m,v 1.2 2007/07/26 15:09:16 dpwe Exp $

% find our baseline directory
[path] = fileparts(which('mp3write'));

% %%%%% Directory for temporary file (if needed)
% % Try to read from environment, or use /tmp if it exists, or use CWD
tmpdir = getenv('TMPDIR');
if isempty(tmpdir) || exist(tmpdir,'file')==0
  tmpdir = '/tmp';
end
if exist(tmpdir,'file')==0
  tmpdir = '';
end
% ensure it exists
%if length(tmpdir) > 0 && exist(tmpdir,'file')==0
%  mkdir(tmpdir);
%end

%%%%%% Command to delete temporary file (if needed)
rmcmd = 'rm';

%%%%%% Location of the binary - attempt to choose automatically
%%%%%% (or edit to be hard-coded for your installation)
ext = lower(computer);
if ispc
  ext = 'exe';
  rmcmd = 'del';
end
lame = fullfile(path,['/mp3bin/lame.',ext]);

%%%% Process input arguments
% Do we have NBITS?
mynargin = nargin;
if ischar(NBITS)
  % NBITS is a string i.e. it's actually the filename
  if mynargin > 3
    OPTIONS = FILE;
  end
  FILE = NBITS;
  NBITS = 16;
  % it's as if NBITS had been specified...
  mynargin = mynargin + 1;
end

if mynargin < 5
  OPTIONS = '--quiet -h';  % -h means high-quality psych model
end

[nr, nc] = size(D);
if nc < nr
  D = D';
  [nr, nc] = size(D);
end
% Now rows are channels, cols are time frames (so interleaving is right)

%%%%% add extension if none (like wavread)
[path,file,ext] = fileparts(FILE);
if isempty(ext)
  FILE = [FILE, '.mp3'];
end

nchan = nr;
nfrm = nc;

if nchan == 1
  monostring = ' -m m';
else
  monostring = '';
end

lameopts = [' ', OPTIONS, monostring, ' '];

%if exist('popenw') == 3
if length(which('popenw')) > 0

  % We have the writable stream process extensions
  cmd = ['"',lame,'"', lameopts, '-r -s ',num2str(SR),' - "',FILE,'"'];

  p = popenw(cmd);
  if p < 0
    error(['Error running popen(',cmd,')']);
  end

  % We feed the audio to the encoder in blocks of <blksize> frames.
  % By adapting this loop, you can create your own code to 
  % write a single, large, MP3 file one part at a time.
  
  blksiz = 10000;

  nrem = nfrm;
  base = 0;

  while nrem > 0
    thistime = min(nrem, blksiz);
    done = popenw(p,32767*D(:,base+(1:thistime)),'int16be');
    nrem = nrem - thistime;
    base = base + thistime;
    %disp(['done=',num2str(done)]);
  end

  % Close pipe
  popenw(p,[]);

else 
  disp('Warning: popenw not available, writing temporary file');
  
  tmpfile = fullfile(tmpdir,['tmp',num2str(round(1000*rand(1))),'.wav']);

  %wavwrite(D',SR,tmpfile);
  audiowrite(tmpfile,D',SR);
  
  cmd = ['"',lame,'"', lameopts, '"',tmpfile, '" "', FILE, '"'];

  mysystem(cmd);

  % Delete tmp file
  mysystem([rmcmd, ' "', tmpfile,'"']);

end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
function w = mysystem(cmd)
% Run system command; report error; strip all but last line
[s,w] = system(cmd);
if s ~= 0 
  error(['unable to execute ',cmd,' (',w,')']);
end
% Keep just final line
w = w((1+max([0,findstr(w,10)])):end);
% Debug
%disp([cmd,' -> ','*',w,'*']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%