clear
selpath='C:\1570894192.500';
selpath='C:\�����ļ�\ORCA\squr\1570894192.500';

data.indexLidarCSV=1;
%%���ز�����imu����
[timeIMU,data] = loadIMUData(selpath,data);
disp('imu���ݼ������!');

%%���ز�������ײ��״�
[timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data);
disp('���ײ��״����ݼ������!');

%%���ز��������״�
data.lidarDirCSV=dir([selpath,'\*.csv']);
[~,ind]=sort([data.lidarDirCSV(:).datenum]);
data.lidarDirCSV=data.lidarDirCSV(ind);
filename = [data.lidarDirCSV(1).folder,'\',data.lidarDirCSV(1).name];
[data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
lidarTimeFirst=lidarTimeNum(1);
lidarTimeNum=lidarTimeNum-lidarTimeNum(1);
disp('�����״����ݼ������!');
%�����״�ʱ���
dirTemp = dir([selpath,'\Laser*']);
timeLidar = str2double(strtrim(erase(dirTemp.name,'Laser_')));%�����״�ʱ���,��λ��

%ʱ�����ʼ��׼
[timeMax,~]=max([timeIMU,timeLidar]);
[imuIndexStartMin,imuIndexStart]=min(abs(data.imuData.timenum-(timeMax-timeIMU)));
[lidarIndexStartMin,lidarIndexStart]=min(abs(lidarTimeNum-(timeMax-timeLidar)));

%ʱ���׼,����table����Ӧ�������ݶ�׼ǰ
%����С������
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(imuIndexStart);
if data.indexLidarCSV==1
    %ע��ȫ����,��Ҫ���
    data.timeLidarOpen.lidarTime=lidarTimeNum(lidarIndexStart)+lidarTimeFirst;
    data.timeLidarOpen.actualTime=lidarTimeNum(lidarIndexStart);
end
lidarTimeNum=lidarTimeNum-lidarTimeNum(lidarIndexStart);
lidarTimeNum(1:lidarIndexStart-1,:)=[];


%���ݶ�׼
data.imuData(1:imuIndexStart-1,:)=[];
%�����״�
data.LidarData.AngleHorizontal(1:lidarIndexStart-1,:)=[];
AngleVertical(1:lidarIndexStart-1,:)=[];
data.LidarData.dist(1:lidarIndexStart-1,:)=[];
data.LidarData.reflectivity(1:lidarIndexStart-1,:)=[];


data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
data.LidarData.y=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);

%��֡
[~,ia,~] = unique(lidarTimeNum);
[pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
data.LidarData.sequence=ia(locs(pks>350))+1;
lidarTimeNum=[0;lidarTimeNum(data.LidarData.sequence)];


[~,ia,~] = unique([data.imuData.lat,data.imuData.lng],'rows','stable');
data.TimeNum.gps=data.imuData.timenum(ia);
data.gpsData.lat=data.imuData.lat(ia);
data.gpsData.lng=data.imuData.lng(ia);
%lat,lngת��
lla=[data.gpsData.lat,data.gpsData.lng,zeros(size(data.gpsData.lat))];p = lla2ecef(lla, 'WGS84');
[data.gpsData.xEast,data.gpsData.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.gpsData.lat(1),data.gpsData.lng(1),0,wgs84Ellipsoid);

%����ɾ��data.imuData.timenum�Լ�.lat,.lng
data.TimeNum.imu=data.imuData.timenum;
data.TimeNum.lidar=lidarTimeNum;

data.indexLidarCSV=data.indexLidarCSV+1;




