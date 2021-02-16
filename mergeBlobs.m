function newBlobList = mergeBlobs(blobList, imgH, imgW, kerSize, kNN)

iLabel = 1;

    numOfBlobs = size(blobList,1);
    %%% get the affinity matrix
    affinityMat = zeros(numOfBlobs,numOfBlobs);
    for i=1:numOfBlobs
        for j=1:numOfBlobs
            affinityMat(i,j) = sqrt((blobList(i,1)-blobList(j,1))^2 + (blobList(i,2)-blobList(j,2))^2);
        end
    end
    
    TobeMerged = [];
    blob1_is_larger = 0;
    blob2_is_larger = 0;
    numOfOverlaps = 0;
    
    newImgH = imgH;
    newImgW = imgW;
    newKerSize = kerSize;
    
    for i=1:numOfBlobs
        nullImage1 = zeros(newImgH,newImgW);
        h_gauss1 = elipGauss([blobList(i,3)*6+1,blobList(i,3)*6+1], blobList(i,3), blobList(i,4), blobList(i,5));
        h_gauss1 = scaleNormalization(h_gauss1,0,255);
        h_gauss_bin1 = (h_gauss1>25);
        [yyContour1, xxContour1] = find(h_gauss_bin1>0);
        yyContour1 = yyContour1-kerSize;
        xxContour1 = xxContour1-kerSize;
        for j=1:length(yyContour1)
            yyy = blobList(i,1)*2+yyContour1(j);
            xxx = blobList(i,2)*2+xxContour1(j);
            if (yyy>=1)&&(yyy<=newImgH)&&(xxx>=1)&&(xxx<=newImgW)
                nullImage1(yyy, xxx)=1;
            end
        end

        %%% find the k-nearest neighbors (k=8) of i-th blobs
        [sorted_dist, index_dist] = sort(affinityMat(i,:),'ascend');
        
        for j=2:kNN
            nullImage2 = zeros(newImgH,newImgW);
            h_gauss2 = elipGauss([blobList(index_dist(j),3)*6+1,blobList(index_dist(j),3)*6+1], blobList(index_dist(j),3), blobList(index_dist(j),4), blobList(index_dist(j),5));
            h_gauss2 = scaleNormalization(h_gauss2,0,255);
            h_gauss_bin2 = (h_gauss2>25);
            [yyContour2, xxContour2] = find(h_gauss_bin2>0);
            yyContour2 = yyContour2-kerSize;
            xxContour2 = xxContour2-kerSize;
            for jj=1:length(yyContour2)
                yyy = blobList(index_dist(j),1)*2+yyContour2(jj);
                xxx = blobList(index_dist(j),2)*2+xxContour2(jj);
                if (yyy>=1)&&(yyy<=newImgH)&&(xxx>=1)&&(xxx<=newImgW)
                    nullImage2(yyy, xxx)=1;
                end
            end
            sum_nullImage = sum(sum(nullImage1 & nullImage2));
            smaller_blobArea = min(sum(sum(nullImage1)), sum(sum(nullImage2)));
            bigger_blobArea = max(sum(sum(nullImage1)), sum(sum(nullImage2)));
            if ((sum_nullImage/smaller_blobArea>0.5)&&(abs(blobList(i,5)-blobList(index_dist(j),5))<0.1))||(sum_nullImage/smaller_blobArea>0.7)||((sum_nullImage/smaller_blobArea>0.2)&&(bigger_blobArea/smaller_blobArea>3))
                numOfOverlaps = numOfOverlaps+1;
                if numOfOverlaps==1
                    TobeMerged = [i,index_dist(j)];
                    if sum(sum(nullImage1))>=sum(sum(nullImage2))
                        blob1_is_larger = 1;
                    else
                        blob2_is_larger = 1;
                    end
                end
                if numOfOverlaps>1
                    break;
                end
            end
        end
        
        if numOfOverlaps>1
            break;
        end
    end
    
    %%% merge the two selected blobs
    if numOfOverlaps>=1
        if blob1_is_larger==1
            if TobeMerged(2)==numOfBlobs
                newBlobList = blobList(1:numOfBlobs-1, :);
            elseif TobeMerged(2)==1
                newBlobList = blobList(2:end, :);
            else
                newBlobList = [blobList(1:TobeMerged(2)-1, :); blobList(TobeMerged(2)+1:end, :)];
            end
        else
            if TobeMerged(1)==numOfBlobs
                newBlobList = blobList(1:numOfBlobs-1, :);
            elseif TobeMerged(1)==1
                newBlobList = blobList(2:end, :);
            else
                newBlobList = [blobList(1:TobeMerged(1)-1, :); blobList(TobeMerged(1)+1:end, :)];
            end
        end

        blobList = newBlobList;
        if numOfOverlaps>1
            newBlobList = mergeBlobs(blobList, imgH, imgW, kerSize, kNN);
        end
        
    else
        newBlobList = blobList;
    end
