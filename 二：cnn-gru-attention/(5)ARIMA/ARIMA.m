clear;
%data=xlsread('2003');
%data=data(:,1);
%Data=data(1:249);

for t=1:11
y=xlsread('error-vmd.xlsx');
y=y(:,t);
%��ʼ���ݵ�¼��
Data=y;

%load test(lorenz63)
%Data=data(:,1);

%data=xlsread('Arou');
%data=data(:,7);
%Data=data(1:1000);



SourceData=Data(1:190);%ȡ1800-2000������
step=1;
TempData=SourceData;
TempData=detrend(TempData);%����ʱ�������е�����������
TrendData=SourceData-TempData;%��ʵֵ��ȥ��������  �����Բ���
%--------��֣�ƽ�Ȼ�ʱ������---------
H=adftest(TempData);
difftime=0;
SaveDiffData=[];
while ~H
SaveDiffData=[SaveDiffData,TempData(1,1)];
TempData=diff(TempData); %��֣�ƽ�Ȼ�ʱ������
difftime=difftime+1; %��ִ���
H=adftest(TempData); %adf���飬�ж�ʱ�������Ƿ�ƽ�Ȼ�
end
%---------ģ�Ͷ��׻�ʶ��--------------
u = iddata(TempData);
test = [];
for p = 0:10%�Իع��ӦPACF,�����ͺ󳤶�����p��q��һ��ȡΪT/10��ln(T)��T^(1/2),����ȡT/10=12
  for q = 0:10 %�ƶ�ƽ����ӦACF
    m = armax(u,[p q]);
    AIC = aic(m); %armax(p,q),����AIC
    test = [test;p q AIC];
 end
end


for k = 1:size(test,1)
   if test(k,3) == min(test(:,3)) %ѡ��AICֵ��С��ģ��
      p_test = test(k,1);
      q_test = test(k,2);
      break;
   end
end
%------1��Ԥ��-----------------
TempData=[TempData;zeros(step,1)];
n=iddata(TempData);
m = armax(u,[p_test q_test]);
%m = armax(u(1:ls),[p_test q_test]);
%armax(p,q),[p_test q_test]��ӦAICֵ��С���Զ��ع黬��ƽ��ģ��
P1=predict(m,n,1);
PreR=P1.OutputData;
PreR=PreR';
%----------��ԭ���-----------------
if size(SaveDiffData,2)~=0
   for index=size(SaveDiffData,2):-1:1
      PreR=cumsum([SaveDiffData(index),PreR]);
    end
end
%-------------------Ԥ�����Ʋ����ؽ��----------------
mp1=polyfit([1:size(TrendData',2)],TrendData',1);
xt=[];
for j=1:step
   xt=[xt,size(TrendData',2)+j];
end
TrendResult=polyval(mp1,xt);
PreData=TrendResult+PreR(size(SourceData',2)+1:size(PreR,2));
tempx=[TrendData',TrendResult]+PreR; % tempxΪԤ����
tempx=tempx(1:190)';
%����������
mse=MSE1(tempx,Data(1:190));
y_arima=tempx';
plot(tempx,'r');         %��ɫΪԤ��ֵͼ��
hold on
plot(Data(1:190),'b')%��ɫΪ�۲�ֵͼ��
legend('Ԥ�����','�������')
y_arima=y_arima(1:190)';
y_test=Data(1:190);
rmse1 = sqrt(mean((y_arima-y_test).^2));
%re=y_arima-y_test;

 MSE_test = mean((y_arima - y_test).^2);
disp(['�������MSE = ', num2str(MSE_test)])
MAE_test = mean(abs(y_arima - y_test));
disp(['ƽ���������MAE = ', num2str(MAE_test)])
RMSE_test = sqrt(MSE_test);
disp(['���������RMSE = ', num2str(RMSE_test)])
  mape=sum(abs((y_arima-y_test)./y_arima))/length(y_arima);
  disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(mape)])
% MAPE_test = mean(abs((y_arima - y_test)./y_arima));
% disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(MAPE_test*100), '%'])
R_test = corrcoef(y_arima, y_test);
R2_test = R_test(1, 2)^2;
disp(['����Ŷ�R2 = ', num2str(R2_test)])
c(:,t)=y_test;
 b(:,t)=y_arima;
   end
