% �������ݺ�ָ������
x = VarName1; % �滻Ϊ��� x ������
y = y1; % �滻Ϊ��� y ������
start_x = 1400; % ָ�� x �᷶Χ����ʼֵ
end_x = 1450; % ָ�� x �᷶Χ�Ľ���ֵ
% ȷ��ָ�������ڵ�����
start_index = find(x >= start_x, 1);
end_index = find(x <= end_x, 1, 'last');
% �и�ָ�������ڵ�����
subset_y = y(start_index:end_index);
subset_x = x(start_index:end_index);
% �ҵ���Сֵ�Ͷ�Ӧ������
[min_value, min_index] = min(subset_y);
% �ҵ���Ӧ�� x �� y ֵ
x_value = subset_x(min_index);
y_value = subset_y(min_index);
% ������
disp(['��ָ�� x ��Χ�ڣ�y ����Сֵ�� ', num2str(min_value)]);
disp(['��Ӧ�� x ֵ�� ', num2str(x_value)]);
disp(['��Ӧ�� y ֵ�� ', num2str(y_value)]);