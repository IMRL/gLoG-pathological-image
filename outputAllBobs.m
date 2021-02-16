function outputAllBobs(imgColor, dark_blob_centers, blobCenters_far_from_border_dark, blobShapes_dark, blobOri_dark,...
                        bright_blob_centers, blobCenters_far_from_border_bright, blobShapes_bright, blobOri_bright, onlyDetectBlobCenters, outputPath)
                
imgOut = imgColor;                        
imgH = size(imgColor,1);
imgW = size(imgColor,2);
ellipGaussianIntensity = 25;

imgOut1 = imgColor; 



if onlyDetectBlobCenters==1
    %%%%%% output dark blob centers
    for ii=1:size(dark_blob_centers,1)
        tty = dark_blob_centers(ii, 1);
        ttx = dark_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut1(tty-2:tty+2, ttx, 1) = 0;
            imgOut1(tty, ttx-2:ttx+2, 1) = 0;
            imgOut1(tty-2:tty+2, ttx, 2) = 255;
            imgOut1(tty, ttx-2:ttx+2, 2) = 255;
            imgOut1(tty-2:tty+2, ttx, 3) = 0;
            imgOut1(tty, ttx-2:ttx+2, 3) = 0;
        end
    end
    %%%%%% output bright blob centers
    for ii=1:size(bright_blob_centers,1)
        tty = bright_blob_centers(ii, 1);
        ttx = bright_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut1(tty-2:tty+2, ttx, 1) = 255;
            imgOut1(tty, ttx-2:ttx+2, 1) = 255;
            imgOut1(tty-2:tty+2, ttx, 2) = 0;
            imgOut1(tty, ttx-2:ttx+2, 2) = 0;
            imgOut1(tty-2:tty+2, ttx, 3) = 0;
            imgOut1(tty, ttx-2:ttx+2, 3) = 0;
        end
    end
    
    outputFileName = [outputPath,'_blobCenters_all.tif']; 
    imwrite(uint8(imgOut1), outputFileName, 'tif');
    
else
    
    
    %%%%%% output dark blob centers
    for ii=1:size(dark_blob_centers,1)
        tty = dark_blob_centers(ii, 1);
        ttx = dark_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut1(tty-2:tty+2, ttx, 1) = 0;
            imgOut1(tty, ttx-2:ttx+2, 1) = 0;
            imgOut1(tty-2:tty+2, ttx, 2) = 255;
            imgOut1(tty, ttx-2:ttx+2, 2) = 255;
            imgOut1(tty-2:tty+2, ttx, 3) = 0;
            imgOut1(tty, ttx-2:ttx+2, 3) = 0;
        end
    end
    %%%%%% output bright blob centers
    for ii=1:size(bright_blob_centers,1)
        tty = bright_blob_centers(ii, 1);
        ttx = bright_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut1(tty-2:tty+2, ttx, 1) = 255;
            imgOut1(tty, ttx-2:ttx+2, 1) = 255;
            imgOut1(tty-2:tty+2, ttx, 2) = 0;
            imgOut1(tty, ttx-2:ttx+2, 2) = 0;
            imgOut1(tty-2:tty+2, ttx, 3) = 0;
            imgOut1(tty, ttx-2:ttx+2, 3) = 0;
        end
    end
    
    
    dark_blob_centers = blobCenters_far_from_border_dark;
    bright_blob_centers = blobCenters_far_from_border_bright;
    
    %%%%%% output dark blobs
    for ii=1:size(dark_blob_centers,1)
        [h_gauss] = elipGauss([blobShapes_dark(ii, 1)*6+1,blobShapes_dark(ii, 1)*6+1], blobShapes_dark(ii, 1), blobShapes_dark(ii, 2), blobOri_dark(ii));
        h_gauss = scaleNormalization(h_gauss,0,255);
        h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);

        [yyContour, xxContour] = find(h_gauss_contour>0);
        yyContour = yyContour-round((blobShapes_dark(ii, 1)*6+1)/2);
        xxContour = xxContour-round((blobShapes_dark(ii, 1)*6+1)/2);
        for jj=1:length(yyContour)
            yyy = dark_blob_centers(ii, 1)+yyContour(jj);
            xxx = dark_blob_centers(ii, 2)+xxContour(jj);
            if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
                imgOut(yyy, xxx,1)=0;
                imgOut(yyy, xxx,2)=255;
                imgOut(yyy, xxx,3)=0;
            end
        end
        tty = dark_blob_centers(ii, 1);
        ttx = dark_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut(tty-2:tty+2, ttx, 1) = 0;
            imgOut(tty, ttx-2:ttx+2, 1) = 0;
            imgOut(tty-2:tty+2, ttx, 2) = 255;
            imgOut(tty, ttx-2:ttx+2, 2) = 255;
            imgOut(tty-2:tty+2, ttx, 3) = 0;
            imgOut(tty, ttx-2:ttx+2, 3) = 0;
        end

    end


    %%%%%% output bright blobs
    for ii=1:size(bright_blob_centers,1)
        [h_gauss] = elipGauss([blobShapes_bright(ii, 1)*6+1,blobShapes_bright(ii, 1)*6+1], blobShapes_bright(ii, 1), blobShapes_bright(ii, 2), blobOri_bright(ii));
        h_gauss = scaleNormalization(h_gauss,0,255);
        h_gauss_contour = edge(h_gauss>ellipGaussianIntensity);

        [yyContour, xxContour] = find(h_gauss_contour>0);
        yyContour = yyContour-round((blobShapes_bright(ii, 1)*6+1)/2);
        xxContour = xxContour-round((blobShapes_bright(ii, 1)*6+1)/2);
        for jj=1:length(yyContour)
            yyy = bright_blob_centers(ii, 1)+yyContour(jj);
            xxx = bright_blob_centers(ii, 2)+xxContour(jj);
            if (yyy>=1)&&(yyy<=imgH)&&(xxx>=1)&&(xxx<=imgW)
                imgOut(yyy, xxx,1)=255;
                imgOut(yyy, xxx,2)=0;
                imgOut(yyy, xxx,3)=0;
            end
        end
        tty = bright_blob_centers(ii, 1);
        ttx = bright_blob_centers(ii, 2);
        if (tty>2)&&(tty<imgH-2)&&(ttx>2)&&(ttx<imgW-2)
            imgOut(tty-2:tty+2, ttx, 1) = 255;
            imgOut(tty, ttx-2:ttx+2, 1) = 255;
            imgOut(tty-2:tty+2, ttx, 2) = 0;
            imgOut(tty, ttx-2:ttx+2, 2) = 0;
            imgOut(tty-2:tty+2, ttx, 3) = 0;
            imgOut(tty, ttx-2:ttx+2, 3) = 0;
        end

    end
    
    outputFileName = [outputPath,'_blobImage_all.tif']; 
    imwrite(uint8(imgOut), outputFileName, 'tif');

    outputFileName = [outputPath,'_blobCenters_all.tif']; 
    imwrite(uint8(imgOut1), outputFileName, 'tif');
end



