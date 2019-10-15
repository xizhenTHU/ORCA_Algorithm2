%GUI����
%2019.10.5�޸� ����imu����
clear;close all
% selpath='E:\data\1570095400.100';
% selpath='E:\data\1570095953.400';
% selpath='E:\data\1570097017.600';
% selpath='E:\data\1570097138.600';
% selpath='E:\data\1570097192.000';
% selpath='E:\data\1570097234.399';
% selpath='E:\data\1570097660.200';
selpath='C:\�����ļ�\ORCA\data1004\1570095400.100';
% selpath='C:\�����ļ�\ORCA\data1004\1570095953.400';

selpath='C:\�����ļ�\ORCA\data\1570852380.000';
selpath='F:\����\squr\1570894192.500';


data.indexLidarCSV=1;
%%���ز�����realsense����
[timeRealSense,realsenseTimeNum,data] = loadRealSenseData(selpath,data);
disp('realsense���ݼ������!');

%%���ز�����imu����
[timeIMU,data] = loadIMUData(selpath,data);
disp('imu���ݼ������!');

%%���ز��������ײ��״�
[timeMiliRadar,miliRadarTimeNum,data] = loadMiliRadarData(selpath,data);
disp('���ײ��״����ݼ������!');

%%���ز����������״�
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
[timeMax,~]=max([timeMiliRadar,timeRealSense,timeIMU,timeLidar]);
[miliRadarMin,miliRadarIndexStart]=min(abs(miliRadarTimeNum-(timeMax-timeMiliRadar)));
[realsenseMin,realsenseIndexStart]=min(abs(realsenseTimeNum-(timeMax-timeRealSense)));
[imuIndexStartMin,imuIndexStart]=min(abs(data.imuData.timenum-(timeMax-timeIMU)));
[lidarIndexStartMin,lidarIndexStart]=min(abs(lidarTimeNum-(timeMax-timeLidar)));

%ʱ���׼,����table����Ӧ�������ݶ�׼ǰ
%����С������
miliRadarTimeNum=miliRadarTimeNum-miliRadarTimeNum(miliRadarIndexStart);
miliRadarTimeNum(1:miliRadarIndexStart-1,:)=[];
realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(realsenseIndexStart);
realsenseTimeNum(1:realsenseIndexStart-1,:)=[];
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(imuIndexStart);
if data.indexLidarCSV==1
    %ע��ȫ����,��Ҫ���
    data.timeLidarOpen.lidarTime=lidarTimeNum(lidarIndexStart)+lidarTimeFirst;
    data.timeLidarOpen.actualTime=lidarTimeNum(lidarIndexStart);
end
lidarTimeNum=lidarTimeNum-lidarTimeNum(lidarIndexStart);
lidarTimeNum(1:lidarIndexStart-1,:)=[];




%���ݶ�׼
data.MiliRadarData1(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData2(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData3(1:miliRadarIndexStart-1,:)=[];
data.dirRGB(1:realsenseIndexStart-1,:)=[];
data.dirDeepth(1:realsenseIndexStart-1,:)=[];
data.imuData(1:imuIndexStart-1,:)=[];
%�����״����ݶ�׼
data.LidarData.AngleHorizontal(1:lidarIndexStart-1,:)=[];
AngleVertical(1:lidarIndexStart-1,:)=[];
data.LidarData.dist(1:lidarIndexStart-1,:)=[];
data.LidarData.reflectivity(1:lidarIndexStart-1,:)=[];


data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
data.LidarData.y=-data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);

%����Ԥ����
data.LidarData.x_abs=[];
data.LidarData.y_abs=[];
data.LidarData.z_abs=[];
data.LidarData.reflectivity_abs=[];
data.MiliRadarDataAbs.x_abs=[];
data.MiliRadarDataAbs.y_abs=[];
data.MiliRadarDataAbs.z_abs=[];
data.MiliRadarDataAbs.reflectivity_abs=[];


%�����״����ݷ�֡
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
%�������
data.gpsData.dist=zeros(size(data.gpsData.xEast));
for ii=2:length(data.gpsData.xEast)
    data.gpsData.dist(ii)=norm([data.gpsData.xEast(ii-1)-data.gpsData.xEast(ii),...
        data.gpsData.yNorth(ii-1)-data.gpsData.yNorth(ii)]);
end
%����ɾ��data.imuData.timenum�Լ�.lat,.lng
data.TimeNum.miliRadar=miliRadarTimeNum;
data.TimeNum.realsense=realsenseTimeNum;
data.TimeNum.imu=data.imuData.timenum;
data.TimeNum.lidar=lidarTimeNum;
clear miliRadarTimeNum realsenseTimeNum

data.indexLidarCSV=data.indexLidarCSV+1;

% aheadSec=56.5;%����������
% stopSec=170-50;%��ֹ����
aheadSec=0;%����������
stopSec=30;%��ֹ����

%����yaw������
temp=diff(data.imuData.gpsYaw);
temp=find(temp~=0,1)+1;%��ʼgpsyaw��׼index
yawCompensate=mean(data.imuData.gpsYaw(temp:temp+9))-mean(data.imuData.yaw(temp:temp+9));
% yawCompensate=170;


[~,index_miliRadar]=min(abs(data.TimeNum.miliRadar-aheadSec));
[~,index_imu_start]=min(abs(data.TimeNum.imu-aheadSec));
[~,index_realsense]=min(abs(data.TimeNum.realsense-aheadSec));
[~,index_gps]=min(abs(data.TimeNum.gps-aheadSec));
if aheadSec<=data.TimeNum.lidar(end)
    [~,index_lidar]=min(abs(data.TimeNum.lidar-aheadSec));
else
    %С��33���Ƚ��Ƚ�,Ҳ���ǳ�ǰ330s��
    data.indexLidarCSV=floor((aheadSec+data.timeLidarOpen.actualTime)/10)+1;
    filename = [data.lidarDirCSV(data.indexLidarCSV).folder,'\',data.lidarDirCSV(data.indexLidarCSV).name];
    [data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
    lidarTimeNum=lidarTimeNum-data.timeLidarOpen.lidarTime;
    [~,ia,~] = unique(lidarTimeNum);
    %�����״����ݷ�֡
    [pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
    data.LidarData.sequence=ia(locs(pks>350))+1;
    lidarTimeNum=[lidarTimeNum(1);lidarTimeNum(data.LidarData.sequence)];
    data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
    data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
    data.LidarData.y=-data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);
    
    data.TimeNum.lidar=lidarTimeNum;
    [~,index_lidar]=min(abs(data.TimeNum.lidar-aheadSec));
    data.indexLidarCSV=data.indexLidarCSV+1;
end

temp_dist=0;
figure_realsense = figure('NumberTitle', 'off', 'Name', 'realsenseʵʱͼ��');
axes_realsense = axes('Parent',figure_realsense);
figure_lidar = figure('NumberTitle', 'off', 'Name', '�����״�ʵʱͼ��');
axes_lidar = axes('Parent',figure_lidar);
figure_mili = figure('NumberTitle', 'off', 'Name', '���ײ��״�ʵʱͼ��');
axes_mili_front = axes('Parent',figure_mili,'Position',[0.322 0.595 0.3 0.3]);title('ǰ��');
axes_mili_left = axes('Parent',figure_mili,'Position',[0.104 0.198 0.3 0.3]);title('����');
axes_mili_right = axes('Parent',figure_mili,'Position',[0.5625 0.195 0.3 0.3]);title('����');

for index_imu=index_imu_start:length(data.TimeNum.imu)
    if data.TimeNum.imu(index_imu)>=stopSec
        disp('����');
        break
    end
    %����Lidar����
    if index_lidar==length(data.LidarData.sequence)+1 && data.TimeNum.lidar(index_lidar)<=data.TimeNum.imu(index_imu)
        disp('���ؼ����״�����...');
        filename = [data.lidarDirCSV(data.indexLidarCSV).folder,'\',data.lidarDirCSV(data.indexLidarCSV).name];
        [data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
        lidarTimeNum=lidarTimeNum-data.timeLidarOpen.lidarTime;
        [~,ia,~] = unique(lidarTimeNum);
        %��֡
        [pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
        data.LidarData.sequence=ia(locs(pks>350))+1;
        lidarTimeNum=[lidarTimeNum(1);lidarTimeNum(data.LidarData.sequence)];
        data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
        data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
        data.LidarData.y=-data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);
        index_lidar=1;
        data.TimeNum.lidar=lidarTimeNum;
        data.indexLidarCSV=data.indexLidarCSV+1;
    end
    
    
    str=['*imu:',num2str(data.TimeNum.imu(index_imu)),...
        ' Real:',num2str(data.TimeNum.realsense(index_realsense)),...
        ' Mili:',num2str(data.TimeNum.miliRadar(index_miliRadar)),...
        ' Lidar:',num2str(data.TimeNum.lidar(index_lidar))];
    disp(str);
    
    %Yaw���
    %���ݵ��ø�ʽ:data.imuData.yaw,data.imuData.pitch,data.imuData.roll
    %plotTansformCuber(data,data.imuData.yaw(index_imu),data.imuData.pitch(index_imu),data.imuData.roll(index_imu))
    
    %GPS�켣
    %���ݵ��ø�ʽ:data.gpsData.lat,data.gpsData.lng ���� data.gpsData.xEast,data.gpsData.yNorth
    if data.TimeNum.gps(index_gps)<=data.TimeNum.imu(index_imu)
        temp_dist=temp_dist+data.gpsData.dist(index_gps);
        %plot(data.GPSRoute,data.gpsData.xEast(index_gps),data.gpsData.yNorth(index_gps),'.b');
        pause(1.e-5)
        index_gps=index_gps+1;
    end
    %RealSense���
    if data.TimeNum.realsense(index_realsense)<=data.TimeNum.imu(index_imu)
        %plotRealSense(data,index_realsense,axes_realsense);
        index_realsense=index_realsense+1;
    end
    %���ײ����
    %���ݴ�Ϊcell
    %���ݵ��ø�ʽ:data.MiliRadarData1,data.MiliRadarData2,data.MiliRadarData3
    %˳�� 123 �ֱ��Ӧ ��ǰ��
    if data.TimeNum.miliRadar(index_miliRadar)<=data.TimeNum.imu(index_imu)
        %plotMiliRadar(data,index_miliRadar,axes_mili_front,axes_mili_left,axes_mili_right);
        index_miliRadar=index_miliRadar+1;
    end
    %�����״����
    if data.TimeNum.lidar(index_lidar)<=data.TimeNum.imu(index_imu)
        %plotLidar(data,index_lidar,axes_lidar);
        index_lidar=index_lidar+1;
    end
    
    if temp_dist>=2
        data=calLidarAbs(data,index_lidar,index_gps,index_imu,yawCompensate);
        data = calMiliRadarAbs(data,index_miliRadar,index_gps,index_imu,yawCompensate);
        temp_dist=0;
    end
    pause(1.e-5)
    
end


% figure;scatter3(data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,...
%     1,data.LidarData.z_abs,'filled');axis equal
figure;scatter3(data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,...
    1,data.LidarData.reflectivity_abs,'filled');caxis([min(data.LidarData.reflectivity_abs),120])
xlabel('�� /m');ylabel('�� /m');zlabel('z /m');axis equal

figure;scatter3(data.MiliRadarDataAbs.x_abs,data.MiliRadarDataAbs.y_abs,data.MiliRadarDataAbs.z_abs,...
    5,data.MiliRadarDataAbs.reflectivity_abs,'filled');
xlabel('�� /m');ylabel('�� /m');zlabel('z /m');axis equal

figure;scatter3(data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,...
    1,data.LidarData.reflectivity_abs,'filled');caxis([min(data.LidarData.reflectivity_abs),120])
hold on;scatter3(data.MiliRadarDataAbs.x_abs,data.MiliRadarDataAbs.y_abs,data.MiliRadarDataAbs.z_abs,...
    5,'k','filled');xlabel('�� /m');ylabel('�� /m');zlabel('z /m');axis equal


figure;plot(data.gpsData.xEast,data.gpsData.yNorth);xlabel('�� /m');ylabel('�� /m');axis equal

% figure;plot(data.TimeNum.imu,data.imuData.mode);
% figure;histogram(data.MiliRadarDataAbs.reflectivity_abs,'Normalization','cdf')

figure;plot(data.TimeNum.imu,[data.imuData.yaw,data.imuData.roll,data.imuData.pitch,data.imuData.gpsYaw]);
legend('yaw','roll','pitch','gpsYaw')

% csvwrite('LidarAnalysisData.csv',[data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,data.LidarData.reflectivity_abs])