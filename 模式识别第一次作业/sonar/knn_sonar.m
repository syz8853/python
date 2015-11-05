clear all; close all;clc;
X = load('data_sonar.mat');

train_set_tmp = X.sonar;
[m, n] = size(train_set_tmp);
 for j = 1: n %对训练样本进行标准化
     
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
%-------------------------------------------------
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
[n,m] =size(train_set);

[nk, mk] = size(train_kk);

c_num = max(train_lable) - min(train_lable)+1;
train_kk_labled = zeros(nk + 1, mk, c_num);
index_c = ones(1, c_num);


 [nkt, mkt] = size(verify_kk);
cross_counter = 0;

% distance_ki = zeros(nk, mk);
u_I = ones(1, mk);

vr_divide_num = 1;
tr_divide_num = 1;
per_vr_num = mkt/vr_divide_num;
per_tr_num = mk/tr_divide_num;

vr_process = zeros(nkt, mkt/vr_divide_num);
tr_process = zeros(nk, mk/tr_divide_num);
% k_near_buffer = zeros(per_vr_num,knum);
% k_near_buffer_double = ones(per_vr_num, 2 * knum) * 1e9;
% 
% near_cls = zeros(per_vr_num, 2*knum);
% near_lable = zeros(per_vr_num, 2*knum);
% vernear = zeros(mkt, knum); 
% vernear_lb = zeros(mkt, knum); 
for knum = 3:10
    k_near_buffer = zeros(per_vr_num,knum);
k_near_buffer_double = ones(per_vr_num, 2 * knum) * 1e9;

near_cls = zeros(per_vr_num, 2*knum);
near_lable = zeros(per_vr_num, 2*knum);
vernear = zeros(mkt, knum); 
vernear_lb = zeros(mkt, knum); 
    
    for vr_num = 1:vr_divide_num
        for tr_num = 1:tr_divide_num
            
        vr_process = verify_kk(:, 1+(vr_num-1)*per_vr_num: vr_num*per_vr_num);
        tr_process = train_kk(:, 1+(tr_num-1)*per_tr_num:tr_num*per_tr_num);
            vr_vec = vr_process(:);
            tr_vec = repmat(tr_process, per_vr_num,1);
            diff_vec = bsxfun(@minus, tr_vec, vr_vec);
            diff_vec = diff_vec.^2;
            
            dist_mat = reshape(sum(reshape(diff_vec,nkt,[])),[],size(diff_vec,2));
            [dist_sort, pos] = sort(dist_mat, 2);
            k_near_buffer = dist_sort(:,1:knum);
            k_near_ind = pos(:, 1:knum);
            true_near_ind = k_near_ind +per_tr_num  * (tr_num-1);
            
            k_near_buffer_double(:,knum+1:2*knum) = k_near_buffer;
            true_near_ind_double(:,knum + 1 : 2*knum) = true_near_ind(:,1:knum);
            
            [dis_sort2, pos2] = sort(k_near_buffer_double,2);
            for j = 1:per_vr_num
            near_cls(j,:) = true_near_ind_double(j,pos2(j,:));
            near_lable(j,1:knum) = tr_lable_kk(near_cls(j,1:knum));
            end
%             vr_num
%             tr_num
        end
        
       vernear(1+per_vr_num*(vr_num-1):per_vr_num*vr_num, :) = near_cls(:,1:knum);
       vernear_lb(1+per_vr_num*(vr_num-1):per_vr_num*vr_num, :) = near_lable(:,1:knum);

        
    end
    
    ver_lable = mode(vernear_lb,2);
    diff = ver_lable' - vr_lable_kk;
    diff_num = length(find(diff ~= 0));
    right_percent = 1 - diff_num/mkt;
     fprintf('KNN验证分类正确率是%.1f%%。k=%f\n', right_percent * 100,knum);
    
end


