clear
selpath='C:\1570894192.500';
selpath='C:\工程文件\ORCA\squr\1570894192.500';

data.indexLidarCSV=1;
%%加载并处理imu数据
[timeIMU,data] = loadIMUData(selpath,data);
disp('imu数据加载完毕!');

%%加载并处理毫米波雷达
[timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data);
disp('毫米波雷达数据加载完毕!');

%%加载并处理激光雷达
data.lidarDirCSV=dir([selpath,'\*.csv']);
[~,ind]=sort([data.lidarDirCSV(:).datenum]);
data.lidarDirCSV=data.lidarDirCSV(ind);
filename = [data.lidarDirCSV(1).folder,'\',data.lidarDirCSV(1).name];
[data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
lidarTimeFirst=lidarTimeNum(1);
lidarTimeNum=lidarTimeNum-lidarTimeNum(1);
disp('激光雷达数据加载完毕!');
%激光雷达时间戳
dirTemp = dir([selpath,'\Laser*']);
timeLidar = str2double(strtrim(erase(dirTemp.name,'Laser_')));%激光雷达时间戳,单位秒

%时间戳初始对准
[timeMax,~]=max([timeIMU,timeLidar]);
[imuIndexStartMin,imuIndexStart]=min(abs(data.imuData.timenum-(timeMax-timeIMU)));
[lidarIndexStartMin,lidarIndexStart]=min(abs(lidarTimeNum-(timeMax-timeLidar)));

%时间对准,由于table存在应放在数据对准前
%存在小幅差异
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(imuIndexStart);
if data.indexLidarCSV==1
    %注意全局性,需要标记
    data.timeLidarOpen.lidarTime=lidarTimeNum(lidarIndexStart)+lidarTimeFirst;
    data.timeLidarOpen.actualTime=lidarTimeNum(lidarIndexStart);
end
lidarTimeNum=lidarTimeNum-lidarTimeNum(lidarIndexStart);
lidarTimeNum(1:lidarIndexStart-1,:)=[];


%数据对准
data.imuData(1:imuIndexStart-1,:)=[];
%激光雷达
data.LidarData.AngleHorizontal(1:lidarIndexStart-1,:)=[];
AngleVertical(1:lidarIndexStart-1,:)=[];
data.LidarData.dist(1:lidarIndexStart-1,:)=[];
data.LidarData.reflectivity(1:lidarIndexStart-1,:)=[];


data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
data.LidarData.y=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);

%分帧
[~,ia,~] = unique(lidarTimeNum);
[pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
data.LidarData.sequence=ia(locs(pks>350))+1;
lidarTimeNum=[0;lidarTimeNum(data.LidarData.sequence)];


[~,ia,~] = unique([data.imuData.lat,data.imuData.lng],'rows','stable');
data.TimeNum.gps=data.imuData.timenum(ia);
data.gpsData.lat=data.imuData.lat(ia);
data.gpsData.lng=data.imuData.lng(ia);
%lat,lng转换
lla=[data.gpsData.lat,data.gpsData.lng,zeros(size(data.gpsData.lat))];p = lla2ecef(lla, 'WGS84');
[data.gpsData.xEast,data.gpsData.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.gpsData.lat(1),data.gpsData.lng(1),0,wgs84Ellipsoid);

%可以删掉data.imuData.timenum以及.lat,.lng
data.TimeNum.imu=data.imuData.timenum;
data.TimeNum.lidar=lidarTimeNum;

data.indexLidarCSV=data.indexLidarCSV+1;




