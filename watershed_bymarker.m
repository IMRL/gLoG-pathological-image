function [watershedImage_blobMarker, watershedImage_blobMarker1] = watershed_bymarker(imgColor, maximaLoc, binaryImage, watershed_line_color, smallestCellSize)
imgH = size(imgColor,1);
imgW = size(imgColor,2);

%%%% fill holes whose size is smaller than 150
binaryImage = bwareaopen(binaryImage, smallestCellSize, 4);

bw = binaryImage;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% using boundary as
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% marker 

%%% apply watershed transformation
distMap = bwdist(~bw);
%% distMap_nm = scaleNormalization(distMap,0,255);

D = imcomplement(distMap);
%% D_nm = scaleNormalization(D,0,255);
%% imwrite(uint8(D_nm),[imPath,name1,'\',str,'_distMap_nm_neg_withFilter.tif'],'tif');

%%% suppress insignificant minima
D = imhmin(D, 2);
%% D_nm1 = scaleNormalization(D,0,255);

mask = ones(size(D));
mask(watershed(D)==0)=0;
%%% separate the regions
mask = 1-mask;
mask = mask & bw;
bw = edge(bw);
bw = mask | bw;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% using blob center as
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% marker 

[yy,xx] = find(maximaLoc>0);

D = bwdist(maximaLoc);
% D = imcomplement(distMap);
D = imhmin(D, 2);
mask = ones(size(D));
mask(watershed(D)==0)=0;
mask = 1-mask;
mask1 = mask;
mask = mask & binaryImage;

bw = edge(binaryImage);

bw = mask | bw;

bw1 = mask1;
watershedImage_blobMarker = imgColor;
if strcmp(watershed_line_color,'red')==1
    watershedImage_blobMarker(:,:,1) = watershedImage_blobMarker(:,:,1).*(1-bw) + bw*255;
    watershedImage_blobMarker(:,:,2) = watershedImage_blobMarker(:,:,2).*(1-bw);
    watershedImage_blobMarker(:,:,3) = watershedImage_blobMarker(:,:,3).*(1-bw);
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 1) = 255;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 1) = 255;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 2) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 2) = 0;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
        end
    end
    
elseif strcmp(watershed_line_color,'green')==1
    watershedImage_blobMarker(:,:,1) = watershedImage_blobMarker(:,:,1).*(1-bw);
    watershedImage_blobMarker(:,:,2) = watershedImage_blobMarker(:,:,2).*(1-bw) + bw*255;
    watershedImage_blobMarker(:,:,3) = watershedImage_blobMarker(:,:,3).*(1-bw);
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 2) = 255;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 2) = 255;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
        end
    end
elseif strcmp(watershed_line_color,'blue')==1
    watershedImage_blobMarker(:,:,1) = watershedImage_blobMarker(:,:,1).*(1-bw);
    watershedImage_blobMarker(:,:,2) = watershedImage_blobMarker(:,:,2).*(1-bw);
    watershedImage_blobMarker(:,:,3) = watershedImage_blobMarker(:,:,3).*(1-bw) + bw*255;
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 2) = 0;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 2) = 0;
            watershedImage_blobMarker(yy(i)-2:yy(i)+2, xx(i), 3) = 255;
            watershedImage_blobMarker(yy(i), xx(i)-2:xx(i)+2, 3) = 255;
        end
    end
end

watershedImage_blobMarker1 = imgColor;
if strcmp(watershed_line_color,'red')==1
    watershedImage_blobMarker1(:,:,1) = watershedImage_blobMarker1(:,:,1).*(1-bw1) + bw1*255;
    watershedImage_blobMarker1(:,:,2) = watershedImage_blobMarker1(:,:,2).*(1-bw1);
    watershedImage_blobMarker1(:,:,3) = watershedImage_blobMarker1(:,:,3).*(1-bw1);
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 1) = 255;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 1) = 255;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 2) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 2) = 0;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
        end
    end
elseif strcmp(watershed_line_color,'green')==1
    watershedImage_blobMarker1(:,:,1) = watershedImage_blobMarker1(:,:,1).*(1-bw1);
    watershedImage_blobMarker1(:,:,2) = watershedImage_blobMarker1(:,:,2).*(1-bw1) + bw1*255;
    watershedImage_blobMarker1(:,:,3) = watershedImage_blobMarker1(:,:,3).*(1-bw1);
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 2) = 255;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 2) = 255;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 3) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 3) = 0;
        end
    end
elseif strcmp(watershed_line_color,'blue')==1
    watershedImage_blobMarker1(:,:,1) = watershedImage_blobMarker1(:,:,1).*(1-bw1);
    watershedImage_blobMarker1(:,:,2) = watershedImage_blobMarker1(:,:,2).*(1-bw1);
    watershedImage_blobMarker1(:,:,3) = watershedImage_blobMarker1(:,:,3).*(1-bw1) + bw1*255;
    for i=1:length(yy)
        if (yy(i)>2)&(yy(i)<imgH-2)&(xx(i)>2)&(xx(i)<imgW-2)
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 1) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 1) = 0;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 2) = 0;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 2) = 0;
            watershedImage_blobMarker1(yy(i)-2:yy(i)+2, xx(i), 3) = 255;
            watershedImage_blobMarker1(yy(i), xx(i)-2:xx(i)+2, 3) = 255;
        end
    end
end


