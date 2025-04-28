function UI_txt_csv
    % 创建主窗口
    fig = figure('Name', 'TXT文件转CSV工具', 'Position', [300, 200, 600, 400], ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'on');
    
    % 创建面板
    panel = uipanel('Parent', fig, 'Title', '参数设置', ...
        'Position', [0.05, 0.55, 0.9, 0.4]);
    
    % 创建输入文件夹路径输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '输入文件夹路径:', ...
        'Position', [20, 110, 100, 20], 'HorizontalAlignment', 'left');
    folderPathEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [130, 110, 300, 25], 'String', 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '浏览...', ...
        'Position', [440, 110, 60, 25], 'Callback', @browseFolderCallback);
    
    % 创建输出文件夹输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '输出文件夹:', ...
        'Position', [20, 70, 100, 20], 'HorizontalAlignment', 'left');
    outputFolderEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [130, 70, 300, 25], 'String', 'D:\OneDrive\桌面\实验室_微机光纤传感器\auto_filter_new\txt\$RW7ZM59\探针-7\-15\');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '浏览...', ...
        'Position', [440, 70, 60, 25], 'Callback', @browseOutputFolderCallback);
    
    % 创建输出文件名输入
    uicontrol('Parent', panel, 'Style', 'text', 'String', '输出文件名:', ...
        'Position', [20, 30, 100, 20], 'HorizontalAlignment', 'left');
    outputFileNameEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [130, 30, 300, 25], 'String', 'txt_csv.csv');
    
    % 创建文件信息显示区域
    fileInfoText = uicontrol('Parent', panel, 'Style', 'text', ...
        'Position', [20, 0, 480, 20], 'String', '未选择文件', ...
        'HorizontalAlignment', 'left');
    
    % 创建状态显示区域
    statusText = uicontrol('Parent', fig, 'Style', 'text', ...
        'Position', [30, 50, 540, 30], 'String', '准备就绪', ...
        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % 创建进度条
    progressBar = uicontrol('Parent', fig, 'Style', 'slider', ...
        'Position', [30, 90, 540, 20], 'Min', 0, 'Max', 100, 'Value', 0, ...
        'Enable', 'off');
    
    % 创建执行按钮
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', '执行转换', ...
        'Position', [250, 15, 100, 30], 'Callback', @executeCallback);
    
    % 浏览输入文件夹回调函数
    function browseFolderCallback(~, ~)
        folder = uigetdir('', '选择TXT文件所在文件夹');
        if folder ~= 0
            set(folderPathEdit, 'String', [folder, '\']);
            updateFileInfo(folder);
        end
    end
    
    % 浏览输出文件夹回调函数
    function browseOutputFolderCallback(~, ~)
        folder = uigetdir('', '选择输出文件夹');
        if folder ~= 0
            set(outputFolderEdit, 'String', [folder, '\']);
        end
    end
    
    % 更新文件信息
    function updateFileInfo(folder)
        try
            files = dir([folder, '\*.txt']);
            set(fileInfoText, 'String', sprintf('找到 %d 个TXT文件', length(files)));
        catch
            set(fileInfoText, 'String', '无法读取文件夹信息');
        end
    end
    
    % 执行转换回调函数
    function executeCallback(~, ~)
        try
            % 获取UI输入参数
            folderPath = get(folderPathEdit, 'String');
            outputFolder = get(outputFolderEdit, 'String');
            outputFileName = get(outputFileNameEdit, 'String');
            % 构造完整的输出路径
            outputFilePath = fullfile(outputFolder, outputFileName);
            
            % 检查输入文件夹路径是否存在
            if ~exist(folderPath, 'dir')
                error('输入文件夹路径不存在');
            end
            
            % 更新状态显示
            set(statusText, 'String', '正在查找TXT文件...');
            drawnow;
            
            % 获取所有TXT文件
            files = dir([folderPath, '*.txt']);
            if isempty(files)
                error('未找到TXT文件');
            end
            
            set(statusText, 'String', sprintf('找到 %d 个TXT文件，开始处理...', length(files)));
            set(fileInfoText, 'String', sprintf('找到 %d 个TXT文件', length(files)));
            drawnow;
            
            % 初始化一个矩阵来存储所有的光强数据
            dataMatrix = [];
            
            % 处理每个文件
            for n = 1:length(files)
                % 更新进度条
                set(progressBar, 'Value', (n/length(files))*100);
                set(statusText, 'String', sprintf('正在处理第 %d/%d 个文件: %s', n, length(files), files(n).name));
                drawnow;
                
                % 读取当前文件的数据
                temp = dlmread([folderPath, files(n).name]);
                
                if n == 1
                    % 如果是第一个文件，保存第一列数据为波长数据
                    wavelength = temp(:, 1);
                    dataMatrix(:, 1) = wavelength;
                end
                
                if n == length(files)
                    % 如果是最后一个文件，假设只有一列光源强度数据
                    source_intensity = temp(:, 1);
                    dataMatrix(:, 2) = source_intensity;
                else
                    % 如果不是最后一个文件，提取第二列光强数据
                    if size(temp, 2) >= 2
                        intensity = temp(:, 2);
                        dataMatrix(:, n+2) = intensity;
                    else
                        error(['文件 ' files(n).name ' 中数据列数不足，无法提取光强数据']);
                    end
                end
            end
            
            % 保存结果为 CSV 文件
            set(statusText, 'String', '正在保存CSV文件...');
            drawnow;
            % 确保输出目录存在
            [outputDir, ~, ~] = fileparts(outputFilePath);
            if ~exist(outputDir, 'dir') && ~isempty(outputDir)
                mkdir(outputDir);
            end
            save(outputFilePath, '-ascii', 'dataMatrix');
            
            % 更新状态
            set(statusText, 'String', ['转换完成，结果已保存为: ', outputFilePath]);
            set(progressBar, 'Value', 100);
            
            % 显示成功消息（模态窗口）
            msgbox(['转换完成，结果已保存为: ', outputFilePath], '处理完成', 'modal');
            
        catch e
            % 显示错误信息
            set(statusText, 'String', ['错误: ', e.message]);
            errordlg(['处理过程中发生错误: ', e.message], '错误');
        end
    end
    
    % 初始化时更新文件信息
    updateFileInfo(get(folderPathEdit, 'String'));
end
