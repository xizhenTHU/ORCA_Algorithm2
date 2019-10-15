function [timeRealSense,realsenseTimeNum,data] = loadRealSenseData(selpath,data)
%%加载并处理realsense数据
% 返回 RealSense启动时间，RealSense时间戳，data数组
data.dirRGB = dir([selpath,'\realsense*\rgb\*.jpg']);
data.dirDeepth = dir([selpath,'\realsense*\depth\*.jpg']);

%读取realsense时间戳
dirTemp = dir([selpath,'\realsense*']);
timeRealSense = str2double(strtrim(erase(dirTemp.name,'realsense_')));%realsense启动时间
dirTemp = dir([selpath,'\',dirTemp.name,'\imu.csv']);
filename = [dirTemp.folder,'\',dirTemp.name];
delimiter = ',';
formatSpec = '%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
realsenseTimeNum = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(1);%realsense时间戳,单位秒
end

