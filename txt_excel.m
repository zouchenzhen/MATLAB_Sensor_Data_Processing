file=dir('D:\OneDrive\桌面\实验室_微机光纤传感器\guojiaming\2024.11.6\2024.11.6\ag+ito\*.txt');%选择纯TXT文件夹
for n=1:length(file)
    
temp=dlmread(['D:\OneDrive\桌面\实验室_微机光纤传感器\guojiaming\2024.11.6\2024.11.6\ag+ito\',file(n).name]);%与第一行读取数据一致
temp=temp(:,2);
data(:,n)=temp;
end
save D:\OneDrive\桌面\实验室_微机光纤传感器\guojiaming\txt_excel\rs.csv -ascii data;

