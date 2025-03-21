%单纯滤波
close all
%x=flip(y1);

 Y=y1-y0;%减光源滤波
N=length(y1);
 for i=1:N
    if Y(i)<=-45
        Y(i)=-45;
    end
 end
x=rmmissing(Y);
% 生成原始信号
fs = length(x1); % 采样频率
t = rmmissing(x1); % 时间向量
% 进行傅里叶变换
N = length(x); % 信号长度
X = fft(x)/N; % 计算傅里叶变换并除以信号长度得到幅值
f = (0:N-1)*fs/N; % 构建频率向量
% 显示原始信号和傅里叶变换
%figure;
subplot(2,2,1);
plot(t,x);
xlabel('波长（nm）');
ylabel('光强');
title('原始信号');%原始信号图像
%f=f/fs;%归一化光谱
subplot(2,2,2);
plot(f,abs(X));
xlabel('频率 (Hz)');
ylabel('幅值');
title('信号的傅里叶变换');
xlim([0 fs/2]);%限制横坐标长度
% 构建滤波器并应用于信号
fc =18; % 滤波器截至频率
[b,a] = butter(6,fc/(fs/2)); % 构建6阶巴特沃斯低通滤波器
y2 = filtfilt(b,a,x); % 应用滤波器
% 显示滤波后的信号和傅里叶变换
%figure;
subplot(2,2,3);
plot(t,y2);
xlabel('波长（nm）');
ylabel('光强');
title('滤波后的信号');
subplot(2,2,4);
Y = fft(y2)/N;
stem(f,abs(Y));
xlabel('频率 (Hz)');
ylabel('幅值');
title('滤波后的信号的傅里叶变换');
xlim([0 fs/2]);
plot(t,x,t,y2)