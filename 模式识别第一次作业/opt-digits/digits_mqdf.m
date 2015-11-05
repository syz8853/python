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

[n, m] = size(train_set); %m ����������n��������������ά��
train_set = train_set + 0.5- abs((rand(n,m) * 10));

train_set = (train_set - 8)/2;

 %------���ɴ�����ǵ���άѵ��������
c_num = max(train_lable) - min(train_lable)+1;
train_set_labled = zeros(n + 1, m, c_num);
index_c = ones(1, c_num);
for i = 1:m
    c_temp = train_lable(i) + 1;
    
    train_set_labled(1:n, index_c(c_temp), c_temp) = train_set(:, i);
    train_set_labled(n +1, index_c(c_temp), c_temp) = 1;%������Ч���
    index_c(c_temp) = index_c(c_temp) + 1;
end

k = 32; %����k����ֵ������kʱʹ������ֵ���
eig_values = zeros(n, c_num);
eig_mtr = zeros(n,n,c_num);
%-----------���������б����Ĳ���(LDF)------------------------------
sample_num = zeros(1, c_num);
u = zeros(n, c_num);%����ľ�ֵ
sigma = zeros(n,n,c_num); %�����Э�������
sw = zeros(n,n);%ȫ�����Э�������
pw = zeros(1, c_num);%������� pw

for c = 1:c_num
    train_c = train_set_labled(:,:,c);%��ǰ������������
    tag_c = train_c(n + 1, :);
    num_tmp = find(tag_c<1);
    sample_num(c) = num_tmp(1) - 1; %��������������Ŀ
    
    u_temp = sum(train_c, 2)/sample_num(c);%����������ͣ�֮�����ƽ������
    u(:, c) = u_temp(1:n);
    
    sig_tmp = cov(train_c(1:n, 1:sample_num(c))');
    sigma(:,:, c) = sig_tmp; % �������Э�������
    
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

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%����ȷ��
 fprintf('MQDF�����б������Է�����ȷ����%.1f%%��\n', right_percent * 100);
 
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

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%����ȷ��
 fprintf('MQDF�����б���ѵ��������ȷ����%.1f%%��\n', right_percent * 100);
 
 
 