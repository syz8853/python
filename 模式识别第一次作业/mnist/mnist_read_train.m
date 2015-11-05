clc;clear all;close all;

%------------------读取训练集数据--------------------
fid_train_img = fopen('train-images.idx3-ubyte', 'r');
title_info = fread(fid_train_img,16);

conv_coefs = [256^3; 256^2; 256^1; 1];
magic_num = title_info(1:4)' * conv_coefs;
image_num = title_info(5:8)' * conv_coefs;
row_num = title_info(9:12)' * conv_coefs;
col_num = title_info(13:16)' * conv_coefs;
pixel_num = row_num * col_num;
train_set = zeros(pixel_num, image_num);

for i = 1 : image_num
    train_set(:, i) = fread(fid_train_img,pixel_num,'uint8');    
end
fclose(fid_train_img);

fid_train_lable = fopen('train-labels.idx1-ubyte', 'r');
title_info2 = fread(fid_train_lable,8);
magic_num2 = title_info2(1:4)' * conv_coefs;
image_num2 = title_info2(5:8)' * conv_coefs;
train_lable = zeros(1, image_num2);

for i = 1:image_num2
    train_lable(i) = fread(fid_train_lable, 1, 'uint8');
end
fclose(fid_train_lable);
%------------------------读取训练数据完毕--------------



