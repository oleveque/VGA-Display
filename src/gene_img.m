close all; clear all;

filename = 'EPFL-color'; %image path
src = imread([filename, '.jpg']); %decompression

array = [];
for i = 1:size(src,1) %for each horizontal line
    disp(i);
    line = ['('];
    for j = 1:size(src,2) %for each pixel in the line
         R = double(src(i,j,1));
         G = double(src(i,j,2));
         B = double(src(i,j,3));
         line = [line, 'X"', dec2hex(65536*R + 256*G + B, 6), '"']; %extract the color pixel in hexa
         if j<size(src,2)
             line = [line, ','];
         end
    end
    line = [line, '),'];
    
    if isempty(array)
        array = line;
    else
        array = [array; line];
    end
end

dlmwrite([filename, '.txt'], array,'delimiter',''); %save in txt file
type([filename, '.txt']); %display the result