function [grayImage, grayImageCpy, binaryImage] = preprocessImage(imgColor,withAnisodiff,label,outputPath)

if strcmp(label, 'bright')==1
    imgGray = double(rgb2gray(uint8(imgColor)));
    adaThr = adaptiveThreholding1(imgGray,1);
    thr = adaThr;

    binaryImage = (imgGray>thr);  %%%% for bright blobs

    grayImage = imgGray; 
    grayImageCpy = imgGray;
    if withAnisodiff==1
        grayImage = anisodiff(grayImage, 10, 40, 0.25, 1);
        grayImageCpy = grayImage;
    end
    %outputFileName = [outputPath,'_anisodiff.tif']; 
    %imwrite(uint8(grayImage), outputFileName, 'tif');

elseif strcmp(label, 'dark')==1
    imgGray = 255-double(rgb2gray(uint8(imgColor)));
    adaThr = adaptiveThreholding1(imgGray,1);
    thr = adaThr;

    binaryImage = (imgGray>thr);

    grayImage = imgGray; 
    grayImageCpy = imgGray;
    if withAnisodiff==1
        grayImage = anisodiff(grayImage, 10, 40, 0.25, 1);
        grayImageCpy = grayImage;
    end
    %outputFileName = [outputPath,'_anisodiff_Neg.tif']; 
    %imwrite(uint8(grayImage), outputFileName, 'tif');
else
    error('label must be either bright or dark!');
end