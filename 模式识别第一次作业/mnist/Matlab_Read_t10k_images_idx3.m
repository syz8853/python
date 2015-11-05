% Matlab_Read_t10k-images_idx3.m
% ���ڶ�ȡMNIST���ݼ���t10k-images.idx3-ubyte�ļ�������ת����bmp��ʽͼƬ�����
% �÷������г��򣬻ᵯ��ѡ�����ͼƬ�����ļ�t10k-labels.idx1-ubyte·���ĶԻ����
% ѡ�񱣴����ͼƬ·���ĶԻ���ѡ��·��������Զ�������ϣ��ڼ����������ʾ������ȡ�
% ͼƬ��TestImage_00001.bmp��TestImage_10000.bmp�ĸ�ʽ������ָ��·����10000���ļ�ռ�ÿռ�39M����
% �����������й����輸����ʱ�䡣
% Written By DXY@HUST IPRAI
% 2009-2-22
clear all;
clc;
%��ȡѵ��ͼƬ�����ļ�
[FileName,PathName] = uigetfile('*.*','ѡ�����ͼƬ�����ļ�t10k-images.idx3-ubyte');
TrainFile = fullfile(PathName,FileName);
fid = fopen(TrainFile,'r');
a = fread(fid,16,'uint8');
MagicNum = ((a(1)*256+a(2))*256+a(3))*256+a(4);
ImageNum = ((a(5)*256+a(6))*256+a(7))*256+a(8);
ImageRow = ((a(9)*256+a(10))*256+a(11))*256+a(12);
ImageCol = ((a(13)*256+a(14))*256+a(15))*256+a(16);
if ((MagicNum~=2051)||(ImageNum~=10000))
    error('���� MNIST t10k-images.idx3-ubyte �ļ���');
    fclose(fid);    
    return;    
end
savedirectory = uigetdir('','ѡ�����ͼƬ·����');
h_w = waitbar(0,'���Ժ򣬴�����>>');
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
    