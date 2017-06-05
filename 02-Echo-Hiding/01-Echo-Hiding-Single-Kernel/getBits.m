function bin_seq = getBits(text)
matrix  = dec2bin(uint8(text),8);
bin_seq = reshape(matrix', 1, 8*length(text));
end