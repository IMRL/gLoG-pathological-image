clear all; close all;
        
%%%%%% parameter setting
autoCharaScale = 0;


resizeImage = 1;  %%% for testing automatic scalability   
removeBoundaryBlobs=0;
useNonmaxsuppts = 0;
useLocalMaxima = 1-useNonmaxsuppts;
applying_watershed = 0;
eccentricityConstraint = 0;
withAnisodiff = 0;
useLogScaleNorm = 1;
alpha = 1;
sigmaStep = -1;
ellipGaussianIntensity = 25;

onlyDetectBlobCenters = 1;  %%% only detect centers, no shape and ori
detectDarkBlobs = 1; %%% only detect dark blobs
detectBrightBlobs = 1; %%% only detect bright blobs
detectAllBlobs = detectDarkBlobs && detectBrightBlobs; %%% detect both
outputLoGDetection = 1;
output_gLoG_detection=detectDarkBlobs && detectBrightBlobs;


%%%%% input and output paths      
imagePath = 'yourDir\images\';
outputPath = [imagePath,'outputDir\'];
if exist(outputPath,'dir')==0
    mkdir(outputPath);
end

for imageId = 1:500
    
    if imageId<10
        imageName = ['image','000', int2str(imageId), '.jpg'];
    elseif imageId<100
        imageName = ['image','00', int2str(imageId), '.jpg'];
    elseif imageId<1000
        imageName = ['image','0', int2str(imageId), '.jpg'];
    else
        imageName = ['image',int2str(imageId), '.jpg'];
    end
    

    imgColor=imread([imagePath,imageName]);    

    imgH = size(imgColor,1);
    imgW = size(imgColor,2);
    if size(imgColor,3) ==3
        imgR = imgColor(:,:,1);
        imgG = imgColor(:,:,2);
        imgB = imgColor(:,:,3);
    else
        imgR = imgColor;
        imgColor = zeros(imgH, imgW, 3);
        imgColor(:,:,1) = imgR;
        imgColor(:,:,2) = imgR;
        imgColor(:,:,3) = imgR;
    end
    
    %%%%% preprocessing the input image
    disp('preprocessing input image.................................');
    if detectBrightBlobs == 1
        [grayImage, grayImageCpy, binaryImage] = preprocessImage(imgColor, withAnisodiff, 'bright', outputPath);
    end
    if detectDarkBlobs == 1
        [grayImage_Neg, grayImageCpy_Neg, binaryImage_Neg] = preprocessImage(imgColor, withAnisodiff, 'dark', outputPath);
    end
    
    
    disp('calculate characteristic scale (for both bright and dark blobs) of input image.................................');
    %%%%% compute the characteristic scale by LoG detector and output blobs by LoG method
    if autoCharaScale==1
        if detectBrightBlobs == 1
            %%%%% get the char scale for bright regions
            [charaScale_bright,blobs_bright,blobs_trimmed_bright] = calculateCharaScale(grayImage);
            %%%%% get the sigma range (largest and smallest sigma_x) for sigma_x
            [largestSigma_bright,smallestSigma_bright] = getRangeOfSigmaX(charaScale_bright,4)
            %%%%% output the detected bright blobs by LoG (before and after trimming)
            if outputLoGDetection==1
                outputDetectedBlobs_byLoG(blobs_bright, blobs_trimmed_bright, imgColor, 'bright', outputPath);
            end
        end
        if detectDarkBlobs == 1
            %%%%% get the char scale for dark regions
            [charaScale_dark,blobs_dark,blobs_trimmed_dark] = calculateCharaScale(grayImage_Neg);
            %%%%% get the sigma range (largest and smallest sigma_x) for sigma_x
            [largestSigma_dark,smallestSigma_dark] = getRangeOfSigmaX(charaScale_dark,4)
            %%%%% output the detected dark blobs by LoG (before and after trimming)
            if outputLoGDetection==1
                outputDetectedBlobs_byLoG(blobs_dark, blobs_trimmed_dark, imgColor, 'dark', outputPath);
            end
        end
        
        %%%%% if the sigma step used for convolution is 2 or -2, we should
        %%%%% make the following sigma upper and lower bounds to be even
        %%%%% numbers.
        
%         if mod(largestSigma_bright,2)~=0
%             largestSigma_bright = largestSigma_bright-1;
%         end
%         if mod(smallestSigma_bright,2)~=0
%             if (smallestSigma_bright-1>0)
%                 smallestSigma_bright = smallestSigma_bright-1;
%             else
%                 smallestSigma_bright = smallestSigma_bright+1;
%             end           
%         end
%         if mod(largestSigma_dark,2)~=0
%             largestSigma_dark = largestSigma_dark-1;
%         end
%         if mod(smallestSigma_dark,2)~=0
%             if (smallestSigma_dark-1>0)
%                 smallestSigma_dark = smallestSigma_dark-1;
%             else
%                 smallestSigma_dark = smallestSigma_dark+1;
%             end  
%         end
    else
        %%% manually set scale parameters
        largestSigma_bright = 8; %16;
        smallestSigma_bright = 2; % 4;
        largestSigma_dark = 8; % 16;
        smallestSigma_dark = 2; % 4;
    end
    
%     [largestSigma_bright,smallestSigma_bright]
%     [largestSigma_dark,smallestSigma_dark]
    
    %%%%%% parameter settings
    if detectDarkBlobs == 1
        kerSize_dark = largestSigma_dark*4;
    end
    if detectBrightBlobs == 1
        kerSize_bright = largestSigma_bright*4;
    end
    maxNumOfBlobs = 10000;
    localMaxThr = 60;
    pi = 3.14159;
    thetaStep = 3.14159/9;

    if detectBrightBlobs == 1
        [filterScales_bright]=set_gLoG_kernels(smallestSigma_bright,largestSigma_bright,sigmaStep,thetaStep);
        numOfFilters_bright = size(filterScales_bright,1);
    end
    if detectDarkBlobs == 1
        [filterScales_dark]=set_gLoG_kernels(smallestSigma_dark,largestSigma_dark,sigmaStep,thetaStep);
        numOfFilters_dark = size(filterScales_dark,1);
    end
    
    %%%%% processing dark blobs
    if detectDarkBlobs == 1
        disp('start detecting dark blobs................................');
        [blobCenters_dark, blobCenters_far_from_border_dark, blobShapes_dark, blobOri_dark, blobShapes_oo_dark, blobOri_oo_dark]=detectBlobs_gLoG(imgColor,grayImage_Neg,binaryImage_Neg,...
                                                                                        largestSigma_dark,smallestSigma_dark,filterScales_dark,sigmaStep,...
                                                                                        thetaStep, kerSize_dark, alpha, useLogScaleNorm, applying_watershed,...
                                                                                        'dark', localMaxThr, maxNumOfBlobs, onlyDetectBlobCenters, outputPath);
    end
    
    if detectBrightBlobs == 1
        disp('start detecting bright blobs................................');
        [blobCenters_bright, blobCenters_far_from_border_bright, blobShapes_bright, blobOri_bright, blobShapes_oo_bright, blobOri_oo_bright]=detectBlobs_gLoG(imgColor,grayImage,binaryImage,...
                                                                                        largestSigma_bright,smallestSigma_bright,filterScales_bright,sigmaStep,...
                                                                                        thetaStep, kerSize_bright, alpha, useLogScaleNorm, applying_watershed,...
                                                                                        'bright', localMaxThr, maxNumOfBlobs, onlyDetectBlobCenters, outputPath);
    end
    %%%%%%% combine the detected bright and dark blobs and output results
    if output_gLoG_detection==1
        outputAllBobs(imgColor, blobCenters_dark, blobCenters_far_from_border_dark, blobShapes_dark, blobOri_dark, blobCenters_bright, blobCenters_far_from_border_bright, blobShapes_bright, blobOri_bright, onlyDetectBlobCenters, outputPath);
    end
    
    %%%%%%% blob-constrained watershed segmentation, call function watershed_bymarker.m
    
    
end