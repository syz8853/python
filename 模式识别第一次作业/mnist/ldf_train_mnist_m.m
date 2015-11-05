mnist_read_train;  %读取训练数据
% train_set = 255 - train_set; % 取反
std_fea = std(train_set, 0, 2);

discard_fea = find(std_fea<2);
train_set(discard_fea, :) = [];

[n, m] = size(train_set); %m 样本数量，n单个样本向量的维数
train_set = train_set + 5- abs(round(rand(n,m) * 10));

train_set = (train_set - 128)/16;

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
    
    sw = sw + sample_num(c)/m * sig_tmp; %求全部类的协方差矩阵的最大似然估计
    pw(c) =  sample_num(c)/m;%求各类别的先验概率
end

%----------读取测试数据----------------------
mnist_read_test;
test_set(discard_fea, :) = [];
% test_set = 255 - test_set;%取反，和训练集保持一致
test_set = (test_set - 128)/16;
[nt,mt] = size(test_set);

sw = m/(m-c_num) * sw; %sw的无偏估计
sw_verse = inv(sw);%因矩阵奇异，求广义逆

rst_class = zeros(c_num, mt); %缓存当前类别的判别函数结果

    
    for c = 1:c_num
    rst_class(c, 1:mt) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + test_set' /sw * u(:,c);
    end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind - 1; %得到所得的结果
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%求正确率
 fprintf('LDF线性判别函数分类正确率是%.1f%%。\n', right_percent * 100);
 
 rst_class = zeros(c_num, m);
 for c = 1:c_num
    rst_class(c, 1:m) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + train_set' /sw * u(:,c);
 end

 [maxv, ind] = max(rst_class); %求出每列样本各个类别的最大值及其所在的位置
 test_result = ind - 1; %得到所得的结果
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%求正确率
 fprintf('LDF线性判别函数分类正确率是%.1f%%。\n', right_percent * 100);

% % sig_tmp2 = zeros(n,n);

% % train_c_10 = train_set_labled(:,1:200,10);
% % u_temp2 = sum(train_c_10(1:n,:), 2)/200;
% % u_10 = sum(train_c_10, 2)/200;
% % for i = 1:200
% %     
% %     x = train_c(1:n, i);
% %     
% %     sig_tmp2 = sig_tmp2 + (x - u_temp2) *  (x - u_temp2)';
% %     
% %     
% %     
% % end
% % sig_tmp2= sig_tmp2/(200-1);
% % sig_tmp3 = cov(train_c_10(1:n, 1:200)');