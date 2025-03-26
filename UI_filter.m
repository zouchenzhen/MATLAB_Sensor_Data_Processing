function UI
    % ����������
    fig = figure('Name', '�ź��˲�������', 'Position', [300, 200, 600, 500], ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'on');
    
    % �������
    panel = uipanel('Parent', fig, 'Title', '��������', ...
        'Position', [0.05, 0.55, 0.9, 0.4]);
    
    % �����ļ���·������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '�ļ���·��:', ...
        'Position', [20, 130, 80, 20], 'HorizontalAlignment', 'left');
    folderPathEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 130, 300, 25], 'String', 'D:\OneDrive\����\ʵ����_΢�����˴�����\auto_filter_new\txt\$RW7ZM59\̽��-7\-15\');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '���...', ...
        'Position', [420, 130, 60, 25], 'Callback', @browseFolderCallback);
    
    % ���������ļ�������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '�����ļ���:', ...
        'Position', [20, 95, 80, 20], 'HorizontalAlignment', 'left');
    inputFileEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 95, 300, 25], 'String', 'txt_csv.csv');
    
    % ��������ļ�������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '����ļ���:', ...
        'Position', [20, 60, 80, 20], 'HorizontalAlignment', 'left');
    outputFileEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 60, 300, 25], 'String', 'txt_csvfiltered.csv');
    
    % �����˲�����ֹƵ������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '��ֹƵ��:', ...
        'Position', [20, 25, 80, 20], 'HorizontalAlignment', 'left');
    fcEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [110, 25, 100, 25], 'String', '8');
    
    % ������ͼѡ��
    uicontrol('Parent', panel, 'Style', 'text', 'String', '��ͼѡ��:', ...
        'Position', [230, 25, 80, 20], 'HorizontalAlignment', 'left');
    plotOption = uicontrol('Parent', panel, 'Style', 'popupmenu', ...
        'Position', [320, 25, 160, 25], 'String', {'ֻ���Ƶ�һ������', '������������'});
    
    % ����״̬��ʾ����
    statusText = uicontrol('Parent', fig, 'Style', 'text', ...
        'Position', [30, 50, 540, 30], 'String', '׼������', ...
        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % ����������
    progressBar = uicontrol('Parent', fig, 'Style', 'slider', ...
        'Position', [30, 90, 540, 20], 'Min', 0, 'Max', 100, 'Value', 0, ...
        'Enable', 'off');
    
    % ����ִ�а�ť
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'ִ���˲�����', ...
        'Position', [250, 15, 100, 30], 'Callback', @executeCallback);
    
    % ����ļ��лص�����
    function browseFolderCallback(~, ~)
        folderPath = uigetdir('', 'ѡ�������ļ���');
        if folderPath ~= 0
            set(folderPathEdit, 'String', [folderPath, '\']);
        end
    end
    
    % ִ���˲�����ص�����
    function executeCallback(~, ~)
        try
            % ��ȡUI�������
            folderPath = get(folderPathEdit, 'String');
            inputFileName = get(inputFileEdit, 'String');
            outputFileName = get(outputFileEdit, 'String');
            fc = str2double(get(fcEdit, 'String'));
            plotOptionVal = get(plotOption, 'Value');
            
            % ���û�ͼѡ�� (1: ֻ����һ��, 0: �����е�)
            p = (plotOptionVal == 1);
            
            % ����״̬
            set(statusText, 'String', '���ڴ�������...');
            drawnow;
            
            % ���屣������·��
            outputFilePath = fullfile(folderPath, outputFileName);
            
            % ��ȡ CSV �ļ�
            filePath = fullfile(folderPath, inputFileName);
            set(statusText, 'String', ['���ڶ�ȡ�ļ�: ', inputFileName]);
            drawnow;
            data = load(filePath);  % �������ݣ����������Ǵ����ֵ�
            
            % ��ȡ�����͹�Դǿ������
            wavelength = data(:, 1);  % ��һ���ǲ���
            y0 = data(:, 2);  % �ڶ����ǹ�Դǿ��
            
            % ��ȡ�����Ĺ�ǿ���ݣ��ӵ����п�ʼ��
            measured_data = data(:, 3:end);
            
            % ��ʼ������洢�˲�������ݺͼ�Сֵ����
            filtered_data = [];
            min_values_wavelength = [];  % ���ڴ洢ÿ�����ݵļ�Сֵ����
            
            % �趨����Ƶ��
            fs = length(wavelength);
            
            % ����MATLAB�����д��ڵ��������
            format short;  % ��ʾ��׼����
            
            % ����ÿ���������
            totalGroups = size(measured_data, 2);
            for k = 1:totalGroups
                % ���½�����
                set(progressBar, 'Value', (k/totalGroups)*100);
                set(statusText, 'String', sprintf('���ڴ���� %d/%d ������...', k, totalGroups));
                drawnow;
                
                y1 = measured_data(:, k);  % ��ȡ��k������Ĺ�ǿ����
                
                % ����Դ�˲�
                Y = y1 - y0;  % ��ȥ��Դ�ź�
                
                % ������ǿ���ݣ�ȷ����ֵ�������-45
                Y(Y <= -45) = -45;
                
                % ȥ��ȱʧ����
                x = rmmissing(Y);
                
                % ����ʱ������������ʱ��Ͳ�����ͬ��
                t = wavelength(~isnan(Y));  % ʹ��ȥ��NaN��Ĳ�����Ϊʱ������
                
                % ���а�����˹��ͨ�˲���
                [b, a] = butter(6, fc / (fs / 2));  % 6�װ�����˹��ͨ�˲���
                y2 = filtfilt(b, a, x);  % Ӧ���˲���
                
                % �ж��Ƿ���Ҫ��ͼ
                if p == 0 || (p == 1 && k == 1)  % ��� p=1 �ҵ�ǰ�ǵ�һ���źţ����� p=0 ���������ź�
                    figure;
                    plot(t, x, 'b', 'LineWidth', 1.5);  % ԭʼ�źţ���ɫ��
                    hold on;
                    plot(t, y2, 'r', 'LineWidth', 1.5);  % �˲����źţ���ɫ��
                    xlabel('������nm��');
                    ylabel('��ǿ');
                    legend('ԭʼ�ź�', '�˲����ź�');
                    title(['�źŶԱ� - �� ', num2str(k)]);
                    grid on;
                    hold off;
                end
                
                % ���˲����������ӵ������У�������ԭ���ݴ�Сһ��
                filtered_column = nan(length(wavelength), 1);
                filtered_column(~isnan(Y)) = y2;
                filtered_data(:, k) = filtered_column;
                
                % ���Ҿֲ���Сֵ�����Ӧ�Ĳ���
                min_idx = islocalmin(y2);  % ��ȡ�ֲ���Сֵ������
                min_wavelength = t(min_idx);  % ��Ӧ�Ĳ���
                
                % ���漫Сֵ������Ϣ��������
                min_values_wavelength(1:length(min_wavelength), k) = min_wavelength;  % ��ÿ�еļ�Сֵ�����洢��������
            end
            
            % �Լ�Сֵ���������������ת��
            min_values_transposed = min_values_wavelength.';  % ת�ú�ľ���
            
            % ��ȡת�ú�ļ�Сֵ��������������������ݵ�������
            num_measurements = size(min_values_transposed, 2);
            
            % ����һ���վ����� `filtered_data` һ�£����ڴ��ת�ú�ļ�Сֵ��������
            final_data_with_min = [wavelength, filtered_data];  % ��ʼΪ�����к��˲�����
            
            % ȷ��ת�ú�ļ�Сֵ����������� `final_data_with_min` ������һ��
            % ͨ����� NaN ʹ����ƥ��
            min_values_transposed_padded = [min_values_transposed; nan(size(final_data_with_min, 1) - size(min_values_transposed, 1), num_measurements)];
            
            % ��ת�ú�ļ�Сֵ�������ݲ��뵽 final_data_with_min �ĺ���λ��
            final_data_with_min(:, end + 1 : end + num_measurements) = min_values_transposed_padded;
            
            % �����д�� CSV �ļ�
            set(statusText, 'String', '���ڱ�����...');
            drawnow;
            writematrix(final_data_with_min, outputFilePath, 'Delimiter', ',');
            
            % ����״̬
            set(statusText, 'String', ['�˲�������ɣ�����ѱ���Ϊ ', outputFileName]);
            set(progressBar, 'Value', 100);
            
            % ��ʾ�ɹ���Ϣ
            msgbox(['�˲�������ɣ�����ѱ���Ϊ ', outputFileName], '�������');
            
        catch e
            % ��ʾ������Ϣ
            set(statusText, 'String', ['����: ', e.message]);
            errordlg(['��������з�������: ', e.message], '����');
        end
    end
end
