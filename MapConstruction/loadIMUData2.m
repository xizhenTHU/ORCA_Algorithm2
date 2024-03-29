function [timeIMU,data] = loadIMUData2(selpath,data)
%时间戳以GPS时间戳为准
%%加载并处理imu数据
% 返回IMU启动时间,data数组

%读取imu时间戳
dirTemp = dir([selpath,'\imu*']);
timeIMU = str2double(strtrim(erase(dirTemp.name,'imu_')));%imu启动时间
filename = [selpath,'\',dirTemp.name];
delimiter = ';';
formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
data.imuData = table(dataArray{1:end-1}, 'VariableNames', {'timeIMU','roll','pitch','yaw','gpsYaw','gpsTime','lat','lng','mode'});
[~,ia,~] = unique(data.imuData.gpsTime,'rows','stable');
data.imuData=data.imuData(ia,:);
data.imuData.timenum=zeros(size(data.imuData.gpsTime));
for ii=1:length(data.imuData.gpsTime)
    temp=num2str(data.imuData.gpsTime(ii)*100);
    data.imuData.timenum(ii)=double(string(temp(1:2)))*3600+double(string(temp(3:4)))*60+double(string(temp(5:end)));
end
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(1);
clearvars filename delimiter formatSpec fileID dataArray ans;
end

