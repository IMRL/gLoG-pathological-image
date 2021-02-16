function outputDetectedBlobs_byLoG(blobs, blobs_trimmed, imgOut, label, outputPath)


imgOut1 = imgOut;
imgOut_blobCenters = imgOut;
imgOut_blobCenters1 = imgOut;
imgH1 = size(imgOut,1);
imgW1 = size(imgOut,2);

blobCenters = zeros(length(blobs),2);
blobCenters_trimmed = zeros(length(blobs_trimmed),2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% output the blobs and blob centers before trimming
for i=1:length(blobs)

    blob_info = blobs{i};
    blobCenters(i,1) = blob_info(1);
    blobCenters(i,2) = blob_info(2);
    [circy circx] = create_circle(blob_info(1), blob_info(2), 1.5*blob_info(3));

    numOfPts = length(circx);
    circy = round(circy);
    circx = round(circx);
    circy = min(circy,repmat(imgH1, 1, numOfPts));
    circy = max(circy,ones(1, numOfPts));
    circx = min(circx,repmat(imgW1, 1, numOfPts));
    circx = max(circx,ones(1, numOfPts));

    for j=1:numOfPts
        imgOut(circy(j),circx(j),1) = 0;
        imgOut(circy(j),circx(j),2) = 255;
        imgOut(circy(j),circx(j),3) = 0;
    end


    if (blob_info(1)>3)&&(blob_info(1)<imgH1-3)&&(blob_info(2)>3)&&(blob_info(2)<imgW1-3)
        imgOut_blobCenters(blob_info(1)-3:blob_info(1)+3, blob_info(2), 1) = 0;
        imgOut_blobCenters(blob_info(1), blob_info(2)-3:blob_info(2)+3, 1) = 0;
        imgOut_blobCenters(blob_info(1)-3:blob_info(1)+3, blob_info(2), 2) = 255;
        imgOut_blobCenters(blob_info(1), blob_info(2)-3:blob_info(2)+3, 2) = 255;
        imgOut_blobCenters(blob_info(1)-3:blob_info(1)+3, blob_info(2), 3) = 0;
        imgOut_blobCenters(blob_info(1), blob_info(2)-3:blob_info(2)+3, 3) = 0;
    end

end


%%%%%%%% output
if strcmp(label, 'bright')==1
    outputFileName = [outputPath,'_blobCenters_cirLoG_bright.mat'];
    coord = blobCenters;
    save(outputFileName, 'coord', '-mat');

    outputFileName = [outputPath,'_blobs_cirLoG_bright.tif']; 
    imwrite(uint8(imgOut), outputFileName, 'tif');

    outputFileName = [outputPath,'_blobCenters_cirLoG_bright.tif']; 
    imwrite(uint8(imgOut_blobCenters), outputFileName, 'tif');
elseif strcmp(label, 'dark')==1
    outputFileName = [outputPath,'_blobCenters_cirLoG_dark.mat'];
    coord = blobCenters;
    save(outputFileName, 'coord', '-mat');

    outputFileName = [outputPath,'_blobs_cirLoG_dark.tif']; 
    imwrite(uint8(imgOut), outputFileName, 'tif');

    outputFileName = [outputPath,'_blobCenters_cirLoG_dark.tif']; 
    imwrite(uint8(imgOut_blobCenters), outputFileName, 'tif');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% output the blobs and blob centers after trimming
radius_after_trimming = zeros(length(blobs_trimmed),1);
for i=1:length(blobs_trimmed)

    blob_info = blobs_trimmed{i};
    blobCenters_trimmed(i,1) = blob_info(1);
    blobCenters_trimmed(i,2) = blob_info(2);
    radius_after_trimming(i) = blob_info(3);
    [circy circx] = create_circle(blob_info(1), blob_info(2), 1.5*blob_info(3));

    numOfPts = length(circx);
    circy = round(circy);
    circx = round(circx);
    circy = min(circy,repmat(imgH1, 1, numOfPts));
    circy = max(circy,ones(1, numOfPts));
    circx = min(circx,repmat(imgW1, 1, numOfPts));
    circx = max(circx,ones(1, numOfPts));
    for j=1:numOfPts
        imgOut1(circy(j),circx(j),1) = 0;
        imgOut1(circy(j),circx(j),2) = 255;
        imgOut1(circy(j),circx(j),3) = 0;
    end

    if (blob_info(1)>3)&&(blob_info(1)<imgH1-3)&&(blob_info(2)>3)&&(blob_info(2)<imgW1-3)
        imgOut_blobCenters1(blob_info(1)-3:blob_info(1)+3, blob_info(2), 1) = 0;
        imgOut_blobCenters1(blob_info(1), blob_info(2)-3:blob_info(2)+3, 1) = 0;
        imgOut_blobCenters1(blob_info(1)-3:blob_info(1)+3, blob_info(2), 2) = 255;
        imgOut_blobCenters1(blob_info(1), blob_info(2)-3:blob_info(2)+3, 2) = 255;
        imgOut_blobCenters1(blob_info(1)-3:blob_info(1)+3, blob_info(2), 3) = 0;
        imgOut_blobCenters1(blob_info(1), blob_info(2)-3:blob_info(2)+3, 3) = 0;
    end
end

if strcmp(label, 'bright')==1
    outputFileName = [outputPath,'_blobCenters_cirLoG_bright_aftrim.mat'];
    coord = blobCenters_trimmed;
    save(outputFileName, 'coord', '-mat');
    outputFileName = [outputPath,'_blobs_cirLoG_bright_aftrim.tif']; 
    imwrite(uint8(imgOut1), outputFileName, 'tif');
    outputFileName = [outputPath,'_blobCenters_cirLoG_bright_aftrim.tif']; 
    imwrite(uint8(imgOut_blobCenters1), outputFileName, 'tif');
elseif strcmp(label, 'dark')==1
    outputFileName = [outputPath,'_blobCenters_cirLoG_dark_aftrim.mat'];
    coord = blobCenters_trimmed;
    save(outputFileName, 'coord', '-mat');
    outputFileName = [outputPath,'_blobs_cirLoG_dark_aftrim.tif']; 
    imwrite(uint8(imgOut1), outputFileName, 'tif');
    outputFileName = [outputPath,'_blobCenters_cirLoG_dark_aftrim.tif']; 
    imwrite(uint8(imgOut_blobCenters1), outputFileName, 'tif');
end
