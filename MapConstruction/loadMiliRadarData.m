function [timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data)
%%加载并处理毫米波雷达
% 返回 毫米波雷达启动时间，毫米波雷达时间戳，data数组
dirMiliRadar = dir([selpath,'\radar*\*data*.txt']);
data.MiliRadarData1=readData1843([dirMiliRadar(1).folder,'\',dirMiliRadar(1).name]).';
data.MiliRadarData2=readData1843([dirMiliRadar(2).folder,'\',dirMiliRadar(2).name]).';
data.MiliRadarData3=readData1843([dirMiliRadar(3).folder,'\',dirMiliRadar(3).name]).';

%读取毫米波雷达时间戳
dirTemp = dir([selpath,'\radar*']);
timeMiliRadar = str2double(strtrim(erase(dirTemp.name,'radar_')));%毫米波雷达启动时间
dirTemp = dir([selpath,'\',dirTemp.name,'\radar1_time*.txt']);
filename = [dirTemp.folder,'\',dirTemp.name];
delimiter = ' ';
formatSpec = '%*s%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
miliRadarTimeNum = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;
miliRadarTimeNum=(miliRadarTimeNum-miliRadarTimeNum(1))/1.e3;%毫米波雷达时间戳,单位秒
end

