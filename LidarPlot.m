%绘制激光雷达
clear;close all
% filename = 'C:\工程文件\ORCA\代码\2_Algorithm2\shiwaishiwai1.csv';
% filename = 'C:\工程文件\ORCA\代码\2_Algorithm2\Lidar\datacollectsystem\laser\123.csv';
% filename = 'C:\工程文件\ORCA\代码\2_Algorithm2\Lidar\datacollectsystem\laser\789_.csv';
% filename = 'C:\工程文件\ORCA\代码\2_Algorithm2\lidartest\0811shinei2.csv';
selpath='C:\Users\WPD\Desktop\1565259039.001';
filename = [selpath,'\shiwaishiwai9.csv'];
delimiter = ',';
formatSpec = '%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
AngleHorizontal = dataArray{:, 1};
AngleVertical = dataArray{:, 2};
dist = dataArray{:, 3}/100;
reflectivity = dataArray{:, 4};
time = dataArray{:, 5}/1000;
clearvars filename delimiter formatSpec fileID dataArray ans;

% dist(reflectivity<45)=0;
del=(reflectivity==0);
AngleVertical(del)=[];
AngleHorizontal(del)=[];
dist(del)=[];
time(del)=[];
reflectivity(del)=[];
 
z=dist.*sind(AngleVertical);
y=dist.*cosd(AngleVertical).*cosd(AngleHorizontal);
x=dist.*cosd(AngleVertical).*sind(AngleHorizontal);

[~,ia,~] = unique(time);
freq=167;
num=floor(length(ia)/freq);

Xlim = [-20 40]/1;Ylim = [-25 25]/1;
Zlim = [0 10];Clim = [1 100];

figure;
for ii=1:num
    cut=ia((ii-1)*freq+1):ia(ii*freq)-1;
    scatter3(x(cut),y(cut),z(cut),2,reflectivity(cut),'filled');axis equal
%     scatter3(x(cut),y(cut),z(cut),5,dist(cut),'filled');axis equal
    %xlim([min(x) max(x)]);ylim([min(y) max(y)]);zlim([min(z) max(z)]);
    xlim([Xlim(1) Xlim(2)]);ylim([Ylim(1) Ylim(2)]);zlim([Zlim(1) Zlim(2)]);
    pause(1/freq)
end


% scatter3(x,y,z,5,dist,'filled');axis equal
% figure;plot(AngleHorizontal(cut))
% (36310-4254)/192