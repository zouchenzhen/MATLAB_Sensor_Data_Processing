% ------------------------- 设置参数 ------------------------- 
% 1. 文件夹路径 
folderPath = 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\';  % 文件夹路径

% 2. 输入文件名
inputFileName = 'txt_csv.CSV';  % 输入文件名

% 3. 输出文件名   
outputFileName = 'txt_csvfiltered.csv';  % 输出文件名  

% 4. 滤波器截止频率
fc = 8;  % 滤波器截止频率

% 5. 是否只画一个时域图 (1: 只画第一个, 0: 画所有的)
p = 1; 

% ------------------------- 主程序 -------------------------

% 定义保存结果的路径
outputFilePath = fullfile(folderPath, outputFileName);

% 读取 CSV 文件
filePath = fullfile(folderPath, inputFileName);
data = load(filePath);  % 导入数据，假设数据是纯数字的

% 提取波长和光源强度数据
wavelength = data(:, 1);  % 第一列是波长
y0 = data(:, 2);  % 第二列是光源强度

% 获取测量的光强数据（从第三列开始）
measured_data = data(:, 3:end);

% 初始化矩阵存储滤波后的数据和极小值波长
filtered_data = [];
min_values_wavelength = [];  % 用于存储每列数据的极小值波长

% 设定采样频率
fs = length(wavelength);

% 设置MATLAB命令行窗口的输出精度
format short;  % 显示标准精度

% 处理每组测量数据
for k = 1:size(measured_data, 2)
    y1 = measured_data(:, k);  % 获取第k组测量的光强数据

    % 减光源滤波
    Y = y1 - y0;  % 减去光源信号

    % 修正光强数据，确保其值不会低于-45
    Y(Y <= -45) = -45;

    % 去除缺失数据
    x = rmmissing(Y);

    % 生成时间向量（假设时间和波长相同）
    t = wavelength(~isnan(Y));  % 使用去除NaN后的波长作为时间向量

    % 进行巴特沃斯低通滤波器
    [b, a] = butter(6, fc / (fs / 2));  % 6阶巴特沃斯低通滤波器
    y2 = filtfilt(b, a, x);  % 应用滤波器

    % 判断是否需要绘图
    if p == 0 || (p == 1 && k == 1)  % 如果 p=1 且当前是第一个信号，或者 p=0 绘制所有信号
        figure;
        plot(t, x, 'b', 'LineWidth', 1.5);  % 原始信号（蓝色）
        hold on;
        plot(t, y2, 'r', 'LineWidth', 1.5);  % 滤波后信号（红色）
        xlabel('波长（nm）');
        ylabel('光强');
        legend('原始信号', '滤波后信号');
        title(['信号对比 - 组 ', num2str(k)]);
        grid on;
        hold off;
    end

    % 将滤波后的数据添加到矩阵中，保持与原数据大小一致
    filtered_column = nan(length(wavelength), 1);
    filtered_column(~isnan(Y)) = y2;
    filtered_data(:, k) = filtered_column;

    % 查找局部极小值及其对应的波长
    min_idx = islocalmin(y2);  % 获取局部极小值的索引
    min_wavelength = t(min_idx);  % 对应的波长

    % 保存极小值波长信息到矩阵中
    min_values_wavelength(1:length(min_wavelength), k) = min_wavelength;  % 将每列的极小值波长存储到矩阵中
end

% 对极小值波长矩阵进行行列转置
min_values_transposed = min_values_wavelength.';  % 转置后的矩阵

% 获取转置后的极小值矩阵的列数（即测量数据的组数）
num_measurements = size(min_values_transposed, 2);

% 创建一个空矩阵与 `filtered_data` 一致，用于存放转置后的极小值波长数据
final_data_with_min = [wavelength, filtered_data];  % 初始为波长列和滤波数据

% 确保转置后的极小值矩阵的行数与 `final_data_with_min` 的行数一致
% 通过填充 NaN 使行数匹配
min_values_transposed_padded = [min_values_transposed; nan(size(final_data_with_min, 1) - size(min_values_transposed, 1), num_measurements)];

% 将转置后的极小值波长数据插入到 final_data_with_min 的合适位置
final_data_with_min(:, end + 1 : end + num_measurements) = min_values_transposed_padded;

% 将结果写入 CSV 文件
writematrix(final_data_with_min, outputFilePath, 'Delimiter', ',');

% 动态显示输出文件名
disp(['滤波处理完成，结果已保存为 ', outputFileName]);
