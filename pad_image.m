%
% Pads an image with the desired value.
% 
% inputs:  
% -------
% im_in - the image to pad
% num_rows - the number of rows to add to the top and bottom
% num_cols - the number of cols to add to the left and right
% value - the value used for padding
%
% outputs:  
% --------
% im_out - the padded image
%
function im_out = pad_image(im_in, num_rows, num_cols, value)

    % Get the size of the image
    [rows cols] = size(im_in);
    % Create the new image with the desired value everywhere
    im_out = ones(rows+2*num_rows, cols+2*num_cols).*value;
    % Insert the input image into the center
    im_out(1+num_rows:rows+num_rows, 1+num_cols:cols+num_cols) = im_in;

end