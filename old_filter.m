%�����˲�
close all
%x=flip(y1);

 Y=y1-y0;%����Դ�˲�
N=length(y1);
 for i=1:N
    if Y(i)<=-45
        Y(i)=-45;
    end
 end
x=rmmissing(Y);
% ����ԭʼ�ź�
fs = length(x1); % ����Ƶ��
t = rmmissing(x1); % ʱ������
% ���и���Ҷ�任
N = length(x); % �źų���
X = fft(x)/N; % ���㸵��Ҷ�任�������źų��ȵõ���ֵ
f = (0:N-1)*fs/N; % ����Ƶ������
% ��ʾԭʼ�źź͸���Ҷ�任
%figure;
subplot(2,2,1);
plot(t,x);
xlabel('������nm��');
ylabel('��ǿ');
title('ԭʼ�ź�');%ԭʼ�ź�ͼ��
%f=f/fs;%��һ������
subplot(2,2,2);
plot(f,abs(X));
xlabel('Ƶ�� (Hz)');
ylabel('��ֵ');
title('�źŵĸ���Ҷ�任');
xlim([0 fs/2]);%���ƺ����곤��
% �����˲�����Ӧ�����ź�
fc =18; % �˲�������Ƶ��
[b,a] = butter(6,fc/(fs/2)); % ����6�װ�����˹��ͨ�˲���
y2 = filtfilt(b,a,x); % Ӧ���˲���
% ��ʾ�˲�����źź͸���Ҷ�任
%figure;
subplot(2,2,3);
plot(t,y2);
xlabel('������nm��');
ylabel('��ǿ');
title('�˲�����ź�');
subplot(2,2,4);
Y = fft(y2)/N;
stem(f,abs(Y));
xlabel('Ƶ�� (Hz)');
ylabel('��ֵ');
title('�˲�����źŵĸ���Ҷ�任');
xlim([0 fs/2]);
plot(t,x,t,y2)