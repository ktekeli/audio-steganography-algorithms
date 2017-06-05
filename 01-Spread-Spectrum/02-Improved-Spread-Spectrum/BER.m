function out = BER(hidden, retrieved)
%BER Bit Error Rate to measure error rate

y = getBits(hidden); x = getBits(retrieved);
len = min(length(x), length(y));   

ber = 0;
for i=1:len
    err = (x(i)~= y(i));
    ber = ber + err;
end
out = 100*(ber/len);
end