function UI_txt_csv
    % ����������
    fig = figure('Name', 'TXT�ļ�תCSV����', 'Position', [300, 200, 600, 400], ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'on');
    
    % �������
    panel = uipanel('Parent', fig, 'Title', '��������', ...
        'Position', [0.05, 0.55, 0.9, 0.4]);
    
    % �����ļ���·������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '�����ļ���·��:', ...
        'Position', [20, 110, 100, 20], 'HorizontalAlignment', 'left');
    folderPathEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [130, 110, 300, 25], 'String', 'D:\OneDrive\����\ʵ����_΢�����˴�����\auto_filter_new\txt\$RW7ZM59\̽��-7\-15\');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '���...', ...
        'Position', [440, 110, 60, 25], 'Callback', @browseFolderCallback);
    
    % ��������ļ�·������
    uicontrol('Parent', panel, 'Style', 'text', 'String', '����ļ�·��:', ...
        'Position', [20, 70, 100, 20], 'HorizontalAlignment', 'left');
    outputFileEdit = uicontrol('Parent', panel, 'Style', 'edit', ...
        'Position', [130, 70, 300, 25], 'String', 'D:\OneDrive\����\ʵ����_΢�����˴�����\auto_filter_new\txt\$RW7ZM59\̽��-7\-15\txt_csv.csv');
    uicontrol('Parent', panel, 'Style', 'pushbutton', 'String', '���...', ...
        'Position', [440, 70, 60, 25], 'Callback', @browseOutputFileCallback);
    
    % �����ļ���Ϣ��ʾ����
    fileInfoText = uicontrol('Parent', panel, 'Style', 'text', ...
        'Position', [20, 30, 480, 20], 'String', 'δѡ���ļ�', ...
        'HorizontalAlignment', 'left');
    
    % ����״̬��ʾ����
    statusText = uicontrol('Parent', fig, 'Style', 'text', ...
        'Position', [30, 50, 540, 30], 'String', '׼������', ...
        'HorizontalAlignment', 'left', 'FontSize', 10);
    
    % ����������
    progressBar = uicontrol('Parent', fig, 'Style', 'slider', ...
        'Position', [30, 90, 540, 20], 'Min', 0, 'Max', 100, 'Value', 0, ...
        'Enable', 'off');
    
    % ����ִ�а�ť
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'ִ��ת��', ...
        'Position', [250, 15, 100, 30], 'Callback', @executeCallback);
    
    % ����ļ��лص�����
    function browseFolderCallback(~, ~)
        folderPath = uigetdir('', 'ѡ��TXT�ļ������ļ���');
        if folderPath ~= 0
            set(folderPathEdit, 'String', [folderPath, '\']);
            updateFileInfo(folderPath);
        end
    end
    
    % �������ļ��ص�����
    function browseOutputFileCallback(~, ~)
        [fileName, pathName] = uiputfile({'*.csv', 'CSV�ļ� (*.csv)'}, '����CSV�ļ�');
        if fileName ~= 0
            set(outputFileEdit, 'String', fullfile(pathName, fileName));
        end
    end
    
    % �����ļ���Ϣ
    function updateFileInfo(folder)
        try
            files = dir([folder, '\*.txt']);
            set(fileInfoText, 'String', sprintf('�ҵ� %d ��TXT�ļ�', length(files)));
        catch
            set(fileInfoText, 'String', '�޷���ȡ�ļ�����Ϣ');
        end
    end
    
    % ִ��ת���ص�����
    function executeCallback(~, ~)
        try
            % ��ȡUI�������
            folderPath = get(folderPathEdit, 'String');
            outputFilePath = get(outputFileEdit, 'String');
            
            % ����ļ���·���Ƿ����
            if ~exist(folderPath, 'dir')
                error('�ļ���·��������');
            end
            
            % ����״̬
            set(statusText, 'String', '���ڲ���TXT�ļ�...');
            drawnow;
            
            % ��ȡ����TXT�ļ�
            file = dir([folderPath, '*.txt']);
            
            if isempty(file)
                error('δ�ҵ�TXT�ļ�');
            end
            
            set(statusText, 'String', sprintf('�ҵ� %d ��TXT�ļ�����ʼ����...', length(file)));
            set(fileInfoText, 'String', sprintf('�ҵ� %d ��TXT�ļ�', length(file)));
            drawnow;
            
            % ��ʼ��һ���������洢���еĹ�ǿ����
            data = [];
            
            % ����ÿ���ļ�
            for n = 1:length(file)
                % ���½�����
                set(progressBar, 'Value', (n/length(file))*100);
                set(statusText, 'String', sprintf('���ڴ���� %d/%d ���ļ�: %s', n, length(file), file(n).name));
                drawnow;
                
                % ��ȡ��ǰ�ļ�������
                temp = dlmread([folderPath, file(n).name]);
                
                if n == 1
                    % ����ǵ�һ���ļ��������һ������Ϊ��������
                    wavelength = temp(:, 1); % �����һ���ļ��ĵ�һ������
                    data(:, 1) = wavelength; % ����������ӵ� data �ĵ�һ��
                end
                
                if n == length(file)
                    % ��������һ���ļ�������ֻ��һ�й�Դǿ������
                    source_intensity = temp(:, 1); % ��ȡ��Դǿ������
                    data(:, 2) = source_intensity; % ����Դǿ�ȴ浽 data �ĵڶ���
                else
                    % ����������һ���ļ�����ȡ�ڶ��й�ǿ����
                    if size(temp, 2) >= 2
                        intensity = temp(:, 2); % ��ȡ��ǿ����
                        data(:, n+2) = intensity; % �ӵ����п�ʼ����洢��ǿ����
                    else
                        error(['�ļ� ' file(n).name ' �������������㣬�޷���ȡ��ǿ����']);
                    end
                end
            end
            
            % ������Ϊ CSV �ļ�
            set(statusText, 'String', '���ڱ���CSV�ļ�...');
            drawnow;
            
            % ȷ�����Ŀ¼����
            [outputDir, ~, ~] = fileparts(outputFilePath);
            if ~exist(outputDir, 'dir') && ~isempty(outputDir)
                mkdir(outputDir);
            end
            
            save(outputFilePath, '-ascii', 'data');
            
            % ����״̬
            set(statusText, 'String', ['ת����ɣ�����ѱ���Ϊ: ', outputFilePath]);
            set(progressBar, 'Value', 100);
            
            % ��ʾ�ɹ���Ϣ
            msgbox(['ת����ɣ�����ѱ���Ϊ: ', outputFilePath], '�������');
            
        catch e
            % ��ʾ������Ϣ
            set(statusText, 'String', ['����: ', e.message]);
            errordlg(['��������з�������: ', e.message], '����');
        end
    end
    
    % ��ʼ��ʱ�����ļ���Ϣ
    updateFileInfo(get(folderPathEdit, 'String'));
end