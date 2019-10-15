clear all;close all
selpath='C:\工程文件\ORCA\squr\1570894192.500';
data.indexLidarCSV=1;
[timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data);
[timeIMU,data] = loadIMUData(selpath,data);
[~,ia,~] = unique([data.imuData.lat,data.imuData.lng],'rows','stable');
data.TimeNum.gps=data.imuData.timenum(ia);
data.gpsData.lat=data.imuData.lat(ia);
data.gpsData.lng=data.imuData.lng(ia);
%lat,lng转换
lla=[data.gpsData.lat,data.gpsData.lng,zeros(size(data.gpsData.lat))];p = lla2ecef(lla, 'WGS84');
[data.gpsData.xEast,data.gpsData.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.gpsData.lat(1),data.gpsData.lng(1),0,wgs84Ellipsoid);
Showoneframedata(data.MiliRadarData3',data,miliRadarTimeNum);