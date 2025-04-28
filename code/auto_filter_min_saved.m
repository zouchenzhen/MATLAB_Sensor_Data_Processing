% 定义文件夹路径作为常量 输出NaN最小值
folderPath = 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\practice\';
% 定义保存结果的路径
outputFilePath = fullfile(folderPath, 'filtered.csv');
% 读取 CSV 文件
filePath = fullfile(folderPath, 'txt_csv.csv');
data = load(filePath); % 导入数据，假设数据是纯数字的
% 提取波长和光源强度数据
wavelength = data(:, 1); % 第一列是波长
y0 = data(:, 2); % 第二列是光源强度
% 获取测量的光强数据（从第三列开始）
measured_data = data(:, 3:end);
% 初始化矩阵存储滤波后的数据
filtered_data = [];
min_values_data = NaN(length(wavelength), size(measured_data, 2)); % 用于存储每列数据的极小值
% 设定采样频率
fs = length(wavelength);
% 处理每组测量数据
for k = 1:size(measured_data, 2)
y1 = measured_data(:, k); % 获取第k组测量的光强数据
% 减光源滤波
Y = y1 - y0; % 减去光源信号
% 修正光强数据，确保其值不会低于-45
Y(Y <= -45) = -45;
% 去除缺失数据
x = rmmissing(Y);
% 生成时间向量（假设时间和波长相同）
t = wavelength(~isnan(Y)); % 使用去除NaN后的波长作为时间向量
% 进行巴特沃斯低通滤波器
fc = 18; % 滤波器截止频率
[b, a] = butter(6, fc / (fs / 2)); % 6阶巴特沃斯低通滤波器
y2 = filtfilt(b, a, x); % 应用滤波器
% 显示原始信号和滤波后信号对比图
figure;
plot(t, x, 'b', 'LineWidth', 1.5); % 原始信号（蓝色）
hold on;
plot(t, y2, 'r', 'LineWidth', 1.5); % 滤波后信号（红色）
xlabel('波长（nm）');
ylabel('光强');
legend('原始信号', '滤波后信号');
title(['信号对比 - 组 ', num2str(k)]);
grid on;
hold off;
% 将滤波后的数据添加到矩阵中，保持与原数据大小一致
filtered_column = nan(length(wavelength), 1);
filtered_column(~isnan(Y)) = y2;
filtered_data(:, k) = filtered_column;
% 查找局部极小值及其对应的波长
min_idx = islocalmin(y2); % 获取局部极小值的索引
min_intensity = y2(min_idx); % 对应的光强
% 将极小值存入min_values_data
min_values_data(min_idx, k) = min_intensity; % 将极小值填充到对应位置
end
% 将波长和滤波后的光强数据组合到一起
final_data = [wavelength, filtered_data, min_values_data];
% 写入 CSV 文件
writematrix(final_data, outputFilePath, 'Delimiter', ',');
disp('滤波处理完成，结果已保存为 filtered.csv');
clear ans;
