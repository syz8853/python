clear all; close all;clc;
X = load('data_sonar.mat');

train_set_tmp = X.sonar;
[m, n] = size(train_set_tmp);
 for j = 1: n %��ѵ���������б�׼��
     
     fj = train_set_tmp(:,j);
     
     fj = (fj - mean(fj))/std(fj);
     train_set_tmp(:,j) = fj;
 end
 
 train_set = train_set_tmp';
 
 L = load('lable_sonar.mat');
 lable_tmp = L.sonar;
 lable = zeros(1,length(lable_tmp));
 
 c1 = char('R');
 c2 = char('M');
 for j = 1:length(lable_tmp)
     tmp = char(lable_tmp(j));
     if strcmp(c1, tmp)
         lable(j) = 1;
     end
     if strcmp(c2, tmp)
         lable(j) = 2;
     end
 end
 rand_colindex = randperm(m);
train_set_rand = train_set(:, rand_colindex);
train_lable_rand = lable(:, rand_colindex);

train_num = 160;
train_kk = train_set_rand(:, 1:train_num);
tr_lable_kk = train_lable_rand(:, 1:train_num);
verify_kk = train_set_rand(:, train_num + 1:m);
vr_lable_kk = train_lable_rand(:, train_num + 1:m);

train_set = train_kk;
train_lable = tr_lable_kk;
[n, m] = size(train_set);
c_num = max(train_lable) - min(train_lable)+1;
train_set_labled = zeros(n + 1, m, c_num);
index_c = ones(1, c_num);
for i = 1:m
    c_temp = train_lable(i);
    
    train_set_labled(1:n, index_c(c_temp), c_temp) = train_set(:, i);
    train_set_labled(n +1, index_c(c_temp), c_temp) = 1;%������Ч���
    index_c(c_temp) = index_c(c_temp) + 1;
end

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
    
    sw = sw + sample_num(c)/m * sig_tmp; %��ȫ�����Э�������������Ȼ����
    pw(c) =  sample_num(c)/m;%��������������
end


test_set = verify_kk;
test_lable = vr_lable_kk;
[nt,mt] = size(test_set);
sw = m/(m-c_num) * sw; %sw����ƫ����
sw_verse = inv(sw);%��������죬�������

rst_class = zeros(c_num, mt); %���浱ǰ�����б������

    
    for c = 1:c_num
    rst_class(c, 1:mt) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + test_set' /sw * u(:,c);
    end

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind; %�õ����õĽ��
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%����ȷ��
 fprintf('LDF�����б�������Բ��Լ���ȷ����%.1f%%��\n', right_percent * 100);
 
 
 
 rst_class = zeros(c_num, m);
 for c = 1:c_num
    rst_class(c, 1:m) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + train_set' /sw * u(:,c);
 end

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind; %�õ����õĽ��
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%����ȷ��
 fprintf('LDF�����б�����ѵ����������ȷ����%.1f%%��\n', right_percent * 100); 
 
 