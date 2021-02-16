function [filterScales]=set_gLoG_kernels(smallestSigma,largestSigma,sigmaStep,thetaStep)

filterScales = [];
for sigmaX = largestSigma : sigmaStep: smallestSigma;
    for sigmaY = sigmaX : sigmaStep: smallestSigma;
        if sigmaX==sigmaY
            for theta = 0: 0
                filterScales = [filterScales; sigmaX sigmaY theta];
            end
        else
            for theta = 0: thetaStep : pi-thetaStep
                filterScales = [filterScales; sigmaX sigmaY theta];
            end
        end
    end      
end