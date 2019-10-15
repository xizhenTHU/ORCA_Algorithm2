%定位起始数据
clear
% selpath='C:\工程文件\ORCA\代码\2_Algorithm2\Data\1564739132.995';
% selpath='C:\Users\WPD\Desktop\1565249228.996';
selpath='C:\Users\WPD\Desktop\1565259039.001';
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
%读取imu时间戳
dirTemp = dir([selpath,'\imu*']);
timeIMU = str2double(strtrim(erase(dirTemp.name,'imu_')));%imu启动时间
filename = [selpath,'\',dirTemp.name];
delimiter = ';';
formatSpec = '%f%f%f%f%*s%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
imuData = table(dataArray{1:end-1}, 'VariableNames', {'yaw','pitch','roll','timenum','lat','lng','mode'});
clearvars filename delimiter formatSpec fileID dataArray ans;
imuTimeNum=imuData.timenum;%单位微秒
imuTimeNum=(imuTimeNum-imuTimeNum(1))/1.e6;%imu时间戳,单位秒
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

dirTemp = dir([selpath,'\Laser*']);
timeLidar = str2double(strtrim(erase(dirTemp.name,'Laser_')));%激光雷达时间戳,单位秒

[timeMax,~]=max([timeMiliRadar,timeRealSense,timeIMU,timeLidar]);
[~,miliRadarIndexStart]=min(abs(miliRadarTimeNum-(timeMax-timeMiliRadar)))
[~,realsenseIndexStart]=min(abs(realsenseTimeNum-(timeMax-timeRealSense)))
[~,imuIndexStart]=min(abs(imuTimeNum-(timeMax-timeIMU)))



realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(realsenseIndexStart);
imuTimeNum=imuTimeNum-imuTimeNum(imuIndexStart);
miliRadarTimeNum=miliRadarTimeNum-miliRadarTimeNum(imuIndexStart);
