%p-窗法，根据样本进行概率密度函数进行估计
function p=Parzen(xi,x,h1)
%---------------------参数说明------------------------%
%xi：样本
%x ：概率密度函数的自变量的取值
%h1：可调节参量，通过调整h1可以调整窗宽（一般为经验值，不断调整选取）
%返回x对应的概率密度函数值
%----------------------------------------------------%
f=@(u)(1/sqrt(2*pi))*exp(-0.5*u.^2);%使用正态窗函数
N=size(xi,2);
hn=h1/sqrt(N);
[X Xi]=meshgrid(x,xi);%生成x-xi平面上的自变量“格点”矩阵，矩阵不同的行对应不同的x取值，不同的列对应不同的xi取值
p=sum(f((X-Xi)/hn)/hn)/N;%对列Xi求和 
