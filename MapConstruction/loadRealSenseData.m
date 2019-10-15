function [timeRealSense,realsenseTimeNum,data] = loadRealSenseData(selpath,data)
%%���ز�����realsense����
% ���� RealSense����ʱ�䣬RealSenseʱ�����data����
data.dirRGB = dir([selpath,'\realsense*\rgb\*.jpg']);
data.dirDeepth = dir([selpath,'\realsense*\depth\*.jpg']);

%��ȡrealsenseʱ���
dirTemp = dir([selpath,'\realsense*']);
timeRealSense = str2double(strtrim(erase(dirTemp.name,'realsense_')));%realsense����ʱ��
dirTemp = dir([selpath,'\',dirTemp.name,'\imu.csv']);
filename = [dirTemp.folder,'\',dirTemp.name];
delimiter = ',';
formatSpec = '%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
realsenseTimeNum = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(1);%realsenseʱ���,��λ��
end

