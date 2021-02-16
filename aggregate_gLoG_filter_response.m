function [aggregated_response] = aggregate_gLoG_filter_response(imageGray, largestSigma,smallestSigma,sigmaStep, thetaStep, kernelSize, alpha, useLogScaleNorm)

filterImage = zeros(size(imageGray));

for sigmaX = largestSigma : sigmaStep: smallestSigma;
    for sigmaY = sigmaX : sigmaStep: smallestSigma;

        if sigmaX==sigmaY
            for theta = 0: 0
                [h] = -elipLog([kernelSize+1,kernelSize+1], sigmaX, sigmaY, theta);
                if useLogScaleNorm==1
                    tmpImg = (1+log(sigmaX^alpha))*(1+log(sigmaY^alpha))*imfilter(imageGray,h,'replicate'); 
                else
                    tmpImg = sigmaX*sigmaY*imfilter(imageGray,h,'replicate');
                end
                filterImage = filterImage+tmpImg;
            end
        else
            for theta = 0: thetaStep : pi-thetaStep;
                [h] = -elipLog([kernelSize+1,kernelSize+1], sigmaX, sigmaY, theta);
                if useLogScaleNorm==1
                    tmpImg = (1+log(sigmaX^alpha))*(1+log(sigmaY^alpha))*imfilter(imageGray,h,'replicate'); 
                else
                    tmpImg = sigmaX*sigmaY*imfilter(imageGray,h,'replicate');
                end
                filterImage = filterImage+tmpImg;
            end
        end
    end
end

aggregated_response = filterImage;