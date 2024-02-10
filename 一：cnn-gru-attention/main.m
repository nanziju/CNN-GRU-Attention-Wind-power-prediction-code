%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������

%%  �������ݣ�ʱ�����еĵ������ݣ�
 % result = xlsread('shiyanyi.xlsx');
for t=1:11
data = xlsread('eemd.xlsx')';
result=data(:,t);
%%  ���ݷ���
num_samples = length(result);  % �������� 
kim = 10;                      % ��ʱ������kim����ʷ������Ϊ�Ա�����
zim =  1;                      % ��zim��ʱ������Ԥ��

%%  �������ݼ�
for i = 1: num_samples - kim - zim + 1
    res(i, :) = [reshape(result(i: i + kim - 1), 1, kim), result(i + kim + zim - 1)];
end

%% ���ݼ�����
outdim = 1;                                  % ���
num_size = 0.8;                              % ѵ����ռ���ݼ�����
num_train_s = round(num_size * num_samples); % ѵ������������
f_ = size(res, 2) - outdim;                  % ��������ά��

%%  ����ѵ�����Ͳ��Լ�
P_train = res(1: num_train_s, 1: f_)';
T_train = res(1: num_train_s, f_ + 1: end)';
M = size(P_train, 2);

P_test = res(num_train_s + 1: end, 1: f_)';
T_test = res(num_train_s + 1: end, f_ + 1: end)';
N = size(P_test, 2);

%%  ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test = mapminmax('apply', P_test, ps_input);

[t_train, ps_output] = mapminmax(T_train, 0, 1);
t_test = mapminmax('apply', T_test, ps_output);

%%  ����ƽ��
%   ������ƽ�̳�1ά����ֻ��һ�ִ���ʽ
%   Ҳ����ƽ�̳�2ά���ݣ��Լ�3ά���ݣ���Ҫ�޸Ķ�Ӧģ�ͽṹ
%   ����Ӧ��ʼ�պ���������ݽṹ����һ��
p_train =  double(reshape(p_train, f_, 1, 1, M));
p_test  =  double(reshape(p_test , f_, 1, 1, N));
t_train =  double(t_train)';
t_test  =  double(t_test )';

%%  ���ݸ�ʽת��
for i = 1 : M
    Lp_train{i, 1} = p_train(:, :, 1, i);
end

for i = 1 : N
    Lp_test{i, 1}  = p_test( :, :, 1, i);
end
    
%%  ����ģ��
lgraph = layerGraph();                                                 % �����հ�����ṹ

tempLayers = [
    sequenceInputLayer([f_, 1, 1], "Name", "sequence")                 % ��������㣬�������ݽṹΪ[f_, 1, 1]
    sequenceFoldingLayer("Name", "seqfold")];                          % ���������۵���
lgraph = addLayers(lgraph, tempLayers);                                % ����������ṹ����հ׽ṹ��

tempLayers = convolution2dLayer([3, 1], 32, "Name", "conv_1");         % ����� �����[3, 1] ����[1, 1] ͨ���� 32
lgraph = addLayers(lgraph,tempLayers);                                 % ����������ṹ����հ׽ṹ��
 
tempLayers = [
    reluLayer("Name", "relu_1")                                        % �����
    convolution2dLayer([3, 1], 64, "Name", "conv_2")                   % ����� �����[3, 1] ����[1, 1] ͨ���� 64
    reluLayer("Name", "relu_2")];                                      % �����
lgraph = addLayers(lgraph, tempLayers);                                % ����������ṹ����հ׽ṹ��

tempLayers = [
    globalAveragePooling2dLayer("Name", "gapool")                      % ȫ��ƽ���ػ���
    fullyConnectedLayer(16, "Name", "fc_2")                            % SEע�������ƣ�ͨ������1 / 4
    reluLayer("Name", "relu_3")                                        % �����
    fullyConnectedLayer(64, "Name", "fc_3")                            % SEע�������ƣ���Ŀ��ͨ������ͬ
    sigmoidLayer("Name", "sigmoid")];                                  % �����
lgraph = addLayers(lgraph, tempLayers);                                % ����������ṹ����հ׽ṹ��

tempLayers = multiplicationLayer(2, "Name", "multiplication");         % ��˵�ע����
lgraph = addLayers(lgraph, tempLayers);                                % ����������ṹ����հ׽ṹ��

tempLayers = [
    sequenceUnfoldingLayer("Name", "sequnfold")                        % �������з��۵���
    flattenLayer("Name", "flatten")                                    % ������ƽ��
    gruLayer(6, "Name", "gru", "OutputMode", "last")                   % GRU��
    fullyConnectedLayer(1, "Name", "fc")                               % ȫ���Ӳ�
    regressionLayer("Name", "regressionoutput")];                      % �ع��
lgraph = addLayers(lgraph, tempLayers);                                % ����������ṹ����հ׽ṹ��

lgraph = connectLayers(lgraph, "seqfold/out", "conv_1");               % �۵������ ���� ���������;
lgraph = connectLayers(lgraph, "seqfold/miniBatchSize", "sequnfold/miniBatchSize"); 
                                                                       % �۵������ ���� ���۵�������  
lgraph = connectLayers(lgraph, "conv_1", "relu_1");                    % �������� ���� �����
lgraph = connectLayers(lgraph, "conv_1", "gapool");                    % �������� ���� ȫ��ƽ���ػ�
lgraph = connectLayers(lgraph, "relu_2", "multiplication/in2");        % �������� ���� ��˲�
lgraph = connectLayers(lgraph, "sigmoid", "multiplication/in1");       % ȫ������� ���� ��˲�
lgraph = connectLayers(lgraph, "multiplication", "sequnfold/in");      % ������

%%  ��������
options = trainingOptions('adam', ...      % Adam �ݶ��½��㷨
    'MaxEpochs', 100, ...                  % ����������
    'InitialLearnRate', 1e-2, ...          % ��ʼѧϰ��Ϊ0.01
    'LearnRateSchedule', 'piecewise', ...  % ѧϰ���½�
    'LearnRateDropFactor', 0.1, ...        % ѧϰ���½����� 0.5
    'LearnRateDropPeriod', 50, ...         % ����50��ѵ���� ѧϰ��Ϊ 0.01 * 0.1
    'Shuffle', 'every-epoch', ...          % ÿ��ѵ���������ݼ�
    'Plots', 'training-progress', ...      % ��������
    'Verbose', false);

%%  ѵ��ģ��
net = trainNetwork(Lp_train, t_train, lgraph, options);

%%  ģ��Ԥ��
t_sim1 = predict(net, Lp_train);
t_sim2 = predict(net, Lp_test );

%%  ���ݷ���һ��
T_sim1 = mapminmax('reverse', t_sim1, ps_output);
T_sim2 = mapminmax('reverse', t_sim2, ps_output);
b(:,t)=T_sim2;
c=sum(b,2);
end
%%  ���������
error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

%%  ��ʾ����ṹ
analyzeNetwork(net)

% %%  ��ͼ
% figure
% plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
% legend('��ʵֵ', 'Ԥ��ֵ')
% xlabel('Ԥ������')
% ylabel('Ԥ����')
% string = {'ѵ����Ԥ�����Ա�'; ['RMSE=' num2str(error1)]};
% title(string)
% xlim([1, M])
% grid
% 
% figure
% plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
% legend('��ʵֵ', 'Ԥ��ֵ')
% xlabel('Ԥ������')
% ylabel('Ԥ����')
% string = {'���Լ�Ԥ�����Ա�'; ['RMSE=' num2str(error2)]};
% title(string)
% xlim([1, N])
% grid
% 
% %%  ���ָ�����
% %  R2
% R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
% R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;
% 
% %disp(['ѵ�������ݵ�R2Ϊ��', num2str(R1)])
% disp(['���Լ����ݵ�R2Ϊ��', num2str(R2)])
% 
% %  MAE
% mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
% mae2 = sum(abs(T_sim2' - T_test )) ./ N ;
% 
% %disp(['ѵ�������ݵ�MAEΪ��', num2str(mae1)])
% disp(['���Լ����ݵ�MAEΪ��', num2str(mae2)])
% 
% %  MBE
% mbe1 = sum(T_sim1' - T_train) ./ M ;
% mbe2 = sum(T_sim2' - T_test ) ./ N ;
% 
% %disp(['ѵ�������ݵ�MBEΪ��', num2str(mbe1)])
% disp(['���Լ����ݵ�MBEΪ��', num2str(mbe2)])


MSE_test = mean((T_sim2 - T_test').^2);
disp(['�������MSE = ', num2str(MSE_test)])
MAE_test = mean(abs(T_sim2 - T_test'));
disp(['ƽ���������MAE = ', num2str(MAE_test)])
RMSE_test = sqrt(MSE_test);
disp(['���������RMSE = ', num2str(RMSE_test)])
mape=sum(abs((T_sim2-T_test')./T_sim2))/length(T_sim2);
disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(mape)])
%  MAPE_test = mean(abs((T_sim2-T_test')./T_sim2));
% disp(['ƽ�����԰ٷֱ����MAPE = ', num2str(MAPE_test*100), '%'])
R_test = corrcoef(T_sim2, T_test');
R2_test = R_test(1, 2)^2;
disp(['����Ŷ�R2 = ', num2str(R2_test)])