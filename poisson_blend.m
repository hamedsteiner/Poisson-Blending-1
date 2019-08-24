function imgout = poisson_blend(im_s, mask_s, im_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Poisson Blending                  %
%               - Suhong Kim -                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -----Input
% im_s     source image (object)
% mask_s   mask for source image (1 meaning inside the selected region)
% im_t     target image (background)
% -----Output
% imgout   the blended image

%test input
[imh, imw, nb] = size(im_s);

% (optional)make sure source and target has same dim (Execute one time)  
if size(im_s, 3) ~= size(im_t, 3)
    gray2rgb = @(g) cat(3, g, g, g);
    if size(im_s, 3) == 1, im_s = gray2rgb(im_s); end 
    if size(im_t, 3) == 1, im_t = gray2rgb(im_t); end
end
% (optional)Make sure mask has always 4 neighbors
mask = mask_s(:);
for p = 1:imh*imw
    if ((p == 1) || (p == imh) || (p == imh*imw-imh) || (p == imh*imw) ... % corner
        || (1 < p && p < imh) || ((imh*imw-imh) < p && p < imh*imw) ...    % hor edge
        || (mod(p,imh) == 1) || (mod(p, imh) == 0))                        % ver edge
        mask(p) = 0;
    end
end
mask_s = reshape(mask, [imh, imw]); 

%TODO: consider different channel numbers
disp(nb);
if nb > 1
    imgout(:,:,1:nb-1) = poisson_blend(im_s(:,:,1:nb-1), mask_s, im_t(:,:,1:nb-1)); 
end
im1d_s = im_s(:,:,nb); 
im1d_t = im_t(:,:,nb); 

%TODO: initialize counter, A (sparse matrix) and b.
%Note: A don't have to be k¡Ák,
%      you can add useless variables for convenience,
%      e.g., a total of imh*imw variables
n_pxl = imh*imw;
S = im1d_s(:);
T = im1d_t(:); 
M = mask_s(:); 

n_mask = sum(M>0);
i = zeros(1, n_mask*5); 
j = zeros(1, n_mask*5); 
v = zeros(1, n_mask*5);
b = zeros(n_mask, 1); 

% initialize before use
eq = 1;
idx_conv = zeros(1, n_pxl); % p_idx -> m_idx
for px =1:n_pxl 
    if M(px)==1  
        idx_conv(px) = eq; 
        eq = eq + 1; 
    end 
end 

%TODO: fill the elements in A and b, for each pixel in the image
e = 1;
for p = 1:n_pxl      
    % masked pixels
    if(M(p) == 1)
        % 4*v(x,y)
        b(e) = 4*S(p) - S(p+1) - S(p-1) - S(p+imh) - S(p-imh); 
        i(e) = e; j(e) = e; v(e) = 4;           
        
        % -1*v(x+1, y)
        if M(p+1) == 1  
            i(e+1*n_mask) = e;  j(e+1*n_mask) = idx_conv(p+1); v(e+1*n_mask) = -1;
        else
            i(e+1*n_mask) = e;  j(e+1*n_mask) = e;  v(e+1*n_mask) = 0; 
            b(e) = b(e) + T(p+1); 
        end
       
        % -1*v(x-1, y)
        if M(p-1) == 1  
            i(e+2*n_mask) = e;  j(e+2*n_mask) = idx_conv(p-1); v(e+2*n_mask) = -1;     
        else
            i(e+2*n_mask) = e;  j(e+2*n_mask) = e;  v(e+2*n_mask) = 0; 
            b(e) = b(e) + T(p-1); 
        end
        
        % -1*v(x, y+1)
        if M(p+imh) == 1  
            i(e+3*n_mask) = e;  j(e+3*n_mask) = idx_conv(p+imh); v(e+3*n_mask) = -1; 
        else
            i(e+3*n_mask) = e;  j(e+3*n_mask) = e;  v(e+3*n_mask) = 0; 
            b(e) = b(e) + T(p+imh); 
        end
        
        % -1*v(x, y-1)
        if M(p-imh) == 1  
            i(e+4*n_mask) = e;  j(e+4*n_mask) = idx_conv(p-imh); v(e+4*n_mask) = -1; 
        else
            i(e+4*n_mask) = e;  j(e+4*n_mask) = e;  v(e+4*n_mask) = 0;  
            b(e) = b(e) + T(p-imh); 
        end
        
        e = e + 1;
    end
end

%TODO: add extra constraints (if any)
%-----
%-----

%TODO: solve the equation
%use "lscov" or "\", please google the matlab documents
A = sparse(i, j, v); 
solution = A\b;
error = sum(abs(A*solution-b));
disp(error)

%TODO: copy those variable pixels to the appropriate positions
%      in the output image to obtain the blended image
poisson = zeros(1, n_pxl); 
for p = 1:n_pxl
    if idx_conv(p)> 0
        poisson(p) = solution(idx_conv(p)); 
    else
        poisson(p) = T(p); 
    end
end

imgout(:,:,nb) = reshape(poisson,[imh,imw]);
imwrite(imgout(:,:,nb), strcat('output_', int2str(nb), '.png'));

if nb == 3 
    imwrite(imgout, strcat('output', '.png'));
    subplot(2,2,1), imshow(im_s); title('source'); 
    subplot(2,2,2), imshow(im_t); title('destination'); 
    subplot(2,2,3), imshow(mask_s); 
    subplot(2,2,4), imshow(imgout); 
end

