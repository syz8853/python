clear all; close all;clc;
X = load('iris_data.mat');

train_set_tmp = X.iris;
[m, n] = size(train_set_tmp);
 for j = 1: n %对训练样本进行标准化
     
     fj = train_set_tmp(:,j);
     
     fj = (fj - mean(fj))/std(fj);
     train_set_tmp(:,j) = fj;
 end
 
 train_set = train_set_tmp';
 
 L = load('iris_lable.mat');
 lable_tmp = L.Irissetosa;
 lable = zeros(1,length(lable_tmp));
 c1 = char('Iris-setosa');
 c2 = char('Iris-versicolor');
 c3 = char('Iris-virginica');
 for j = 1:length(lable_tmp)
     tmp = char(lable_tmp(j));
     if strcmp(c1, tmp)
         lable(j) = 1;
     end
     if strcmp(c2, tmp)
         lable(j) = 2;
     end
     
     if strcmp(c3, tmp)
         lable(j) = 3;
     end
     
 end
 
rand_colindex = randperm(m);
train_set_rand = train_set(:, rand_colindex);
train_lable_rand = lable(:, rand_colindex);

train_num = 100;
train_kk = train_set_rand(:, 1:train_num);
tr_lable_kk = train_lable_rand(:, 1:train_num);
verify_kk = train_set_rand(:, train_num + 1:m);
vr_lable_kk = train_lable_rand(:, train_num + 1:m);
train_lable = tr_lable_kk;
train_set = train_kk;
[n,m] =size(train_set);
[nk, mk] = size(train_kk);

c_num = max(train_lable) - min(train_lable)+1;
train_kk_labled = zeros(nk + 1, mk, c_num);
index_c = ones(1, c_num);
for i = 1:mk
    c_temp = tr_lable_kk(i);
    
    train_kk_labled(1:nk, index_c(c_temp), c_temp) = train_kk(:, i);
    train_kk_labled(nk +1, index_c(c_temp), c_temp) = 1;%样本有效标记
    index_c(c_temp) = index_c(c_temp) + 1;
end

 [nkt, mkt] = size(verify_kk);
cross_counter = 0;
for beta = 0:0.1:1
    for gama = 0:0.1:1
 %交叉验证for begin
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

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind ; %得到所得的结果
 diff = vr_lable_kk - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mkt;%求正确率
 fprintf('QDF线性判别函数验证分类正确率是%.1f%%。gamma=%f beta=%f\n', right_percent * 100,gama,beta);
Gama_cross(cross_counter) = gama;
Beta_cross(cross_counter) = beta;
right_cross(cross_counter) = right_percent * 100;

% 交叉验证 for end
    end
end

rst_class = zeros(c_num, m);
u_I = ones(1, m);
gama = 0.1;beta = 0.1;
 for c = 1:c_num
        u_c = u(:, c) * u_I;
        test_c = train_set - u_c;
        sig_c = sigma(:, :, c);
        sig_c = (1-gama) * ((1-beta) * sig_c + beta * sw) + gama * tr_sigma(c)/nk * eye(nk);
        rst_c = -log(det(sig_c)) - test_c'  /sig_c *test_c;
        rst_class(c, 1:m) = diag(rst_c);
 end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind; %得到所得的结果
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%求正确率
 fprintf('RDA线性判别函数对训练集分类正确率是%.1f%%。\n', right_percent * 100);
