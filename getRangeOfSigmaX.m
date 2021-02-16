function [largestSigma,smallestSigma] = getRangeOfSigmaX(char_scale, offset)

sigmaSet = exp(0.5:.2:3); %%%% assume that the size of the largest blob is about 120x120 - exp(3)*6+1
if (char_scale>offset)&&(char_scale<length(sigmaSet)-offset)
largestSigma = round(sigmaSet(char_scale+offset));
smallestSigma = round(sigmaSet(char_scale-offset));
elseif (char_scale<=offset)
    largestSigma = round(sigmaSet(char_scale+offset));
    smallestSigma = round(sigmaSet(1));
elseif (char_scale>=length(sigmaSet)-offset)
    largestSigma = round(sigmaSet(char_scale));
    smallestSigma = round(sigmaSet(char_scale-offset));
end
            