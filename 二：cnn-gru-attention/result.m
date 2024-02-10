clear all
close all
clc

% x=xlsread('shiyanyi.xlsx');
% x=x(807:end);
% y=xlsread('predict1.xlsx')';

y=xlsread('shiyaner.xlsx');
y=y(811:end);

x=xlsread(['vmd-cnn-gru-attention.xlsx']);
x=sum(x,2);
c=y-x;

n = length(x);
MSE_test = mean((x - y).^2);
disp(['�������MSE = ', num2str(MSE_test)])
MAE_test = mean(abs(x - y));
disp(['ƽ���������MAE = ', num2str(MAE_test)])
  mape=sum(abs((x-y)./x))/length(x);
  disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(mape)])
RMSE_test = sqrt(MSE_test);
disp(['���������RMSE = ', num2str(RMSE_test)])

% MAPE_test = mean(abs((x - y)./x));
% disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(MAPE_test*100), '%'])
% R_test = corrcoef(x, y);
% R2_test = R_test(1, 2)^2;
% disp(['����Ŷ�R2 = ', num2str(R2_test)])

numerator6 =sqrt(sum((x - y).^2));
denominator6=sqrt(sum(x.^2)) + sqrt(sum(y.^2));
R2_mlp_arima =numerator6 / denominator6;
disp(['Theil��s U = ', num2str(R2_mlp_arima)])
R2_mlp_arima1= sqrt(sum((x - y).^2) / n) / (sqrt(sum((x- mean(x)).^2) / n) + sqrt(sum((y - mean(y)).^2) / n));
disp(['TIC = ', num2str(R2_mlp_arima1)])

xx=1:1:190 ;
TURE=x;
PREDICTION=y;
plot(xx,TURE,'-r',xx,PREDICTION,'-g');

axis([0,190,0,45])
set(gca,'XTick',[0:20:190])
set(gca,'YTick',[0:5:45])
xlabel('T period')
ylabel('Wind power (m/s)')
