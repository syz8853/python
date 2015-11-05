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

train_set = train_kk;
train_lable = tr_lable_kk;
[n,m] =size(train_set);
train_set = train_set * 100;
train_set = roundn(train_set, -1);
c_num = max(train_lable) - min(train_lable)+1;
train_set_labled = zeros(n + 1, m, c_num);
index_c = ones(1, c_num);

test_set = verify_kk;
test_lable = vr_lable_kk;
[nt,mt] = size(test_set); 
test_set = test_set * 100;
test_set = roundn(test_set, -1);


for i = 1:m
    c_temp = train_lable(i);
    
    train_set_labled(1:n, index_c(c_temp), c_temp) = train_set(:, i);
    train_set_labled(n +1, index_c(c_temp), c_temp) = 1;%样本有效标记
    index_c(c_temp) = index_c(c_temp) + 1;
end
 
x_Min = min(min(train_set)) - 200;
x_Max = max(max(train_set)) + 200;

x_Axis = x_Min:0.1:x_Max; 
sample_num = zeros(1, c_num);
h = 5;
PXM = zeros(length(x_Axis),n,c_num);
for h = 20:20

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