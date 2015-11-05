mnist_read_train;  %��ȡѵ������
% train_set = 255 - train_set; % ȡ��
std_fea = std(train_set, 0, 2);

discard_fea = find(std_fea<2);
train_set(discard_fea, :) = [];

[n, m] = size(train_set); %m ����������n��������������ά��
train_set = train_set + 5- abs(round(rand(n,m) * 10));

train_set = (train_set - 128)/16;

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

%----------��ȡ��������----------------------
mnist_read_test;
test_set(discard_fea, :) = [];
% test_set = 255 - test_set;%ȡ������ѵ��������һ��
test_set = (test_set - 128)/16;
[nt,mt] = size(test_set);

sw = m/(m-c_num) * sw; %sw����ƫ����
sw_verse = inv(sw);%��������죬�������

rst_class = zeros(c_num, mt); %���浱ǰ�����б������

    
    for c = 1:c_num
    rst_class(c, 1:mt) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + test_set' /sw * u(:,c);
    end

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = test_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/mt;%����ȷ��
 fprintf('LDF�����б���������ȷ����%.1f%%��\n', right_percent * 100);
 
 rst_class = zeros(c_num, m);
 for c = 1:c_num
    rst_class(c, 1:m) = log(pw(c)) - 1/2 * u(:,c)' /sw * u(:,c) + train_set' /sw * u(:,c);
 end

 [maxv, ind] = max(rst_class); %���ÿ�����������������ֵ�������ڵ�λ��
 test_result = ind - 1; %�õ����õĽ��
 diff = train_lable - test_result;
 diff_samples = find(diff ~= 0);
 diff_num = length(diff_samples);
 right_percent = 1 - diff_num/m;%����ȷ��
 fprintf('LDF�����б���������ȷ����%.1f%%��\n', right_percent * 100);

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