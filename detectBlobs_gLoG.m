function [blobCenters, blobCenters_far_from_border, blobShapes, blobOri, blobShapes_oo, blobOri_oo] = detectBlobs_gLoG(colorImage, grayImage,binaryImage,...
                                                                                                        largestSigma,smallestSigma,filterScales,sigmaStep,...
                                                                                                        thetaStep, kerSize, alpha, useLogScaleNorm, applying_watershed,...
                                                                                                        label, localMaxThr, maxNumOfBlobs, onlyDetectBlobCenters, outputPath)

imgH = size(grayImage,1);
imgW = size(grayImage,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% compute aggregated_response and output normalized aggregated_response
[aggregated_response] = aggregate_gLoG_filter_response(grayImage, largestSigma, smallestSigma, sigmaStep,...
                                                                thetaStep, kerSize, alpha, useLogScaleNorm);

[aggregated_response_norm] = scaleNormalization(aggregated_response, 0, 255);  
if strcmp(label, 'bright')==1                                                            
    outputFileName = [outputPath,'_responseSum_bright.tif']; 
    %imwrite(uint8(aggregated_response_norm), outputFileName, 'tif');
elseif strcmp(label, 'dark')==1
    outputFileName = [outputPath,'_responseSum_dark.tif']; 
    %imwrite(uint8(aggregated_response_norm), outputFileName, 'tif');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% find the blob locations
maximaLoc = zeros(imgH,imgW);
[zmax,imax,zmin,imin]= extrema2(aggregated_response_norm);
imax = imax(zmax>localMaxThr);

if length(imax)>maxNumOfBlobs
    imax = imax(1:maxNumOfBlobs);
   [ii,jj] = ind2sub(size(grayImage),imax);
   maximaLoc(sub2ind(size(grayImage), ii, jj)) = 1;
else
    [ii,jj] = ind2sub(size(grayImage),imax);
   maximaLoc(sub2ind(size(grayImage), ii, jj)) = 1;
end

%%%%------------------------------------------------
%%%% for some applications, this might be necessary
% maximaLoc = maximaLoc.*binaryImage;
%%%%------------------------------------------------


%%%% blob locations including the ones near borders
[yy,xx] = find(maximaLoc>0);
blobCenters = [yy xx];  

%%%%% output the image with detected blob centers highlighted
output_gLoG_blob_centers(maximaLoc, double(colorImage), label, outputPath);

%%%% blob locations excluding the ones near borders
half_KerSize = round(kerSize*0.5);
tmpH1 = round(yy)-half_KerSize;
tmpH2 = round(yy)+half_KerSize;
tmpW1 = round(xx)-half_KerSize;
tmpW2 = round(xx)+half_KerSize;
validIndx = find(tmpH1>=1 & tmpH2<=imgH & tmpW1>=1 & tmpW2<=imgW);
yy = yy(validIndx);
xx = xx(validIndx);
blobCenters_far_from_border = [yy xx];                                                                 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% output segmentation image based on blob-center constrained watershed
if applying_watershed==1
    disp('Applying marker-controlled watershed based on the the detected blob centers...................................................');
    [watershedImage_blobMarker, watershedImage_blobMarker1] = watershed_bymarker(double(colorImage), maximaLoc, binaryImage, 'green', 50);       

    if strcmp(label, 'bright')==1   
        outputFileName = [outputPath,'_watershedImage_blobMarker_bright.tif']; 
        %imwrite(uint8(watershedImage_blobMarker), outputFileName, 'tif');

        outputFileName = [outputPath,'_watershedImage_blobMarker1_bright.tif']; 
        imwrite(uint8(watershedImage_blobMarker1), outputFileName, 'tif');
    elseif strcmp(label, 'dark')==1
        outputFileName = [outputPath,'_watershedImage_blobMarker_dark.tif']; 
        %imwrite(uint8(watershedImage_blobMarker), outputFileName, 'tif');

        outputFileName = [outputPath,'_watershedImage_blobMarker1_dark.tif']; 
        imwrite(uint8(watershedImage_blobMarker1), outputFileName, 'tif');
    end
end                    

blobShapes = [];
blobOri = [];
blobShapes_oo = [];
blobOri_oo = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                                
%%%%% estimate blob shape and orientations
if onlyDetectBlobCenters~=1
    [blobShapes, blobOri, blobShapes_oo, blobOri_oo] = estimate_gLoG_blobShape_Orientation(double(colorImage), grayImage, largestSigma, smallestSigma, blobCenters_far_from_border, filterScales, sigmaStep,...
                                                                    thetaStep, kerSize, alpha, useLogScaleNorm, label, outputPath);
end


