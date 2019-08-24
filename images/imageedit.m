% image preprocessing
% background 700~432
% target 300

image = imread('IMG_0669.jpg'); 
%image = imresize(image, 0.5);
image = imrotate(image, -90);

imshow(image); 
imwrite(image, 'IMG_0669.jpg'); 