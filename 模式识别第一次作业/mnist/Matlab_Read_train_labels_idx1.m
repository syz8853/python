% Matlab_Read_train_labels_idx1.m
% ���ڶ�ȡMNIST���ݼ���train-labels.idx1-ubyte�ļ�������ת����txt��ʽ�ļ������
% �÷������г��򣬻ᵯ��ѡ��ѡ��ѵ��ͼƬ�����ļ�train-labels.idx1-ubyte·���ĶԻ���
% �ͱ���ѵ��ͼƬ��ǩ�����ļ�(txt��ʽ)·���ĶԻ���ѡ��·��������Զ�������ϣ��ڼ����������ʾ������ȡ�
% �����������й�����Լ3����ʱ�䡣
% Written By DXY@HUST IPRAI
% 2009-2-22
clear all;
clc;
%��ȡѵ��ͼƬ��ǩ�����ļ�
[FileName1,PathName1] = uigetfile('*.*','ѡ��ѵ��ͼƬ�����ļ�train-labels.idx1-ubyte');
InFile = fullfile(PathName1,FileName1);
fid1 = fopen(InFile,'r');
a = fread(fid1,8,'uint8');
MagicNum = ((a(1)*256+a(2))*256+a(3))*256+a(4);
ImageNum = ((a(5)*256+a(6))*256+a(7))*256+a(8);
if ((MagicNum~=2049)||(ImageNum~=60000))
    error('���� MNIST train-labels.idx1-ubyte �ļ���');
    fclose(fid1);    
    return;    
end
%����ѵ��ͼƬ��ǩ�����ļ�txt��ʽ
[FileName2,PathName2] = uiputfile('ѵ��ͼƬ��ǩ����.txt','����ѵ��ͼƬ��ǩ����txt�ļ�');
OutFile = fullfile(PathName2,FileName2);
fid2 = fopen(OutFile,'w');
h_w = waitbar(0,'���Ժ򣬴�����>>');
for i=1:ImageNum
    b = fread(fid1,1,'uint8');    
    fprintf(fid2,'%d\n',b);
    waitbar(i/ImageNum);
end
fclose(fid1);
fclose(fid2);
close(h_w);
    