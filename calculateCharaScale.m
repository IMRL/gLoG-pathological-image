function [char_scale,blobs,blobs_trimmed] = calculateCharaScale(grayImage)

grayImage_Neg = 255-grayImage;  %%% since the original LoG only detects dark blobs
[blobs, char_scale, eng_scale] = detect_blobs(grayImage_Neg, 0.05, 0.5:.2:3);  %%% set a smaller threhold to detect more isotropic blob, I set 0.1 for my applications
blobs_trimmed = prune_blobs(blobs, 0.25);
            
            
