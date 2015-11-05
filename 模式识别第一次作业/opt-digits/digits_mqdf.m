clc;close all; clear all;
Train = load('train.mat');
Test = load('test.mat');

Train_matrix = Train.optdigits;
train_set = (Train_matrix(:,1:64))';
train_lable = (Train_matrix(:, 65))';

Test_matrix = Test.optdigits;
test_set = (Test_matrix(:,1:64))';
test_lable = (Test_matrix(:, 65))';
%-----------------------------------
std_fea = std(train_set, 0, 2);

discard_fea = find(std_fea<2);
train_set(discard_fea, :) = [];

[n, m] = size(train_set); %m 样本数量，n单个样本向量的维数
train_set = train_set + 0.5- abs((rand(n,m) * 10));

train_set = (train_set - 8)/2;

 %------生成带类别标记的三维训练集数组
c_num = max(train_lable) - min(train_lable)+1;
train_set_labled = zeros(n + 1, m, c_num);
index_c = ones(1, c_num);
for i = 1:m
    c_temp = train_lable(i) + 1;
    
    train_set_labled(1:n, index_c(c_temp), c_temp) = train_set(:, i);
    train_set_labled(n +1, index_c(c_temp), c_temp) = 1;%样本有效标记
    index_c(c_temp) = index_c(c_temp) + 1;
end

k = 32; %设置k的数值，大于k时使用特征值替代
eig_values = zeros(n, c_num);
eig_mtr = zeros(n,n,c_num);
%-----------计算线性判别函数的参数(LDF)------------------------------
sample_num = zeros(1, c_num);
u = zeros(n, c_num);%各类的均值
sigma = zeros(n,n,c_num); %各类的协方差矩阵
sw = zeros(n,n);%全部类的协方差矩阵
pw = zeros(1, c_num);%先验概率 pw

for c = 1:c_num
    train_c = train_set_labled(:,:,c);%当前类别的所有样本
    tag_c = train_c(n + 1, :);
    num_tmp = find(tag_c<1);
    sample_num(c) = num_tmp(1) - 1; %求各类别样本的数目
    
    u_temp = sum(train_c, 2)/sample_num(c);%各列向量求和，之后计算平均向量
    u(:, c) = u_temp(1:n);
    
    sig_tmp = cov(train_c(1:n, 1:sample_num(c))');
    sigma(:,:, c) = sig_tmp; % 求各类别的协方差矩阵
    
    [phi, D, phiT] = svd(sig_tmp);
    eig_sig = diag(D);
    eig_sig(k+1:n) = eig_sig(k);
    eig_values(:,c) = eig_sig;
    eig_mtr(:,:,c) = phi;
    
end
test_set(discard_fea, :) = [];
test_set = (test_set - 8)/2;
[nt,mt] = size(test_set);
rst_class = zeros(c_num,mt);
u_I = ones(1,mt);
for c = 1:c_num
    u_c = u(:, c) * u_I;
    test_c = test_set - u_c;
    phi_c = eig_mtr(:,:,c);
    eig_cc = eig_values(:,c);
    eig_c = 1 ./ eig_values(:,c);
    rst_c = - (test_c' * phi_c) .^2 * eig_c - sum(log(eig_cc));
    rst_class(c, 1:mt) =rst_c;
end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind - 1; %得到所得的结果
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%求正确率
 fprintf('MQDF线性判别函数测试分类正确率是%.1f%%。\n', right_percent * 100);
 
 %-------------------------------------------------------------------------------
rst_class = zeros(c_num,m);
u_I = ones(1,m);
for c = 1:c_num
    u_c = u(:, c) * u_I;
    test_c = train_set - u_c;
    phi_c = eig_mtr(:,:,c);
    eig_cc = eig_values(:,c);
    eig_c = 1 ./ eig_values(:,c);
    rst_c = - (test_c' * phi_c) .^2 * eig_c - sum(log(eig_cc));
    rst_class(c, 1:m) =rst_c;
end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind - 1; %得到所得的结果
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%求正确率
 fprintf('MQDF线性判别函数训练分类正确率是%.1f%%。\n', right_percent * 100);
 
 
 