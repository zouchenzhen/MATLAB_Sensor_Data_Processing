function UI
    % 创建主窗口
    fig = figure('Name', '信号滤波处理工具', 'Position', [300, 200, 600, 500], ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'on');
    
    % 创建面板
    panel = uipanel('Parent', fig, 'Title', '参数设置', ...
        'Position', [0.05, 0.55, 0.9, 0.4]);
    
    % 创建文件夹路径输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '文件夹路径:', ...
        'Position', [20, 130, 80, 20], 'HorizontalAlignment', 'left');
    folderPathEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 130, 300, 25], 'String', 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '浏览...', ...
        'Position', [420, 130, 60, 25], 'Callback', @browseFolderCallback);
    
    % 创建输入文件名输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '输入文件名:', ...
        'Position', [20, 95, 80, 20], 'HorizontalAlignment', 'left');
    inputFileEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 95, 300, 25], 'String', 'txt_csv.csv');
    
    % 创建输出文件名输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '输出文件名:', ...
        'Position', [20, 60, 80, 20], 'HorizontalAlignment', 'left');
    outputFileEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 60, 300, 25], 'String', 'txt_csvfiltered.csv');
    
    % 创建滤波器截止频率输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '截止频率:', ...
        'Position', [20, 25, 80, 20], 'HorizontalAlignment', 'left');
    fcEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 25, 100, 25], 'String', '8');
    
    % 创建绘图选项
    uicontrol('Parent', panel, 'Style', 'text', 'String', '绘图选项:', ...
        'Position', [230, 25, 80, 20], 'HorizontalAlignment', 'left');
    plotOption = uicontrol('Parent', panel, 'Style', 'popupmenu', ...
        'Position', [320, 25, 160, 25], 'String', {'只绘制第一组数据', '绘制所有数据'});
    
    % 创建状态显示区域
    statusText = uicontrol('Parent', fig, 'Style', 'text', ...
        'Position', [30, 50, 540, 30], 'String', '准备就绪', ...
        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % 创建进度条
    progressBar = uicontrol('Parent', fig, 'Style', 'slider', ...
        'Position', [30, 90, 540, 20], 'Min', 0, 'Max', 100, 'Value', 0, ...
        'Enable', 'off');
    
    % 创建执行按钮
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '执行滤波处理', ...
        'Position', [250, 15, 100, 30], 'Callback', @executeCallback);
    
    % 浏览文件夹回调函数
    function browseFolderCallback(~, ~)
        folderPath = uigetdir('', '选择数据文件夹');
        if folderPath ~= 0
            set(folderPathEdit, 'String', [folderPath, '\']);
        end
    end
    
    % 执行滤波处理回调函数
    function executeCallback(~, ~)
        try
            % 获取UI输入参数
            folderPath = get(folderPathEdit, 'String');
            inputFileName = get(inputFileEdit, 'String');
            outputFileName = get(outputFileEdit, 'String');
            fc = str2double(get(fcEdit, 'String'));
            plotOptionVal = get(plotOption, 'Value');
            
            % 设置绘图选项 (1: 只画第一个, 0: 画所有的)
            p = (plotOptionVal == 1);
            
            % 更新状态
            set(statusText, 'String', '正在处理数据...');
            drawnow;
            
            % 定义保存结果的路径
            outputFilePath = fullfile(folderPath, outputFileName);
            
            % 读取 CSV 文件
            filePath = fullfile(folderPath, inputFileName);
            set(statusText, 'String', ['正在读取文件: ', inputFileName]);
            drawnow;
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
            totalGroups = size(measured_data, 2);
            for k = 1:totalGroups
                % 更新进度条
                set(progressBar, 'Value', (k/totalGroups)*100);
                set(statusText, 'String', sprintf('正在处理第 %d/%d 组数据...', k, totalGroups));
                drawnow;
                
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
            set(statusText, 'String', '正在保存结果...');
            drawnow;
            writematrix(final_data_with_min, outputFilePath, 'Delimiter', ',');
            
            % 更新状态
            set(statusText, 'String', ['滤波处理完成，结果已保存为 ', outputFileName]);
            set(progressBar, 'Value', 100);
            
            % 显示成功消息
            msgbox(['滤波处理完成，结果已保存为 ', outputFileName], '处理完成');
            
        catch e
            % 显示错误信息
            set(statusText, 'String', ['错误: ', e.message]);
            errordlg(['处理过程中发生错误: ', e.message], '错误');
        end
    end
end
