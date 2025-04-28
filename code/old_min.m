% 输入数据和指定区间
x = VarName1; % 替换为你的 x 轴数据
y = y1; % 替换为你的 y 轴数据
start_x = 1400; % 指定 x 轴范围的起始值
end_x = 1450; % 指定 x 轴范围的结束值
% 确定指定区间内的索引
start_index = find(x >= start_x, 1);
end_index = find(x <= end_x, 1, 'last');
% 切割指定区间内的数据
subset_y = y(start_index:end_index);
subset_x = x(start_index:end_index);
% 找到最小值和对应的索引
[min_value, min_index] = min(subset_y);
% 找到对应的 x 和 y 值
x_value = subset_x(min_index);
y_value = subset_y(min_index);
% 输出结果
disp(['在指定 x 范围内，y 的最小值是 ', num2str(min_value)]);
disp(['对应的 x 值是 ', num2str(x_value)]);
disp(['对应的 y 值是 ', num2str(y_value)]);
