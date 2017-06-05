function graph( plain, stego, bit, datasig, window, N, L )

bits = str2num(reshape(bit, N, 1))';

figure('Name','Data Bits','NumberTitle','off')
stairs(bits,'linewidth',1);
axis([0 length(bit) -0.2 1.2]);
grid minor;

figure('Name','Direct Sequence Spread Spectrum','NumberTitle','off')
subplot(2,1,1);
plot(datasig); axis([0 N*L -2 2]); grid minor;
title('Spread spectrum with data bits');

subplot(2,1,2);
plot(window); axis([0 N*L -2 2]); grid minor;
title('Hanning windowed data signal');

figure('Name','Audio Signals','NumberTitle','off')
subplot(2,1,1);
plot(plain(1:N*L,1)); axis([0 N*L -2 2]);
title('Plain signal');

subplot(2,1,2);
plot(stego(1:N*L,1)); axis([0 N*L -2 2]);
title('Stego signal');

t = floor(N/2);
figure('Name',['Segment: ' num2str(t)],'NumberTitle','off')
subplot(2,1,1);
plot(plain(t*L+1:(t+1)*L, 1)); axis([0 L -2 2]);
title('Plain signal');

subplot(2,1,2);
plot(stego(t*L+1:(t+1)*L, 1)); axis([0 L -2 2]);
title('Stego signal');

end

