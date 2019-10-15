%GUI改制
clear
selpath='E:\d20190905\1567669452.100';

app.indexLidarCSV=1;
%%加载并处理imu数据
%读取imu时间戳
dirTemp = dir([selpath,'\imu*']);
timeIMU = str2double(strtrim(erase(dirTemp.name,'imu_')));%imu启动时间
filename = [selpath,'\',dirTemp.name];
delimiter = ';';
formatSpec = '%f%f%f%f%*s%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
app.imuData = table(dataArray{1:end-1}, 'VariableNames', {'yaw','pitch','roll','timenum','lat','lng','mode'});
clearvars filename delimiter formatSpec fileID dataArray ans;
app.imuData.lat=app.imuData.lat/1;
app.imuData.lng=app.imuData.lng/1;
app.imuData.timenum=(app.imuData.timenum-app.imuData.timenum(1))/1.e6;%imu时间戳,单位秒
disp('imu数据加载完毕!');


%%加载并处理激光雷达
app.lidarDirCSV=dir([selpath,'\*.csv']);
[~,ind]=sort([app.lidarDirCSV(:).datenum]);
app.lidarDirCSV=app.lidarDirCSV(ind);
filename = [app.lidarDirCSV(1).folder,'\',app.lidarDirCSV(1).name];
[app.LidarData.AngleHorizontal,AngleVertical,app.LidarData.dist,lidarTimeNum,app.LidarData.reflectivity]=readLidarCSV(app,filename);
lidarTimeFirst=lidarTimeNum(1);
lidarTimeNum=lidarTimeNum-lidarTimeNum(1);
disp('激光雷达数据加载完毕!');
%激光雷达时间戳
dirTemp = dir([selpath,'\Laser*']);
timeLidar = str2double(strtrim(erase(dirTemp.name,'Laser_')));%激光雷达时间戳,单位秒

%时间戳初始对准
[timeMax,~]=max([timeIMU,timeLidar]);
[imuIndexStartMin,imuIndexStart]=min(abs(app.imuData.timenum-(timeMax-timeIMU)));
[lidarIndexStartMin,lidarIndexStart]=min(abs(lidarTimeNum-(timeMax-timeLidar)));

%时间对准,由于table存在应放在数据对准前
%存在小幅差异
app.imuData.timenum=app.imuData.timenum-app.imuData.timenum(imuIndexStart);
if app.indexLidarCSV==1
    %注意全局性,需要标记
    app.timeLidarOpen.lidarTime=lidarTimeNum(lidarIndexStart)+lidarTimeFirst;
    app.timeLidarOpen.actualTime=lidarTimeNum(lidarIndexStart);
end
lidarTimeNum=lidarTimeNum-lidarTimeNum(lidarIndexStart);
lidarTimeNum(1:lidarIndexStart-1,:)=[];


%数据对准
app.imuData(1:imuIndexStart-1,:)=[];
%激光雷达
app.LidarData.AngleHorizontal(1:lidarIndexStart-1,:)=[];
AngleVertical(1:lidarIndexStart-1,:)=[];
app.LidarData.dist(1:lidarIndexStart-1,:)=[];
app.LidarData.reflectivity(1:lidarIndexStart-1,:)=[];


app.LidarData.z=app.LidarData.dist.*sind(AngleVertical);
app.LidarData.y=app.LidarData.dist.*cosd(AngleVertical).*cosd(app.LidarData.AngleHorizontal);
app.LidarData.x=app.LidarData.dist.*cosd(AngleVertical).*sind(app.LidarData.AngleHorizontal);

%分帧
[~,ia,~] = unique(lidarTimeNum);
[pks,locs] = findpeaks(app.LidarData.AngleHorizontal(ia));
app.LidarData.sequence=ia(locs(pks>350))+1;
lidarTimeNum=[0;lidarTimeNum(app.LidarData.sequence)];


[~,ia,~] = unique([app.imuData.lat,app.imuData.lng],'rows','stable');
app.TimeNum.gps=app.imuData.timenum(ia);
app.gpsData.lat=app.imuData.lat(ia);
app.gpsData.lng=app.imuData.lng(ia);
%lat,lng转换
lla=[app.gpsData.lat,app.gpsData.lng,zeros(size(app.gpsData.lat))];p = lla2ecef(lla, 'WGS84');
[app.gpsData.xEast,app.gpsData.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),app.gpsData.lat(1),app.gpsData.lng(1),0,wgs84Ellipsoid);

%可以删掉app.imuData.timenum以及.lat,.lng
app.TimeNum.imu=app.imuData.timenum;
app.TimeNum.lidar=lidarTimeNum;

% %设置GPS图坐标轴范围
% app.GPSRoute.XLim = [min(app.gpsData.xEast) max(app.gpsData.xEast)];
% app.GPSRoute.YLim = [min(app.gpsData.yNorth) max(app.gpsData.yNorth)];

app.indexLidarCSV=app.indexLidarCSV+1;




