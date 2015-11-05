clc;close all; clear all;
Train = load('train.mat');
Test = load('test.mat');

Train_matrix = Train.optdigits;
train_set = (Train_matrix(:,1:64))';
train_lable = (Train_matrix(:, 65))';
train_set(:,3824:3825) = train_set(:,1:2);
train_lable(:,3824:3825) = train_lable(:,1:2);
Test_matrix = Test.optdigits;
test_set = (Test_matrix(:,1:64))';
test_lable = (Test_matrix(:, 65))';
%-----------------------------------
std_fea = std(train_set, 0, 2);
discard_fea = find(std_fea<2);
train_set(discard_fea, :) = [];%ȥ��һЩ�仯�����Ե�����ά

[n, m] = size(train_set); %m ����������n��������������ά��

train_set = train_set + 0.5- abs((rand(n,m) * 10));%��ѵ��������һЩ������ֹЭ�����������
train_set = (train_set - 8)/2; %�����߶ȱ仯

%-------------------------------�������ѵ��������֤��---50000������ѵ���� 1���������֤ 
k =5;%K�۽�����֤�������зֳ�k ��

rand_colindex = randperm(m);
train_set_rand = train_set(:, rand_colindex);
train_lable_rand = train_lable(:, rand_colindex);

per_num = m/k;
verify_index = [1+(k-1)*per_num : k * per_num];
train_index = [1:m];
train_index(verify_index) = [];

train_kk = train_set_rand(:, train_index);
verify_kk = train_set_rand(:, verify_index);
tr_lable_kk = train_lable_rand(:, train_index);
vr_lable_kk = train_lable_rand(:, verify_index);

[nk, mk] = size(train_kk);

c_num = max(train_lable) - min(train_lable)+1;
train_kk_labled = zeros(nk + 1, mk, c_num);
index_c = ones(1, c_num);
for i = 1:mk
    c_temp = tr_lable_kk(i) + 1;
    
    train_kk_labled(1:nk, index_c(c_temp), c_temp) = train_kk(:, i);
    train_kk_labled(nk +1, index_c(c_temp), c_temp) = 1;%������Ч���
    index_c(c_temp) = index_c(c_temp) + 1;
end

 [nkt, mkt] = size(verify_kk);
cross_counter = 0;
for beta = 0.2:0.2
    for gama = 0.3:0.3
 %������֤for begin
 cross_counter = cross_counter + 1;
sample_num = zeros(1, c_num);
u = zeros(nk, c_num);
sigma = zeros(nk, nk, c_num);
sw = zeros(nk, nk);
pw = zeros(1, c_num);
tr_sigma = zeros(1, c_num);
for c = 1:c_num
    train_c = train_kk_labled(:, :, c);
    sample_num(c) = index_c(c) -1;
    u_temp = sum(train_c, 2)/sample_num(c);
    u(:, c) = u_temp(1 : nk);
    
%     std_train = std(train_c(1:nk, 1:sample_num(c)), 0, 2);
%     sig_diag = std_train.^2;
%     sig_tmp = diag(sig_diag);
    
    sig_tmp = cov(train_c(1:nk, 1:sample_num(c))');
    u(:, c) = u_temp(1:n);
    sigma(:,:,c) = sig_tmp;
    sw = sw + sample_num(c)/mk * sig_tmp;
    pw(c) = sample_num(c)/mk;
    tr_sigma(c) = sum(diag(sig_tmp));
end

    rst_class = zeros(c_num, mkt);
    u_I = ones(1, mkt);
    for c = 1:c_num
        u_c = u(:, c) * u_I;
        test_c = verify_kk - u_c;
        sig_c = sigma(:, :, c);
        sig_c = (1-gama) * ((1-beta) * sig_c + beta * sw) + gama * tr_sigma(c)/nk * eye(nk);
        rst_c = -log(det(sig_c)) - test_c'  /sig_c *test_c;
        rst_class(c, 1:mkt) = diag(rst_c);
    end

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = vr_lable_kk - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mkt;%����ȷ��
 fprintf('QDF�����б�����֤������ȷ����%.1f%%��gamma=%f beta=%f\n', right_percent * 100,gama,beta);
Gama_cross(cross_counter) = gama;
Beta_cross(cross_counter) = beta;
right_cross(cross_counter) = right_percent * 100;

% ������֤ for end
    end
end

%------------------------------��������

test_set(discard_fea, :) = [];
% test_set = 255 - test_set;%ȡ������ѵ��������һ��
test_set = (test_set - 8)/2;
[nt,mt] = size(test_set);

rst_class = zeros(c_num, mt);


    u_I = ones(1,mt);
    for c = 1:c_num
        u_c = u(:, c) * u_I;
        test_c = test_set - u_c;
        sig_c = sigma(:,:,c);
        sig_c = (1-gama) * ((1-beta) * sig_c + beta * sw) + gama * tr_sigma(c)/nk * eye(nt);
        rst_c = -log(det(sig_c)) - test_c'  /sig_c *test_c;
        rst_class(c, 1:mt) = diag(rst_c);
    end
 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%����ȷ��
 fprintf('QDF�����б������Է�����ȷ����%.1f%%��\n', right_percent * 100);  



 clear rst_c test_c;
 divide_num = 1;
 for i = 1:divide_num
     per_num = m/divide_num;
     
     train_set_tmp = train_set(:,1+(i-1)*per_num:per_num *i);
     train_lable_tmp = train_lable(1+(i-1)*per_num:per_num *i);
 
 u_I = ones(1,per_num);
 rst_class = zeros(c_num, per_num);
 
 for c = 1:c_num
        u_c = u(:, c) * u_I;
        test_c = train_set_tmp - u_c;
        sig_c = sigma(:,:,c);
        sig_c = (1-gama) * ((1-beta) * sig_c + beta * sw) + gama * tr_sigma(c)/nk * eye(n);
    rst_c = -log(det(sig_c)) - test_c'  /sig_c *test_c;
    rst_class(c, 1:per_num) = diag(rst_c);
 end

  [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = train_lable_tmp - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent(i) = 1 - diff_num/per_num;%����ȷ��
 
 end%divide_num
 fprintf('QDF�����б���ѵ��������ȷ����%.1f%%��\n', mean(right_percent) * 100);
