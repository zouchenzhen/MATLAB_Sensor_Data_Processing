% 定义文件夹路径作为常量
folderPath = 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\';
outputFilePath = 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\txt_csv.csv';
file = dir([folderPath, '*.txt']);

% 初始化一个矩阵来存储所有的光强数据
data = [];

for n = 1:length(file)
    % 读取当前文件的数据
    temp = dlmread([folderPath, file(n).name]);
    
    if n == 1
        % 如果是第一个文件，保存第一列数据为波长数据
        wavelength = temp(:, 1); % 保存第一个文件的第一列数据
        data(:, 1) = wavelength; % 将波长列添加到 data 的第一列
    end
    
    if n == length(file)
        % 如果是最后一个文件，假设只有一列光源强度数据
        source_intensity = temp(:, 1); % 读取光源强度数据
        data(:, 2) = source_intensity; % 将光源强度存到 data 的第二列
    else
        % 如果不是最后一个文件，提取第二列光强数据
        if size(temp, 2) >= 2
            intensity = temp(:, 2); % 提取光强数据
            data(:, n+2) = intensity; % 从第三列开始逐个存储光强数据
        else
            error(['文件 ' file(n).name ' 中数据列数不足，无法提取光强数据']);
        end
    end
end

% 保存结果为 CSV 文件
save(outputFilePath, '-ascii', 'data');
