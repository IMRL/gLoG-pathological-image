function [threshold] = adaptiveThreholding1(img,considerZeros);

    [imgH, imgW] = size(img);

    iniT = mean(mean(img));
    
    
    
    lvPixelMean=0.0;
    hvPixelMean=0.0;

if considerZeros==1

    imgVector = reshape(img, imgH*imgW, 1);
    lvPixels = find(imgVector<iniT);  %% low-value pixels
    hvPixels = find(imgVector>=iniT);  %% high-value pixels

    lvPixelMean = mean(imgVector(lvPixels));
    hvPixelMean = mean(imgVector(hvPixels));

    T = (lvPixelMean + hvPixelMean)/2;

    T0 = 3;
    Tdiff = 0;
    if T>=iniT
        Tdiff = T-iniT;
    else
        Tdiff = iniT-T;
    end

    while Tdiff>=T0
       iniT = T;
       lvPixels = find(imgVector<iniT);  %% low-value pixels
       hvPixels = find(imgVector>=iniT);  %% high-value pixels

       lvPixelMean = mean(imgVector(lvPixels));
       hvPixelMean = mean(imgVector(hvPixels));
       T = (lvPixelMean + hvPixelMean)/2;

       if T>=iniT
           Tdiff = T-iniT;
       else
           Tdiff = iniT-T;
       end
    end

    threshold = T;
    
else
    
    imgVector = reshape(img, imgH*imgW, 1);
    lvPixels = find((imgVector<iniT)&(imgVector>0));  %% low-value pixels
    hvPixels = find(imgVector>=iniT);  %% high-value pixels

    lvPixelMean = mean(imgVector(lvPixels));
    hvPixelMean = mean(imgVector(hvPixels));

    T = (lvPixelMean + hvPixelMean)/2;

    T0 = 3;
    Tdiff = 0;
    if T>=iniT
        Tdiff = T-iniT;
    else
        Tdiff = iniT-T;
    end

    while Tdiff>=T0
       iniT = T;
       lvPixels = find((imgVector<iniT)&(imgVector>0));  %% low-value pixels
       hvPixels = find(imgVector>=iniT);  %% high-value pixels

       lvPixelMean = mean(imgVector(lvPixels));
       hvPixelMean = mean(imgVector(hvPixels));
       T = (lvPixelMean + hvPixelMean)/2;

       if T>=iniT
           Tdiff = T-iniT;
       else
           Tdiff = iniT-T;
       end
    end

    threshold = T;
    
end

threshold = threshold-5;