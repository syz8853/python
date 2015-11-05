% Matlab_Read_t10k-images_idx3.m
% 用于读取MNIST数据集中t10k-images.idx3-ubyte文件并将其转换成bmp格式图片输出。
% 用法：运行程序，会弹出选择测试图片数据文件t10k-labels.idx1-ubyte路径的对话框和
% 选择保存测试图片路径的对话框，选择路径后程序自动运行完毕，期间进度条会显示处理进度。
% 图片以TestImage_00001.bmp～TestImage_10000.bmp的格式保存在指定路径，10000个文件占用空间39M。。
% 整个程序运行过程需几分钟时间。
% Written By DXY@HUST IPRAI
% 2009-2-22
clear all;
clc;
%读取训练图片数据文件
[FileName,PathName] = uigetfile('*.*','选择测试图片数据文件t10k-images.idx3-ubyte');
TrainFile = fullfile(PathName,FileName);
fid = fopen(TrainFile,'r');
a = fread(fid,16,'uint8');
MagicNum = ((a(1)*256+a(2))*256+a(3))*256+a(4);
ImageNum = ((a(5)*256+a(6))*256+a(7))*256+a(8);
ImageRow = ((a(9)*256+a(10))*256+a(11))*256+a(12);
ImageCol = ((a(13)*256+a(14))*256+a(15))*256+a(16);
if ((MagicNum~=2051)||(ImageNum~=10000))
    error('不是 MNIST t10k-images.idx3-ubyte 文件！');
    fclose(fid);    
    return;    
end
savedirectory = uigetdir('','选择测试图片路径：');
h_w = waitbar(0,'请稍候，处理中>>');
for i=1:ImageNum
    b = fread(fid,ImageRow*ImageCol,'uint8');   
    c = reshape(b,[ImageRow ImageCol]);
    d = c';
    e = 255-d;
    e = uint8(e);
    savepath = fullfile(savedirectory,['TestImage_' num2str(i,'%05d') '.bmp']);
    imwrite(e,savepath,'bmp');
    waitbar(i/ImageNum);
end
fclose(fid);
close(h_w);
    