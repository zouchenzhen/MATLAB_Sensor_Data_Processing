# 光纤传感器数据处理工具集

## 项目概述

本项目是为光纤生物传感器实验室开发的一套MATLAB数据处理工具集，旨在自动化和简化光谱数据的处理流程。通过开发一系列具有图形用户界面(GUI)的程序，大大提高了数据处理效率，解放了研究人员的双手，使他们能够更专注于科研工作而非繁琐的数据处理步骤。

项目开发始于2024年6月（作者本人当时处于大二下学期），解决了实验室原有代码老旧、功能不全、操作繁琐等问题，极大地提高了传感器开发测试的速度。

## 功能演示图
![image](https://github.com/zouchenzhen/MATLAB_Sensor_Data_Processing/blob/main/img/UI_txt_csv.jpg)
![image](https://github.com/zouchenzhen/MATLAB_Sensor_Data_Processing/blob/main/img/UI_auto_update_config.jpg)
![image](https://github.com/zouchenzhen/MATLAB_Sensor_Data_Processing/blob/main/img/UI_auto_update_config_final.jpg)
![image](https://github.com/zouchenzhen/MATLAB_Sensor_Data_Processing/blob/main/img/final.jpg)

## 主要功能

本工具集包含以下主要功能模块：

1. **TXT文件转CSV工具 (UI_txt_csv.m)**
   - 将多个TXT格式的光谱数据文件合并为单个CSV文件
   - 自动提取波长数据和光源强度数据
   - 支持批量处理多组测量数据

2. **数据预处理工具 (csv_pre_delete.m)**
   - 删除CSV文件中的无效数据行
   - 删除指定列数据（如从第3列开始的奇数列）
   - 插入光源数据作为第二列

3. **信号滤波与极小值提取工具 (UI.m)**
   - 减光源滤波：从测量数据中减去光源强度数据
   - 巴特沃斯低通滤波：对数据进行平滑处理
   - 局部极小值提取：查找并记录滤波后信号的局部极小值及对应波长
   - 数据可视化：绘制原始信号与滤波后信号的对比图
  
4. **信号滤波与极小值提取最近工具 (UI_compatible.m)**
   - 新增功能1：可自动保存新的配置参数，提高效率
   - 新增功能2：可兼容csv与xlsx格式输入输出（源于实验室仿真的数据处理需要）  
## 技术实现

### TXT文件转CSV工具

该工具实现了将多个TXT格式的光谱数据文件合并为单个CSV文件的功能。处理流程如下：

1. 读取指定文件夹中的所有TXT文件
2. 从第一个文件中提取波长数据（第一列）
3. 从最后一个文件中提取光源强度数据（第一列）
4. 从其他文件中提取光强数据（第二列）
5. 将所有数据合并为一个矩阵并保存为CSV文件

```matlab
% 核心处理逻辑
for n = 1:length(file)
    % 读取当前文件的数据
    temp = dlmread([folderPath, file(n).name]);
    
    if n == 1
        % 如果是第一个文件，保存第一列数据为波长数据
        wavelength = temp(:, 1);
        data(:, 1) = wavelength;
    end
    
    if n == length(file)
        % 如果是最后一个文件，假设只有一列光源强度数据
        source_intensity = temp(:, 1);
        data(:, 2) = source_intensity;
    else
        % 如果不是最后一个文件，提取第二列光强数据
        if size(temp, 2) >= 2
            intensity = temp(:, 2);
            data(:, n+2) = intensity;
        else
            error(['文件 ' file(n).name ' 中数据列数不足，无法提取光强数据']);
        end
    end
end
```

### 信号滤波与极小值提取工具

该工具实现了对光谱数据的滤波处理和极小值提取功能。处理流程如下：

1. 读取CSV文件中的波长数据、光源强度数据和测量光强数据
2. 对每组测量数据进行减光源滤波（减去光源强度数据）
3. 使用巴特沃斯低通滤波器对数据进行平滑处理
4. 查找滤波后信号的局部极小值及对应波长
5. 将滤波后的数据和极小值波长信息保存为CSV文件

```matlab
% 核心滤波和极小值提取逻辑
for k = 1:size(measured_data, 2)
    y1 = measured_data(:, k);
    
    % 减光源滤波
    Y = y1 - y0;
    
    % 修正光强数据
    Y(Y <= -45) = -45;
    
    % 去除缺失数据
    x = rmmissing(Y);
    
    % 生成时间向量
    t = wavelength(~isnan(Y));
    
    % 巴特沃斯低通滤波
    [b, a] = butter(6, fc / (fs / 2));
    y2 = filtfilt(b, a, x);
    
    % 查找局部极小值
    min_idx = islocalmin(y2);
    min_wavelength = t(min_idx);
    
    % 保存极小值波长信息
    min_values_wavelength(1:length(min_wavelength), k) = min_wavelength;
end
```

## 用户界面设计

为了提高工具的易用性，2025年3月我为主要功能模块开发了图形用户界面(GUI)。界面设计遵循简洁、直观的原则，主要包括以下组件：

1. **参数设置区域**：用于设置文件路径、输入/输出文件名、滤波参数等
2. **文件浏览按钮**：方便用户选择文件和文件夹
3. **状态显示区域**：显示当前处理状态和进度
4. **执行按钮**：启动数据处理流程
5. **进度条**：直观显示处理进度

界面设计采用MATLAB的UI控件，如uipanel、uicontrol等，实现了参数输入、文件选择、状态显示等功能。

## 开发历程与版本迭代

### v1.0 - 基础功能实现
- 实现TXT文件转CSV的基本功能
- 实现数据预处理功能（删除行列、插入光源数据）
- 实现基本的信号滤波功能

### v2.0 - 功能增强与优化
- 增加局部极小值提取功能
- 优化滤波算法，提高数据处理精度
- 增加数据可视化功能，绘制原始信号与滤波后信号的对比图

### v3.0 - 图形用户界面开发
- 为主要功能模块开发图形用户界面
- 增加文件浏览功能，方便用户选择文件和文件夹
- 增加进度显示功能，提高用户体验

### v4.0 - 综合优化与开源发布
- 整合各功能模块，形成完整的工具集
- 优化代码结构，提高可维护性
- 编写详细文档，准备开源发布

### v4.1 - 修补完善UI界面
- 输入输出能兼容csv和xlsx文件
- 文件路径，输入输出名称自动保存，新运行后能使用上次最新的配置

## 项目结构

```
光纤传感器数据处理工具集/
├── UI_compatible.m              # V4.1 UI兼容完善版本
├── UI_txt_csv.m                 # TXT文件转CSV工具（带GUI）
├── UI_filter.m                  # 信号滤波与极小值提取工具（带GUI）
├── txt_csv_pro.m                # TXT文件转CSV工具（命令行版本）
├── auto_filter_min_saved_pro.m  # 信号滤波与极小值提取工具（命令行版本）
├── auto_filter_min_saved.m      # 极小值提取工具（NaN输出版本）
├── auto_filter_min_output.m     # 极小值提取工具（命令行输出版本）
├── auto_filter_file.m           # 基础滤波处理工具
├── csv_pre_delete.m             # 数据预处理工具
├── old_filter_pro.m             # 旧版滤波工具（参考用）
├── old_filter.m                 # 旧版基础滤波工具
├── old_min.m                    # 旧版极小值提取工具
├── 10-119.txt                   # 传感测量数据TXT文件示例
├── txt_csv.csv                  # CSV文件滤波前示例
├── txt_csvfiltered.csv          # CSV文件滤波后示例
├── z_光源_1500_1550.txt         # TXT光源文件示例
└── README.md                    # 项目说明文档
```

## 使用说明

### 环境要求
- 作者本人使用的是MATLAB R2023b版本（考虑到代码兼容性，建议不要低于此版本）
- 无需额外工具箱

### TXT文件转CSV工具使用方法

1. 在MATLAB中运行`UI_txt_csv.m`
2. 在界面中设置以下参数：
   - 输入文件夹路径：包含TXT文件的文件夹
   - 输出文件路径：保存CSV文件的路径
3. 点击"执行转换"按钮开始处理
4. 处理完成后，结果将保存为指定的CSV文件

### 信号滤波与极小值提取工具使用方法

1. 在MATLAB中运行`UI.m`
2. 在界面中设置以下参数：
   - 文件夹路径：包含CSV文件的文件夹
   - 输入文件名：待处理的CSV文件名
   - 输出文件名：处理后保存的CSV文件名
   - 截止频率：滤波器截止频率
   - 绘图选项：选择只绘制第一个时域图或全部图像
3. 点击"执行滤波处理"按钮开始处理
4. 处理完成后，结果将保存为指定的CSV文件，并显示原始信号与滤波后信号的对比图

### 命令行版TXT文件转CSV工具使用方法 (txt_csv_pro.m)

1. 打开`txt_csv_pro.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的TXT文件夹路径';
   outputFilePath = '您的输出CSV文件路径';
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件

### TXT转Excel工具使用方法 (txt_excel.m)

1. 打开`txt_excel.m`文件
2. 修改以下参数：
   ```matlab
   file=dir('您的TXT文件夹路径\*.txt');
   save 您的输出Excel文件路径.csv -ascii data;
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件（可用Excel打开）

### 数据预处理工具使用方法 (csv_pre_delete.m)

1. 打开`csv_pre_delete.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的文件夹路径';
   inputFileName = '您的输入CSV文件名.csv';
   outputFileName = '您的输出CSV文件名.csv';
   sourceFileName = '光源文件名.txt';
   ```
3. 运行脚本
4. 处理完成后，脚本将：
   - 删除CSV文件前256行
   - 删除从第3列开始的奇数列
   - 插入光源数据作为第二列
   - 将结果保存为指定的CSV文件

### 命令行版信号滤波与极小值提取工具使用方法 (auto_filter_min_saved_pro.m)

1. 打开`auto_filter_min_saved_pro.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的文件夹路径';
   inputFileName = '您的输入CSV文件名.csv';
   outputFileName = '您的输出CSV文件名.csv';
   fc = 8;  % 滤波器截止频率
   p = 1;   % 是否只画一个时域图 (1: 只画第一个, 0: 画所有的)
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件，并显示原始信号与滤波后信号的对比图

### NaN输出极小值版本工具使用方法 (auto_filter_min_saved.m)

1. 打开`auto_filter_min_saved.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的文件夹路径';
   outputFilePath = fullfile(folderPath, '您的输出CSV文件名.csv');
   filePath = fullfile(folderPath, '您的输入CSV文件名.csv');
   fc = 18;  % 滤波器截止频率（默认为18）
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件，极小值将以NaN形式在原位置标记

### 命令行输出极小值版本工具使用方法 (auto_filter_min_output.m)

1. 打开`auto_filter_min_output.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的文件夹路径';
   outputFilePath = fullfile(folderPath, '您的输出CSV文件名.csv');
   filePath = fullfile(folderPath, '您的输入CSV文件名.csv');
   fc = 18;  % 滤波器截止频率（默认为18）
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件，并在命令窗口中输出每个极小值的波长和光强（保留两位小数）

### 基础滤波处理工具使用方法 (auto_filter_file.m)

1. 打开`auto_filter_file.m`文件
2. 修改以下参数：
   ```matlab
   folderPath = '您的文件夹路径';
   outputFilePath = fullfile(folderPath, '您的输出CSV文件名.csv');
   filePath = fullfile(folderPath, '您的输入CSV文件名.csv');
   fc = 18;  % 滤波器截止频率（默认为18）
   ```
3. 运行脚本
4. 处理完成后，结果将保存为指定的CSV文件，并显示原始信号与滤波后信号的对比图

### 旧版滤波工具使用方法 (old_filter_pro.m)

1. 打开`old_filter_pro.m`文件
2. 修改以下参数：
   ```matlab
   raw_data = '您的光源数据';  % 粘贴数据，使用空格分隔
   ```
3. 运行脚本
4. 处理完成后，将显示原始信号、傅里叶变换、滤波后信号和滤波后信号的傅里叶变换

### 完整数据处理流程建议

对于完整的数据处理流程，建议按以下顺序使用工具：

1. 使用`UI_txt_csv.m`或`txt_csv_pro.m`将TXT文件转换为CSV文件
2. 使用`csv_pre_delete.m`对CSV文件进行预处理
3. 使用`UI.m`或`auto_filter_min_saved_pro.m`对预处理后的数据进行滤波和极小值提取
4. 根据需要，使用`auto_filter_min_output.m`查看具体的极小值波长和光强

## 开发心得

1. **问题驱动开发**：本项目源于实验室实际需求，通过解决实际问题提高了编程能力和问题解决能力。

2. **模块化设计**：将复杂的数据处理流程拆分为多个功能模块，提高了代码的可维护性和可扩展性。

3. **用户体验优先**：通过开发图形用户界面，大大提高了工具的易用性，使非专业人员也能轻松使用。

4. **迭代优化**：在开发过程中不断收集用户反馈，进行迭代优化，使工具更加符合用户需求。

5. **文档与注释**：编写详细的代码注释和使用文档，方便他人理解和使用工具。

## 未来计划

1. **功能扩展**：增加更多数据处理功能，如数据归一化、峰值检测等。

2. **算法优化**：优化滤波算法，提高数据处理精度和效率。

3. **界面美化**：改进用户界面设计，提高用户体验。

4. **跨平台支持**：考虑将工具移植到其他平台，如Python，以支持更多用户。

5. **自动化程度提高**：进一步提高数据处理的自动化程度，减少人工干预。

## 贡献者

- 主要开发者：邹晨振
- 指导教师：杨县超
- 实验室：郑州大学电子材料与通信系统实验室

## 特别鸣谢

- 实验室各位学长学姐：杨冠、杨凡、郭家明、宋瑶佳

## 开源文档撰写日期

- 2025/03/21

## 许可证

本项目采用MIT许可证开源。

---

*注：本项目为光纤生物传感器实验室内部使用工具，开源旨在分享经验和技术，欢迎交流和改进。*
