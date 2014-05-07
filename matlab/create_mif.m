s = sprintf('bruce');
img = imread(s,'bmp');
t = [s,'.mif'];
file = fopen(t,'w');

fprintf(file,'WIDTH=24;\n'); %number of bits per entry
fprintf(file,'DEPTH=115304;\n'); %number of addreses. for 80x480 =, for 406x284
fprintf(file,'\n');
fprintf(file,'ADDRESS_RADIX=UNS;\n');
fprintf(file,'DATA_RADIX=UNS;\n');
fprintf(file,'\n');
fprintf(file,'CONTENT BEGIN\n');

addr = 0;
for i=1:284
    for j=1:406
        r = uint32(img(i,j,1));
        g = uint32(img(i,j,2));
        b = uint32(img(i,j,3));
        pixel = bitor(bitor(bitshift(r,16),bitshift(g,8)),b);
        fprintf(file,'\t%d     :   %d;\n',addr,pixel);
        addr = addr + 1;
    end
end

fprintf(file,'END;\n');
fclose(file);