function mask = get_mask(im)
% mask = getMask(im)
% Asks user to draw polygon around input image.
% Provides binary mask of polygon

disp('Select a region to copy.'); 
disp('You can click multiple times to specify the boundaries of your patch,'); 
disp('then press "Q" to get a closed patch.')
figure(1), hold off, imagesc(im), axis image;
[imh, imw, ~] = size(im);
sx = [];
sy = [];
while 1
    fig = figure(1);
    [x, y, b] = ginput(1);
    if b=='q' || b=='Q'
        set(gca, 'Visible', 'off');
        F= getframe(fig);
        img = F.cdata;
        imwrite(img, 'source.png');
        break;
    end
    if x<2
        x=2;
    end
    if y<2
        y=2;
    end
    if x>imw-1
        x=imw-1;
    end
    if y>imh-1
        y=imh-1;
    end
    sx(end+1) = x;
    sy(end+1) = y;
    hold on, plot(sx, sy, '*-');
end

mask = poly2mask(sx, sy, size(im, 1), size(im, 2));

end
