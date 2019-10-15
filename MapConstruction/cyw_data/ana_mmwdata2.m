clear all;close all
selpath='C:\工程文件\ORCA\squr\1570894192.500';
data.indexLidarCSV=1;
[timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data);
[timeIMU,data] = loadIMUData(selpath,data);

%时间戳初始对准
[timeMax,~]=max([timeMiliRadar,timeIMU]);
[miliRadarMin,miliRadarIndexStart]=min(abs(miliRadarTimeNum-(timeMax-timeMiliRadar)));
[imuIndexStartMin,imuIndexStart]=min(abs(data.imuData.timenum-(timeMax-timeIMU)));

%时间对准,由于table存在应放在数据对准前
%存在小幅差异
miliRadarTimeNum=miliRadarTimeNum-miliRadarTimeNum(miliRadarIndexStart);
miliRadarTimeNum(1:miliRadarIndexStart-1,:)=[];
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(imuIndexStart);

%数据对准
data.MiliRadarData1(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData2(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData3(1:miliRadarIndexStart-1,:)=[];
data.imuData(1:imuIndexStart-1,:)=[];
data.TimeNum.miliRadar=miliRadarTimeNum;
data.TimeNum.imu=data.imuData.timenum;

[~,ia,~] = unique([data.imuData.lat,data.imuData.lng],'rows','stable');
data.TimeNum.gps=data.imuData.timenum(ia);
data.gpsData.lat=data.imuData.lat(ia);
data.gpsData.lng=data.imuData.lng(ia);
%lat,lng转换
lla=[data.gpsData.lat,data.gpsData.lng,zeros(size(data.gpsData.lat))];p = lla2ecef(lla, 'WGS84');
[data.gpsData.xEast,data.gpsData.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.gpsData.lat(1),data.gpsData.lng(1),0,wgs84Ellipsoid);
Showoneframedata(data.MiliRadarData1',data,miliRadarTimeNum);