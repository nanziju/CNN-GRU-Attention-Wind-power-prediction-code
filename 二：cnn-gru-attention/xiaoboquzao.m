%%��ʼ������
clear;
t1=clock;
%���ݵ���
data=xlsread('shiyanyiorgin.xlsx');
YSJ=data;
%% ����Ԥ�������ݿ����Ǵ洢�ھ��������EXCEL�еĶ�ά���ݣ��ν�Ϊһά�ģ����������һά���ݣ��˲���Ҳ����Ӱ������
 [c,l]=size(YSJ);
 GY=[];
 for j=1:l
   Y=[];
   for i=1:c
       Y=[Y,YSJ(i,j)];
   end
  [c1,l1]=size(Y);
  X=1:l1;
  %% ���������ź�ͼ��
   
    figure(j);
    subplot(2,1,1);
    plot(X,Y);
    xlabel('������');
    ylabel('������');
    title('yuanshi');
    
    %% С����ֵȥ��
    lev=3;%�ֽ����
    xz=wden(Y,'minimaxi','h','sln',lev,'sym4');
    %minimaxiΪ����С��ֵ�����滻Ϊsqtwolog���̶���ֵ����heursure������ʽ��ֵ����rigrsure����ƫ���չ�����ֵ��
    %hΪӲ��ֵ�����������滻Ϊs������ֵ��������
    subplot(2,1,2);
    plot(X,xz);
    xlabel('������');
    ylabel('������');
    title('С��');
    set(gcf,'Color',[1 1 1]);
    GY=[GY;xz];

    G=GY';
    %% ���������SNR
    Psig=sum(Y*Y')/l1;
    
    Pnoi3=sum((Y-xz)*(Y-xz)')/l1;
    
    SNR3=10*log10(Psig/Pnoi3);
    % ������������RMSE
    
    RMSE3=sqrt(Pnoi3);
    % ������
    disp(['-----���ǵ�',num2str(j),'�����ݽ����������']);
   disp('-------------������ֵ�趨��ʽ�Ľ��봦����---------------'); 
    disp(['ȥ�봦��SNR=',num2str(SNR3),'��RMSE=',num2str(RMSE3)]);
     t2=clock;
     tim=etime(t2,t1);
     disp(['------------------���к�ʱ',num2str(tim),'��-------------------'])
end