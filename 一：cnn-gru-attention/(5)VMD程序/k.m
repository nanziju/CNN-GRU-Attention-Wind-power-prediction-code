y=xlsread('shiyanyi.xlsx');%ԭʼ
% y=y(:,1);
y1=y(1:1000);
%load xifangshiyou;2017-06-25 063000
data=y1;
%15+7+12+13=47
for st=1:10
    K=st+1;
    [u, u_hat, omega] = VMD(data, length(data), 0, K, 0, 1, 1e-5);
    u=flipud(u);
    resf=zeros(1,K);
    for i=1:K
        testdata=u(i,:);
        hilbert(testdata'); 
        z=hilbert(testdata');                   % ϣ�����ر任
        a=abs(z);                              % ������
        fnor=instfreq(z);                       % ˲ʱƵ��
        resf(i)=mean(fnor);     
    end
    u=u.';
    subplot(4,5,st)
    plot(resf,'k');title(['����Ϊ',num2str(st)]);
    grid on;
end