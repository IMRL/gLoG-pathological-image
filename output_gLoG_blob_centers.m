function output_gLoG_blob_centers(maximaLoc, outputImg, label, outputPath)

[yy,xx] = find(maximaLoc>0);
        
imgH = size(outputImg,1);
imgW = size(outputImg,2);

for i=1:length(yy)
    if (yy(i)>3)&&(yy(i)<imgH-3)&&(xx(i)>3)&&(xx(i)<imgW-3)
        outputImg(yy(i)-3:yy(i)+3, xx(i), 1) = 0;
        outputImg(yy(i), xx(i)-3:xx(i)+3, 1) = 0;
        outputImg(yy(i)-3:yy(i)+3, xx(i), 2) = 255;
        outputImg(yy(i), xx(i)-3:xx(i)+3, 2) = 255;
        outputImg(yy(i)-3:yy(i)+3, xx(i), 3) = 0;
        outputImg(yy(i), xx(i)-3:xx(i)+3, 3) = 0;
    end
end

if strcmp(label, 'bright')==1  
    outputFileName = [outputPath,'_blobCenters_bright.tif']; 
    imwrite(uint8(outputImg), outputFileName, 'tif');

    outputFileName = [outputPath,'_blobCenters_bright.mat'];
    coord = [yy xx];
    save(outputFileName, 'coord', '-mat');
elseif strcmp(label, 'dark')==1
    outputFileName = [outputPath,'_blobCenters_dark.tif']; 
    imwrite(uint8(outputImg), outputFileName, 'tif');

    outputFileName = [outputPath,'_blobCenters_dark.mat'];
    coord = [yy xx];
    save(outputFileName, 'coord', '-mat');
    
end