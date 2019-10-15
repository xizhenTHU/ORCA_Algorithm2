function [AngleHorizontal,AngleVertical,dist,lidarTimeNum,reflectivity]=readLidarCSV(app,filename)
%LidarCSV读取
delimiter = ',';
formatSpec = '%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
AngleHorizontal = dataArray{:, 1};
AngleVertical = dataArray{:, 2};
dist = dataArray{:, 3}/100;%单位米
reflectivity = dataArray{:, 4};
lidarTimeNum = dataArray{:, 5}/1000;%单位秒
% clearvars filename delimiter formatSpec fileID dataArray ans;
del=(dist>15|dist<1.7|reflectivity<65);
% del=[];
AngleVertical(del)=[];
AngleHorizontal(del)=[];
dist(del)=[];
lidarTimeNum(del)=[];
reflectivity(del)=[];
% [~,~,ic] = unique(dist,'rows','stable');
end