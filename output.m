source = imread('source.png'); 
clon = imread('cloning.png');
%clon = imresize(clon, [size(source,1), size(source,2)]);
fig = figure; 
set(gca, 'Visible', 'off')
subplot(2, 2, 1); imshow(source); title('Source');
subplot(2, 2, 2); imshow(im_background); title('Target');
subplot(2, 2, 3); imshow(clon); title('Cloning'); 
subplot(2, 2, 4); imshow(im_blend); title('Blending'); 
saveas(fig, 'poisson.png'); 