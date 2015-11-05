% Matlab_Read_train_labels_idx1.m
% 用于读取MNIST数据集中train-labels.idx1-ubyte文件并将其转换成txt格式文件输出。
% 用法：运行程序，会弹出选择选择训练图片数据文件train-labels.idx1-ubyte路径的对话框
% 和保存训练图片标签数据文件(txt格式)路径的对话框，选择路径后程序自动运行完毕，期间进度条会显示处理进度。
% 整个程序运行过程需约3分钟时间。
% Written By DXY@HUST IPRAI
% 2009-2-22
clear all;
clc;
%读取训练图片标签数据文件
[FileName1,PathName1] = uigetfile('*.*','选择训练图片数据文件train-labels.idx1-ubyte');
InFile = fullfile(PathName1,FileName1);
fid1 = fopen(InFile,'r');
a = fread(fid1,8,'uint8');
MagicNum = ((a(1)*256+a(2))*256+a(3))*256+a(4);
ImageNum = ((a(5)*256+a(6))*256+a(7))*256+a(8);
if ((MagicNum~=2049)||(ImageNum~=60000))
    error('不是 MNIST train-labels.idx1-ubyte 文件！');
    fclose(fid1);    
    return;    
end
%保存训练图片标签数据文件txt格式
[FileName2,PathName2] = uiputfile('训练图片标签数据.txt','保存训练图片标签数据txt文件');
OutFile = fullfile(PathName2,FileName2);
fid2 = fopen(OutFile,'w');
h_w = waitbar(0,'请稍候，处理中>>');
for i=1:ImageNum
    b = fread(fid1,1,'uint8');    
    fprintf(fid2,'%d\n',b);
    waitbar(i/ImageNum);
end
fclose(fid1);
fclose(fid2);
close(h_w);
    