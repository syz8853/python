close all;

delta =  train_kk_labled(:,12,4);
delta = delta * 40 + 128;

ccd = reshape(delta(1:784), [28,28]);

ccm = uint8(ccd');
imshow(ccc);