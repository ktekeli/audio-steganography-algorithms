function  out = NC(hidden, retrieved)
%NC Normalized Correlation to measure error rate

y = getBits(hidden); x = getBits(retrieved);

xbit  = str2num(reshape(x, length(x), 1))';      % char -> double
ybit  = str2num(reshape(y, length(y), 1))';      % char -> double

L = min(length(x), length(y));
xbit = xbit(1:L); ybit = ybit(1:L);

s1 = sum(xbit.*ybit);
s2 = sqrt(sum(xbit.^2) * sum(ybit.^2));

out = s1 / s2;

end