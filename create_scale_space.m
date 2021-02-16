function [scale_space1, char_scale, eng_scale]= create_scale_space(im_in, sigma)

    [rows cols] = size(im_in);
    %%%% might output the upper-bound normalized scale space representation
    % outputPath = 'C:\Users\hkong\myWork2011\TMI_blob\TestImages\Fluorescence Images\original_Images\small\';
    

    im_in_cpy = im_in*255;
    adaThr = adaptiveThreholding1(im_in_cpy,0);
    binaryImage = (im_in_cpy>adaThr+10)/255;


    % Allocate space to store all images in scale space
    scale_space = zeros(length(sigma), rows, cols);
    scale_space1 = zeros(length(sigma), rows, cols);
    % Create all the Laplacian of Gaussian images
    for i=1:length(sigma)
                      
        % Construct the laplacian of gaussian for a given kernel size and sigma
        n = ceil(sigma(i)*3)*2+1;
        lap_gauss = fspecial('log', n, sigma(i));
        
        % Convolve the kernel with the image
        convolved = conv2(double(im_in).*(sigma(i)^2), double(lap_gauss), 'same');   %%%% for some applications, might replace "im_in" by "binaryImage" for better performance
        convolved1 = conv2(double(im_in).*(sigma(i)^2), double(lap_gauss), 'same');
        
        
        % Store the image in our scale space array
        scale_space(i,:,:) = convolved;
        scale_space1(i,:,:) = convolved1;
    end



%%%%%% the first method for deciding the characteristic scales
scale_space_normalized = zeros(rows, cols, length(sigma));
for i=1:length(sigma)
    scale_space_normalized(:,:,i) = scale_space(i,:,:);
end
global_maxVal = max(max(max(scale_space_normalized)));

eng_scale = zeros(length(sigma),1);
for i=1:length(sigma)
    minVal = min(min(scale_space_normalized(:,:,i)));
    scale_space_normalized(:,:,i) = round((scale_space_normalized(:,:,i)-minVal)*255/(global_maxVal-minVal));
    % outputName = [outputPath,'scale_space_nz_',num2str(i),'_sigma',num2str(sigma(i)),'.tif'];
    % imwrite(uint8(scale_space_normalized(:,:,i)),outputName,'tif');
    adaThr_tmp = 160; 
    binaryImg_tmp = (scale_space_normalized(:,:,i)>adaThr_tmp);
    tmpImg = scale_space_normalized(:,:,i);
    eng_scale(i) = sum(sum(tmpImg(binaryImg_tmp>0))); 
end
char_scale = find(eng_scale==max(eng_scale));


