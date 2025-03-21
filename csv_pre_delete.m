% ------------------------- 设置参数 -------------------------
% 文件夹路径
folderPath = 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\1650\';  % 文件夹路径

% 输入文件名
inputFileName = '20241211-1.csv';  % 输入文件名

% 输出文件名
outputFileName = '20241211-1deleted.csv';  % 输出文件名

% 光源文件名
sourceFileName = 'a_光源.txt';  % 光源文件名

% ------------------------- 主程序 -------------------------
% 定义完整路径
filePath = fullfile(folderPath, inputFileName);
outputFilePath = fullfile(folderPath, outputFileName);
sourceFilePath = fullfile(folderPath, sourceFileName);

% 读取 CSV 文件
data = readmatrix(filePath, 'OutputType', 'char');  % 使用 'char' 读取所有文本数据（包括空行）

% ------------------------- 删除前256行 -------------------------
data(1:256, :) = [];  % 删除前256行

% 转换为数值矩阵（处理后续列操作）
data = str2double(data);  % 转为数值，非数字内容将转为 NaN

% ------------------------- 删除特定列 -------------------------
% 获取总列数
num_cols = size(data, 2);

% 确定从第3列开始的所有奇数列（3, 5, 7, 9, ...）
cols_to_delete = 3:2:num_cols;  % 从第3列开始每隔两列选择列

% 删除这些列
data(:, cols_to_delete) = [];

% ------------------------- 删除最后一列 NaN -------------------------
% 检查最后一列是否全为 NaN
if all(isnan(data(:, end)))  % 如果最后一列全是 NaN
    data(:, end) = [];      % 删除最后一列
end

% ------------------------- 读取光源数据 -------------------------
% 读取光源文件中的数据
source_data = readmatrix(sourceFilePath);  % 读取光源数据

% 确保光源数据的行数与CSV数据匹配
if length(source_data) ~= size(data, 1)
    error('光源数据的行数与CSV文件的数据行数不匹配！');
end

% ------------------------- 插入光源数据 -------------------------
% 将光源数据插入到处理后的数据的第二列
data = [data(:, 1), source_data, data(:, 2:end)];  % 将光源数据作为第二列插入

% ------------------------- 写入新的 CSV 文件 -------------------------
% 将处理后的数据写入新的CSV文件
writematrix(data, outputFilePath);

% 输出提示信息 
disp(['处理完成，结果已保存为 ', outputFileName]);
