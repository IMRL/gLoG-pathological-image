function [blobShapes, blobOri, blobShapes_oo, blobOri_oo] = estimate_gLoG_blobShape_Orientation(imgColor, imgGray, largestSigma, smallestSigma, blobCenters_far_from_border, filterScales, sigmaStep,...
                                                                thetaStep, kerSize, alpha, useLogScaleNorm, label, outputPath)
imgH = size(imgColor,1);
imgW = size(imgColor,2);
eccentricityConstraint=0;
ellipGaussianIntensity=25;

if size(imgColor,3) ==3
    blobImage = imgColor;
    blobImage_oo = imgColor;
    blobImage_merged = imgColor;
    blobImage_merged_interpo = imgColor;
else
    blobImage = zeros(imgH,imgW,3);
    blobImage(:,:,1) = imgColor;
    blobImage(:,:,2) = imgColor;
    blobImage(:,:,3) = imgColor;
    blobImage_oo = blobImage;
    blobImage_merged = blobImage;
    blobImage_merged_interpo = blobImage;
end

numOfFilters = size(filterScales,1);
responses100 = zeros(numOfFilters,1);  %%% to save the convolution response 


blobList = [];
blobList_oo = [];

sigmaStep_pos = -sigmaStep;
dumb1 = (largestSigma-smallestSigma)/sigmaStep_pos+1;
numOfOri = length([0: thetaStep : pi-thetaStep]);
specificOrientationResponse = zeros(dumb1,dumb1,numOfOri);  
half_kerSize = round(kerSize*0.5);

yy = blobCenters_far_from_border(:,1);
xx = blobCenters_far_from_border(:,2);



for i=1:length(yy)
    %%%%%%%% scale selection and orientation
    %%%%%% estimation

    indx = 0;
    for sigmaX = largestSigma : sigmaStep: smallestSigma
        for sigmaY = sigmaX : sigmaStep: smallestSigma
            if sigmaX==sigmaY
                for theta = 0: 0
                    indx = indx+1;
                    [h] = -elipLog([kerSize+1,kerSize+1], sigmaX, sigmaY, theta);
                    if useLogScaleNorm==1
                        tmpROI = imgGray(yy(i)-half_kerSize:yy(i)+half_kerSize, xx(i)-half_kerSize:xx(i)+half_kerSize); 
                        tmpResponse = (1+log(sigmaX^alpha))*(1+log(sigmaY^alpha))*imfilter(tmpROI,h,'replicate');
                        tmpResponse = tmpResponse(half_kerSize+1, half_kerSize+1);
                    else
                        tmpROI = imgGray(yy(i)-half_kerSize:yy(i)+half_kerSize, xx(i)-half_kerSize:xx(i)+half_kerSize);
                        tmpResponse = sigmaX*sigmaY*imfilter(tmpROI,h,'replicate');
                        tmpResponse = tmpResponse(half_kerSize+1, half_kerSize+1);
                    end
                    responses100(indx) = tmpResponse;
                    specificOrientationResponse((sigmaX-smallestSigma)/sigmaStep_pos+1,(sigmaY-smallestSigma)/sigmaStep_pos+1,1:numOfOri) = tmpResponse;

                end
            else
                for theta = 0: thetaStep : pi-thetaStep;
                    indx = indx+1;
                    [h] = -elipLog([kerSize+1,kerSize+1], sigmaX, sigmaY, theta);
                    if useLogScaleNorm==1
                        tmpROI = imgGray(yy(i)-half_kerSize:yy(i)+half_kerSize, xx(i)-half_kerSize:xx(i)+half_kerSize); 
                        tmpResponse = (1+log(sigmaX^alpha))*(1+log(sigmaY^alpha))*imfilter(tmpROI,h,'replicate');
                        tmpResponse = tmpResponse(half_kerSize+1, half_kerSize+1);
                    else
                        tmpROI = imgGray(yy(i)-half_kerSize:yy(i)+half_kerSize, xx(i)-half_kerSize:xx(i)+half_kerSize);
                        tmpResponse = sigmaX*sigmaY*imfilter(tmpROI,h,'replicate');
                        tmpResponse = tmpResponse(half_kerSize+1, half_kerSize+1);
                    end
                    responses100(indx) = tmpResponse;
                    specificOrientationResponse((sigmaX-smallestSigma)/sigmaStep_pos+1,(sigmaY-smallestSigma)/sigmaStep_pos+1,round(theta/thetaStep)+1) = tmpResponse;
                end
            end
        end
    end
    
    [sortedResponse, indexResponse] = sort(responses100,'descend');
    kernel_sel = filterScales(indexResponse(1),:);
    if eccentricityConstraint==1
        if kernel_sel(1)/kernel_sel(2)>=3.5
            kernel_sel(1)=2.5;
        end
    end
    blobList = [blobList; yy(i), xx(i), kernel_sel(1), kernel_sel(2), kernel_sel(3), responses100'];
    [h_gauss] = elipGauss([kernel_sel(1)*6+1,kernel_sel(1)*6+1], kernel_sel(1), kernel_sel(2), kernel_sel(3));
    h_gauss = scaleNormalization(h_gauss,0,255);
    h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);

    [yyContour, xxContour] = find(h_gauss_contour>0);
    yyContour = yyContour-round((kernel_sel(1)*6+1)/2);
    xxContour = xxContour-round((kernel_sel(1)*6+1)/2);
    for j=1:length(yyContour)
        yyy = yy(i)+yyContour(j);
        xxx = xx(i)+xxContour(j);
        if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
            blobImage(yyy, xxx, 1)=0;
            blobImage(yyy, xxx, 2)=255;
            blobImage(yyy, xxx, 3)=0;
        end
    end
    
    if (yy(i)>2)&&(yy(i)<imgH-2)&&(xx(i)>2)&&(xx(i)<imgW-2)
        blobImage(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
        blobImage(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
        blobImage(yy(i)-2:yy(i)+2, xx(i), 2) = 255;
        blobImage(yy(i), xx(i)-2:xx(i)+2, 2) = 255;
        blobImage(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
        blobImage(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
    end
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% compute shape and orientation based on another method

    tmpVal = zeros(numOfOri,1);
    for jj=1:numOfOri
        tmpVal(jj) = sum(sum(abs(specificOrientationResponse(:,:,jj))));
    end
    ori_sel = find(tmpVal==max(tmpVal));
    tttt = specificOrientationResponse(:,:,ori_sel);
    [scale_sel_x, scale_sel_y] = find(tttt==max(max(tttt)));
    tmp_scale_sel_x = (scale_sel_x(1)-1)*sigmaStep_pos+smallestSigma;
    tmp_scale_sel_y = (scale_sel_y(1)-1)*sigmaStep_pos+smallestSigma;

    if eccentricityConstraint==1
        if (tmp_scale_sel_x/tmp_scale_sel_y>=3.5)%% &&(scale_sel_y==1)
            scale_sel_x = 2.5;
            tmp_scale_sel_x = (scale_sel_x-1)*sigmaStep_pos+smallestSigma;
        end
    end
    blobList_oo = [blobList_oo; yy(i), xx(i), (ori_sel(1)-1)*thetaStep, tmp_scale_sel_x, tmp_scale_sel_y];

    [h_gauss] = elipGauss([tmp_scale_sel_x*6+1,tmp_scale_sel_x*6+1], tmp_scale_sel_x, tmp_scale_sel_y, (ori_sel(1)-1)*thetaStep);
    h_gauss = scaleNormalization(h_gauss,0,255);
    h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);

    [yyContour, xxContour] = find(h_gauss_contour>0);
    yyContour = yyContour-round((tmp_scale_sel_x*6+1)/2);
    xxContour = xxContour-round((tmp_scale_sel_x*6+1)/2);
    for j=1:length(yyContour)
        yyy = yy(i)+yyContour(j);
        xxx = xx(i)+xxContour(j);
        if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
            blobImage_oo(yyy, xxx, 1)=0;
            blobImage_oo(yyy, xxx, 2)=255;
            blobImage_oo(yyy, xxx, 3)=0;
        end
    end                                                                                                                                                                                                                                                                                                                                   
    if (yy(i)>2)&&(yy(i)<imgH-2)&&(xx(i)>2)&&(xx(i)<imgW-2)
        blobImage_oo(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
        blobImage_oo(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
        blobImage_oo(yy(i)-2:yy(i)+2, xx(i), 2) = 255;
        blobImage_oo(yy(i), xx(i)-2:xx(i)+2, 2) = 255;
        blobImage_oo(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
        blobImage_oo(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
    end

end  %%% end of <<for i=1:length(yy)>>
        
blobShapes = blobList(:,3:4);
blobOri = blobList(:,5);
blobShapes_oo = blobList_oo(:,4:5);
blobOri_oo = blobList_oo(:,3);


if strcmp(label, 'bright')==1
    outputFileName = [outputPath,'_blobImages_bright.tif']; 
    imwrite(uint8(blobImage), outputFileName, 'tif');
    %outputFileName = [outputPath,'_blobImages_oo_bright.tif']; 
    %imwrite(uint8(blobImage_oo), outputFileName, 'tif');
elseif strcmp(label, 'dark')==1
    outputFileName = [outputPath,'_blobImages_dark.tif']; 
    imwrite(uint8(blobImage), outputFileName, 'tif');
    %outputFileName = [outputPath,'_blobImages_oo_dark.tif']; 
    %imwrite(uint8(blobImage_oo), outputFileName, 'tif');
end


%{
disp('starting merging blobs..............................');
blobList_merged = mergeBlobs(blobList, imgH, imgW, kerSize, 8);
blobList_merged_interpo = blobList_merged;



for ii=1:size(blobList_merged,1)
    [h_gauss] = elipGauss([blobList_merged(ii, 3)*6+1,blobList_merged(ii, 3)*6+1], blobList_merged(ii, 3), blobList_merged(ii, 4), blobList_merged(ii, 5));
    h_gauss = scaleNormalization(h_gauss,0,255);
    h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);
    [labeled, numOfContours] = bwlabel(h_gauss_contour,8);
    if numOfContours==1
        [yyContour, xxContour] = find(h_gauss_contour>0);
        yyContour = yyContour-round((blobList_merged(ii, 3)*6+1)/2);
        xxContour = xxContour-round((blobList_merged(ii, 3)*6+1)/2);
        for jj=1:length(yyContour)
            yyy = blobList_merged(ii, 1)+yyContour(jj);
            xxx = blobList_merged(ii, 2)+xxContour(jj);
            if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
                blobImage_merged(yyy, xxx,1)=0;
                blobImage_merged(yyy, xxx,2)=255;
                blobImage_merged(yyy, xxx,3)=0;
            end
        end
    end
    tty = blobList_merged(ii, 1);
    ttx = blobList_merged(ii, 2);
    if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
        blobImage_merged(tty-2:tty+2, ttx, 1) = 0;
        blobImage_merged(tty, ttx-2:ttx+2, 1) = 0;
        blobImage_merged(tty-2:tty+2, ttx, 2) = 255;
        blobImage_merged(tty, ttx-2:ttx+2, 2) = 255;
        blobImage_merged(tty-2:tty+2, ttx, 3) = 0;
        blobImage_merged(tty, ttx-2:ttx+2, 3) = 0;
    end
    
    %%%%% find the largest response (with interpolation)
    if blobList_merged(ii, 3)==blobList_merged(ii, 4) %%% no need for angle interpolation
        interpolatedTheta = 0;
    else 
        sameSigmaIndx = find(filterScales(:,1)==blobList_merged(ii, 3) & filterScales(:,2)==blobList_merged(ii, 4));
        if length(sameSigmaIndx)>0
            responses100 = blobList_merged(ii, 6:end);
            [sortedResponse, indexResponse] = sort(responses100,'descend');
            sameSigmaResponse = responses100(sameSigmaIndx);
            [sorted_sameSigmaResponse, index_sameSigmaResponse] = sort(sameSigmaResponse,'descend');
            secondLargestResponseIndex = sameSigmaIndx(index_sameSigmaResponse(2));
            firstLargestResponseIndex = indexResponse(1);
            [firstLargestResponseIndex secondLargestResponseIndex];
            firstLargestResponse = sorted_sameSigmaResponse(1);
            secondLargestResponse = sorted_sameSigmaResponse(2);
            [firstLargestResponse secondLargestResponse]
            firstAngle = filterScales(firstLargestResponseIndex, 3);
            secondAngle = filterScales(secondLargestResponseIndex, 3);
            firstAngleIndegree = firstAngle*180/3.14
            secondAngleIndegree = secondAngle*180/3.14
            sigmaX = filterScales(firstLargestResponseIndex, 1);
            sigmaY = filterScales(firstLargestResponseIndex, 2);
            smallerSigma = min(sigmaX,sigmaY);
            biggerSigma = max(sigmaX,sigmaY);
            if (firstLargestResponse/secondLargestResponse<1.5)&&(biggerSigma/smallerSigma<2.5)  %%%%%%% 4
                if abs(firstLargestResponseIndex-secondLargestResponseIndex)>1 %%% 
                    if firstAngle==0
                        interpolatedVx = responses100(firstLargestResponseIndex)*cos(3.14) + responses100(secondLargestResponseIndex)*cos(secondAngle);
                        interpolatedVy = responses100(firstLargestResponseIndex)*sin(3.14) + responses100(secondLargestResponseIndex)*sin(secondAngle);
                        interpolatedTheta = atan(interpolatedVy/interpolatedVx);
                        if interpolatedTheta<0
                            interpolatedTheta = interpolatedTheta+3.14;
                        end
                    else
                        interpolatedVx = responses100(firstLargestResponseIndex)*cos(firstAngle) + responses100(secondLargestResponseIndex)*cos(3.14);
                        interpolatedVy = responses100(firstLargestResponseIndex)*sin(firstAngle) + responses100(secondLargestResponseIndex)*sin(3.14);
                        interpolatedTheta = atan(interpolatedVy/interpolatedVx);
                        if interpolatedTheta<0
                            interpolatedTheta = interpolatedTheta+3.14;
                        end
                    end

                else
                    interpolatedVx = responses100(firstLargestResponseIndex)*cos(firstAngle) + responses100(secondLargestResponseIndex)*cos(secondAngle);
                    interpolatedVy = responses100(firstLargestResponseIndex)*sin(firstAngle) + responses100(secondLargestResponseIndex)*sin(secondAngle);
                    interpolatedTheta = atan(interpolatedVy/interpolatedVx);
                    if interpolatedTheta<0
                        interpolatedTheta = interpolatedTheta+3.14;
                    end
                end
            else
                interpolatedTheta = firstAngle;
            end
            interpolatedThetaIndegree = interpolatedTheta*180/3.14

            blobList_merged_interpo(ii,5) = interpolatedTheta;
        end
    end

    [h_gauss] = elipGauss([blobList_merged(ii, 3)*6+1,blobList_merged(ii, 3)*6+1], blobList_merged(ii, 3), blobList_merged(ii, 4), blobList_merged_interpo(ii,5));
    h_gauss = scaleNormalization(h_gauss,0,255);
    h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);
    [labeled, numOfContours] = bwlabel(h_gauss_contour,8);
    if numOfContours==1
        [yyContour, xxContour] = find(h_gauss_contour>0);
        yyContour = yyContour-round((blobList_merged(ii, 3)*6+1)/2);
        xxContour = xxContour-round((blobList_merged(ii, 3)*6+1)/2);
        for jj=1:length(yyContour)
            yyy = blobList_merged(ii, 1)+yyContour(jj);
            xxx = blobList_merged(ii, 2)+xxContour(jj);
            if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
                blobImage_merged_interpo(yyy, xxx,1)=0;
                blobImage_merged_interpo(yyy, xxx,2)=255;
                blobImage_merged_interpo(yyy, xxx,3)=0;
            end
        end
        tty = blobList_merged(ii, 1);
        ttx = blobList_merged(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            blobImage_merged_interpo(tty-2:tty+2, ttx, 1) = 0;
            blobImage_merged_interpo(tty, ttx-2:ttx+2, 1) = 0;
            blobImage_merged_interpo(tty-2:tty+2, ttx, 2) = 255;
            blobImage_merged_interpo(tty, ttx-2:ttx+2, 2) = 255;
            blobImage_merged_interpo(tty-2:tty+2, ttx, 3) = 0;
            blobImage_merged_interpo(tty, ttx-2:ttx+2, 3) = 0;
        end
    end
end

if strcmp(label, 'bright')==1
    %%%% after merging blobs
    outputFileName = [outputPath,'_blobImage_merged_bright.tif']; 
    imwrite(uint8(blobImage_merged), outputFileName, 'tif');

    %%%% after merging and interpolation
    outputFileName = [outputPath,'_blobImage_merged_interpo_bright.tif']; 
    imwrite(uint8(blobImage_merged_interpo), outputFileName, 'tif');
elseif strcmp(label, 'dark')==1
    %%%% after merging blobs
    outputFileName = [outputPath,'_blobImage_merged_dark.tif']; 
    imwrite(uint8(blobImage_merged), outputFileName, 'tif');

    %%%% after merging and interpolation
    outputFileName = [outputPath,'_blobImage_merged_interpo_dark.tif']; 
    imwrite(uint8(blobImage_merged_interpo), outputFileName, 'tif');
end

%}
        