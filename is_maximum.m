%
% Determines if a value is larger than its eight neighbors.
% 
% inputs:  
% -------
% im_in - a 3D input image
% i - the i index
% j - the j index
% k - the k index
%
% outputs:  
% --------
% is_max - true if the value is larger than its neighbors, false otherwise
%
function is_max = is_maximum(im_in, i, j, k)

    % By default, set the return value to false
    is_max = false;

    % Get the dimensions of the image
    [scale rows cols] = size(im_in);
    
    % Max sure we don't go out of bounds left or right
    j_minus_1 = max(1, j-1);
    j_plus_1 = min(rows, j+1);
    
    % Make sure we don't go out of bounds up and down
    k_minus_1 = max(1, k-1);
    k_plus_1 = min(cols, k+1);
    
    % Check all the neighbors
    if ((im_in(i,j,k) >= im_in(i, j, k_minus_1)) && (im_in(i,j,k) >= im_in(i, j, k_plus_1)) && ...
        (im_in(i,j,k) >= im_in(i, j_minus_1, k_minus_1)) && (im_in(i,j,k) >= im_in(i, j_plus_1, k_plus_1)) && ...
        (im_in(i,j,k) >= im_in(i, j_minus_1, k_plus_1)) && (im_in(i,j,k) >= im_in(i, j_plus_1, k_minus_1)))
    
        is_max = true;
       
    end
    
end