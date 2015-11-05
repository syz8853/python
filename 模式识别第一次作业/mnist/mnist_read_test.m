fid_test_img = fopen('t10k-images.idx3-ubyte', 'r');
clear title_info magic_num image_num row_num col_num pixel_num
title_info = fread(fid_test_img,16);
conv_coefs = [256^3; 256^2; 256^1; 1];
magic_num = title_info(1:4)' * conv_coefs;
image_num = title_info(5:8)' * conv_coefs;
row_num = title_info(9:12)' * conv_coefs;
col_num = title_info(13:16)' * conv_coefs;
pixel_num = row_num * col_num;
test_set = zeros(pixel_num, image_num);

for i = 1 : image_num
    test_set(:, i) = fread(fid_test_img,pixel_num,'uint8');    
end
fclose(fid_test_img);

clear title_info2 magic_num2 image_num2
fid_test_lable = fopen('t10k-labels.idx1-ubyte', 'r');
title_info2 = fread(fid_test_lable,8);
magic_num2 = title_info2(1:4)' * conv_coefs;
image_num2 = title_info2(5:8)' * conv_coefs;
test_lable = zeros(1, image_num2);

for i = 1:image_num2
    test_lable(i) = fread(fid_test_lable, 1, 'uint8');
end
fclose(fid_test_lable);