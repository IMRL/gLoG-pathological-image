%
% Reduces the number of blobs based on overlapping regions.
% 
% inputs:  
% -------
% blobs_in - a cell array of blob information [x y sigma intensity]
% overlap_threshold - if the overlap of two circles represents a percentage
%                     of either circle that is larger than this threshold
%                     one of the blobs is removed from consideration.
%
% outputs:  
% --------
% blobs_out - an array of blobs [x y sigma intensity]
%
function blobs_out = prune_blobs(blobs_in, overlap_threshold)

    % Set default arguments
    if (nargin() < 2)
        overlap_threshold = 0.05;
    end
    
    % This array denotes the blobs that will be kept
    keep = ones(length(blobs_in),1);
    
    % Loop over all blobs
    for i=1:length(blobs_in)
        
        % Loop over all blobs
        for j=i:length(blobs_in);

            % If we are comparing a blob to itself, or one of the blobs
            % has already been discarded, continue to the next one
            if (i==j) || (keep(i) == false) || (keep(j) == false)
                continue;
            end
            
            % Pull blob info from the blob cell array
            blobi = blobs_in{i};
            blobj = blobs_in{j};
            
            % Extract scalar values from the blob info
            xi = blobi(1);  yi = blobi(2);  ri = blobi(3);
            xj = blobj(1);  yj = blobj(2);  rj = blobj(3);
            
            % Compute distance between centers
            d = sqrt((xj-xi).^2 + (yj-yi).^2);
            % Compute the area of the overlap between circles
            overlap_area = rj^2*acos((d^2+rj^2-ri^2)/(2*d*rj)) + ri^2*acos((d^2+ri^2-rj^2)/(2*d*ri)) - 0.5*sqrt((-d+ri-rj)*(-d-ri+rj)*(-d+ri+rj)*(d+ri+rj));
            % Compute the area of circle i
            areai = pi*ri^2;
            % Compute the area of circle j
            areaj = pi*rj^2;

            % Compute the max percentage of overlap
            overlap_percent = max(real(overlap_area)/areai, real(overlap_area)/areaj);

            % If the two circles overlap by too much, one has to go
            if (overlap_percent > overlap_threshold)
               
                % Keep the larger of the two
                if (blobi(4) > blobj(4))
                    keep(i) = 1;
                    keep(j) = 0;
                else
                    keep(i) = 0;
                    keep(j) = 1;
                end
                
            end
            
        end
        
    end
    
    % A cell array stores the kept blobs
    blobs_out = {};
    
    % Loop over all blobs
    for i=1:length(blobs_in)
       
        % Only keep the best blobs
        if (keep(i))
            blobs_out{end+1} = blobs_in{i};
        end
        
    end

end

