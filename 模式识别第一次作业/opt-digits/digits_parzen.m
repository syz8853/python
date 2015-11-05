clc;close all; clear all;
Train = load('train.mat');
Test = load('test.mat');

Train_matrix = Train.optdigits;
train_set = (Train_matrix(:,1:64))';
train_lable = (Train_matrix(:, 65))';
train_lable = train_lable + 1;
% train_set(:,3824:3825) = train_set(:,1:2);
% train_lable(:,3824:3825) = train_lable(:,1:2);


std_fea = std(train_set, 0, 2);
std_off = 2;

discard_fea = find(std_fea<std_off);
train_set(discard_fea, :) = [];

[n,m] = size(train_set);

 for j = 1: n %对训练样本进行标准化
     
     fj = train_set(j,:);
     
     fj = (fj - mean(fj))/std(fj);
     train_set(j,:) = fj;
 end



Test_matrix = Test.optdigits;
test_set = (Test_matrix(:,1:64))';
test_lable = (Test_matrix(:, 65))';
test_lable = test_lable + 1;

test_set(discard_fea, :) = [];
[nt,mt] = size(test_set);
 for j = 1: n %对训练样本进行标准化
     
     fj = test_set(j,:);
     
     fj = (fj - mean(fj))/std(fj);
     test_set(j,:) = fj;
 end
% test_set(:,1798:1800) = test_set(:,1:3);
% test_lable(:,1798:1800) = test_lable(:,1:3);
%-----------------------------------------------

c_num = max(train_lable) - min(train_lable)+1;
train_set_labled = zeros(n + 1, m, c_num);
index_c = ones(1, c_num);

for i = 1:m
    c_temp = train_lable(i);
    
    train_set_labled(1:n, index_c(c_temp), c_temp) = train_set(:, i);
    train_set_labled(n +1, index_c(c_temp), c_temp) = 1;%样本有效标记
    index_c(c_temp) = index_c(c_temp) + 1;
end
 
x_Min = min(min(train_set)) - 250;
x_Max = max(max(train_set)) + 250;

x_Axis = x_Min:0.1:x_Max; 
sample_num = zeros(1, c_num);
h = 5;
PXM = zeros(length(x_Axis),n,c_num);
for h = 1:1

for c = 1:c_num
    train_c = train_set_labled(:,:,c);%当前类别的所有样本
    tag_c = train_c(n + 1, :);
    num_tmp = find(tag_c<1);
    sample_num(c) = num_tmp(1) - 1; %求各类别样本的数目
    train_ll = train_c(1:n, 1:sample_num(c));
    
    for feat = 1:n
        x = train_ll(feat,:)';
        px = Parzen(x, x_Axis, h);
        PXM(1:length(x_Axis),feat,c) = px(1:length(x_Axis));
    end
end
rst_class = zeros(c_num, mt);
pck = zeros(1, nt);
for c = 1:c_num
    pcx = PXM(:,:,c);
    for j = 1:mt
    x_c = test_set(:,j);
    for k = 1:nt
    pcf = pcx(:,k);
    pos_k = (x_c(k) - x_Min)/0.1 +1;
    pck(k) = pcf(int32(pos_k));
    end
    rst_class(c,j) = prod(pck);    
        
    end
end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind; %得到所得的结果
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%求正确率
 fprintf('Parzen分类对测试集正确率是%.1f%%。h =%f\n', right_percent * 100,h);
end


rst_class = zeros(c_num, m);
pck = zeros(1, n);

for c = 1:c_num
    pcx = PXM(:,:,c);
    for j = 1:m
    x_c = train_set(:,j);
    for k = 1:n
    pcf = pcx(:,k);
    pos_k = (x_c(k) - x_Min)/0.1 +1;
    pck(k) = pcf(int32(pos_k));
    end
    rst_class(c,j) = prod(pck);    
        
    end
end
[maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind; %得到所得的结果
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%求正确率
 fprintf('Parzen分类对训练集正确率是%.1f%%。h =%f\n', right_percent * 100,h);
 
 
 