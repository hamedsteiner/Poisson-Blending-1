clc;
clear;
close all;

im_background = im2double(imread('./images/black.jpg'));
im_object = im2double(imread('./images/bird.jpg'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (size(im_background, 3) == 1) || (size(im_object, 3) == 1)
    gray2rgb = @(g) cat(3, g, g, g);
    if size(im_background, 3) == 1, im_background = gray2rgb(im_background); end 
    if size(im_object, 3) == 1, im_object = gray2rgb(im_object); end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% get source region mask from the user
objmask = get_mask(im_object);

% align im_s and mask_s with im_background
[im_s, mask_s] = align_source(im_object, objmask, im_background);

% same var
%save('inputs.mat', 'im_s', 'mask_s', 'im_background'); 

% blend
disp('start');
im_blend = poisson_blend(im_s, mask_s, im_background);
disp('end');

imwrite(im_blend,'output.png');
figure(), hold off, imshow(im_blend);
