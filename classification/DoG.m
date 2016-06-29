function [dogImg] = DoG(img , k , sigma1, hsize)

    %k = 10;
    %sigma1 =  0.2;
    sigma2 = sigma1*k;
    %hsize = [3,3];
    h1 = fspecial('gaussian', hsize, sigma1);
    h2 = fspecial('gaussian', hsize, sigma2);
 
    

    gauss1 = imfilter(img,h1,'replicate');
    gauss2 = imfilter(img,h2,'replicate');

    dogImg = gauss1 - gauss2;
end