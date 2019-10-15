%GUI改制
%2019.10.5修改 与新imu搭配
clear;close all
% selpath='E:\data\1570095400.100';
% selpath='E:\data\1570095953.400';
% selpath='E:\data\1570097017.600';
% selpath='E:\data\1570097138.600';
% selpath='E:\data\1570097192.000';
% selpath='E:\data\1570097234.399';
selpath='E:\data\1570097660.200';


data.indexLidarCSV=1;
%%加载并处理realsense数据
data.dirRGB = dir([selpath,'\realsense*\rgb\*.jpg']);
data.dirDeepth = dir([selpath,'\realsense*\depth\*.jpg']);

%读取realsense时间戳
dirTemp = dir([selpath,'\realsense*']);
timeRealSense = str2double(strtrim(erase(dirTemp.name,'realsense_')));%realsense启动时间
dirTemp = dir([selpath,'\',dirTemp.name,'\imu.csv']);
filename = [dirTemp.folder,'\',dirTemp.name];
delimiter = ',';
formatSpec = '%f%*s%*s%*s%*s%*s%*s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
realsenseTimeNum = [dataArray{1:end-1}];
clearvars filename delimiter formatSpec fileID dataArray ans;
realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(1);%realsense时间戳,单位秒
disp('realsense数据加载完毕!');

%%加载并处理imu数据
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
disp('imu数据加载完毕!');

%%加载并处理毫米波雷达
dirMiliRadar = dir([selpath,'\radar*\*data*.txt']);
data.MiliRadarData1=readData1843([dirMiliRadar(1).folder,'\',dirMiliRadar(1).name]).';
data.MiliRadarData2=readData1843([dirMiliRadar(2).folder,'\',dirMiliRadar(2).name]).';
data.MiliRadarData3=readData1843([dirMiliRadar(3).folder,'\',dirMiliRadar(3).name]).';

%读取毫米波雷达时间戳
dirTemp = dir([selpath,'\radar*']);
timeMiliRadar = str2double(strtrim(erase(dirTemp.name,'radar_')));%毫米波雷达启动时间
dirTemp = dir([selpath,'\',dirTemp.name,'\radar1_time*.txt']);
filename = [dirTemp.folder,'\',dirTemp.name];
delimiter = ' ';
formatSpec = '%*s%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
fclose(fileID);
miliRadarTimeNum = dataArray{:, 1};
clearvars filename delimiter formatSpec fileID dataArray ans;
miliRadarTimeNum=(miliRadarTimeNum-miliRadarTimeNum(1))/1.e3;%毫米波雷达时间戳,单位秒
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
[timeMax,~]=max([timeMiliRadar,timeRealSense,timeIMU,timeLidar]);
[miliRadarMin,miliRadarIndexStart]=min(abs(miliRadarTimeNum-(timeMax-timeMiliRadar)));
[realsenseMin,realsenseIndexStart]=min(abs(realsenseTimeNum-(timeMax-timeRealSense)));
[imuIndexStartMin,imuIndexStart]=min(abs(data.imuData.timenum-(timeMax-timeIMU)));
[lidarIndexStartMin,lidarIndexStart]=min(abs(lidarTimeNum-(timeMax-timeLidar)));

%时间对准,由于table存在应放在数据对准前
%存在小幅差异
miliRadarTimeNum=miliRadarTimeNum-miliRadarTimeNum(miliRadarIndexStart);
miliRadarTimeNum(1:miliRadarIndexStart-1,:)=[];
realsenseTimeNum=realsenseTimeNum-realsenseTimeNum(realsenseIndexStart);
realsenseTimeNum(1:realsenseIndexStart-1,:)=[];
data.imuData.timenum=data.imuData.timenum-data.imuData.timenum(imuIndexStart);
if data.indexLidarCSV==1
    %注意全局性,需要标记
    data.timeLidarOpen.lidarTime=lidarTimeNum(lidarIndexStart)+lidarTimeFirst;
    data.timeLidarOpen.actualTime=lidarTimeNum(lidarIndexStart);
end
lidarTimeNum=lidarTimeNum-lidarTimeNum(lidarIndexStart);
lidarTimeNum(1:lidarIndexStart-1,:)=[];




%数据对准
data.MiliRadarData1(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData2(1:miliRadarIndexStart-1,:)=[];
data.MiliRadarData3(1:miliRadarIndexStart-1,:)=[];
data.dirRGB(1:realsenseIndexStart-1,:)=[];
data.dirDeepth(1:realsenseIndexStart-1,:)=[];
data.imuData(1:imuIndexStart-1,:)=[];
%激光雷达
data.LidarData.AngleHorizontal(1:lidarIndexStart-1,:)=[];
AngleVertical(1:lidarIndexStart-1,:)=[];
data.LidarData.dist(1:lidarIndexStart-1,:)=[];
data.LidarData.reflectivity(1:lidarIndexStart-1,:)=[];


data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
data.LidarData.y=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);
% data.LidarData.x_abs=zeros(size(data.LidarData.x));
% data.LidarData.y_abs=zeros(size(data.LidarData.y));
% data.LidarData.z_abs=zeros(size(data.LidarData.z));
data.LidarData.x_abs=[];
data.LidarData.y_abs=[];
data.LidarData.z_abs=[];
data.LidarData.reflectivity_abs=[];

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
%两点距离
data.gpsData.dist=zeros(size(data.gpsData.xEast));
for ii=2:length(data.gpsData.xEast)
    data.gpsData.dist(ii)=norm([data.gpsData.xEast(ii-1)-data.gpsData.xEast(ii),...
        data.gpsData.yNorth(ii-1)-data.gpsData.yNorth(ii)]);
end
%可以删掉data.imuData.timenum以及.lat,.lng
data.TimeNum.miliRadar=miliRadarTimeNum;
data.TimeNum.realsense=realsenseTimeNum;
data.TimeNum.imu=data.imuData.timenum;
data.TimeNum.lidar=lidarTimeNum;

data.indexLidarCSV=data.indexLidarCSV+1;

% aheadSec=56.5;%跳过的秒数
% stopSec=170-50;%中止秒数
aheadSec=0;%跳过的秒数
stopSec=50;%中止秒数

[~,index_miliRadar]=min(abs(data.TimeNum.miliRadar-aheadSec));
[~,index_imu_start]=min(abs(data.TimeNum.imu-aheadSec));
[~,index_realsense]=min(abs(data.TimeNum.realsense-aheadSec));
[~,index_gps]=min(abs(data.TimeNum.gps-aheadSec));
if aheadSec<=data.TimeNum.lidar(end)
    [~,index_lidar]=min(abs(data.TimeNum.lidar-aheadSec));
else
    %小于33包比较稳健,也就是超前330s内
    data.indexLidarCSV=floor((aheadSec+data.timeLidarOpen.actualTime)/10)+1;
    filename = [data.lidarDirCSV(data.indexLidarCSV).folder,'\',data.lidarDirCSV(data.indexLidarCSV).name];
    [data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
    lidarTimeNum=lidarTimeNum-data.timeLidarOpen.lidarTime;
    [~,ia,~] = unique(lidarTimeNum);
    %分帧
    [pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
    data.LidarData.sequence=ia(locs(pks>350))+1;
    lidarTimeNum=[lidarTimeNum(1);lidarTimeNum(data.LidarData.sequence)];
    data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
    data.LidarData.y=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
    data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);
%     data.LidarData.x_abs=zeros(size(data.LidarData.x));
%     data.LidarData.y_abs=zeros(size(data.LidarData.y));
%     data.LidarData.z_abs=zeros(size(data.LidarData.z));

    data.TimeNum.lidar=lidarTimeNum;
    [~,index_lidar]=min(abs(data.TimeNum.lidar-aheadSec));
    data.indexLidarCSV=data.indexLidarCSV+1;
end

temp_dist=0;
figure_realsense = figure;
axes_realsense = axes('Parent',figure_realsense);
figure_lidar = figure;
axes_lidar = axes('Parent',figure_lidar);

for index_imu=index_imu_start:length(data.TimeNum.imu)
    if data.TimeNum.imu(index_imu)>=stopSec
        disp('结束');
        break
    end
    %加载Lidar数据
    if index_lidar==length(data.LidarData.sequence)+1 && data.TimeNum.lidar(index_lidar)<=data.TimeNum.imu(index_imu)
        disp('加载激光雷达数据...');
        filename = [data.lidarDirCSV(data.indexLidarCSV).folder,'\',data.lidarDirCSV(data.indexLidarCSV).name];
        [data.LidarData.AngleHorizontal,AngleVertical,data.LidarData.dist,lidarTimeNum,data.LidarData.reflectivity]=readLidarCSV(data,filename);
        lidarTimeNum=lidarTimeNum-data.timeLidarOpen.lidarTime;
        [~,ia,~] = unique(lidarTimeNum);
        %分帧
        [pks,locs] = findpeaks(data.LidarData.AngleHorizontal(ia));
        data.LidarData.sequence=ia(locs(pks>350))+1;
        lidarTimeNum=[lidarTimeNum(1);lidarTimeNum(data.LidarData.sequence)];
        data.LidarData.z=data.LidarData.dist.*sind(AngleVertical);
        data.LidarData.y=data.LidarData.dist.*cosd(AngleVertical).*cosd(data.LidarData.AngleHorizontal);
        data.LidarData.x=data.LidarData.dist.*cosd(AngleVertical).*sind(data.LidarData.AngleHorizontal);
%         data.LidarData.x_abs=zeros(size(data.LidarData.x));
%         data.LidarData.y_abs=zeros(size(data.LidarData.y));
%         data.LidarData.z_abs=zeros(size(data.LidarData.z));
        index_lidar=1;
        data.TimeNum.lidar=lidarTimeNum;
        data.indexLidarCSV=data.indexLidarCSV+1;
    end
    
    
    str=['*imu:',num2str(data.TimeNum.imu(index_imu)),...
        ' Real:',num2str(data.TimeNum.realsense(index_realsense)),...
        ' Mili:',num2str(data.TimeNum.miliRadar(index_miliRadar)),...
        ' Lidar:',num2str(data.TimeNum.lidar(index_lidar))];
    disp(str);

    %Yaw输出
    %数据调用格式:data.imuData.yaw,data.imuData.pitch,data.imuData.roll
    %plotTansformCuber(data,data.imuData.yaw(index_imu),data.imuData.pitch(index_imu),data.imuData.roll(index_imu))
    
    %GPS轨迹
    %数据调用格式:data.gpsData.lat,data.gpsData.lng 或者 data.gpsData.xEast,data.gpsData.yNorth
    if data.TimeNum.gps(index_gps)<=data.TimeNum.imu(index_imu)
        temp_dist=temp_dist+data.gpsData.dist(index_gps);
        %plot(data.GPSRoute,data.gpsData.xEast(index_gps),data.gpsData.yNorth(index_gps),'.b');
        pause(1.e-5)
        index_gps=index_gps+1;
    end
    %RealSense输出
    if data.TimeNum.realsense(index_realsense)<=data.TimeNum.imu(index_imu)
        %plotRealSense(data,index_realsense,axes_realsense);
        index_realsense=index_realsense+1;
    end
    %毫米波输出
    %数据存为cell
    %数据调用格式:data.MiliRadarData1,data.MiliRadarData2,data.MiliRadarData3
    %顺序 123 分别对应 右前左
    if data.TimeNum.miliRadar(index_miliRadar)<=data.TimeNum.imu(index_imu)
        %plotMiliRadar(data,index_miliRadar);
        index_miliRadar=index_miliRadar+1;
    end
    %激光雷达输出
    if data.TimeNum.lidar(index_lidar)<=data.TimeNum.imu(index_imu)
        if temp_dist>=2
            data=calLidarAbs(data,index_lidar,index_gps,index_imu);
            temp_dist=0;
        end
        %plotLidar(data,index_lidar,axes_lidar);
        index_lidar=index_lidar+1;
    end
    pause(1.e-5)
    
end


% figure;scatter3(data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,...
%     1,data.LidarData.z_abs,'filled');
figure;scatter3(data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,...
    1,data.LidarData.reflectivity_abs,'filled');caxis([min(data.LidarData.reflectivity_abs),120])
xlabel('东 /m');ylabel('北 /m');zlabel('z /m');axis equal

figure;plot(data.gpsData.xEast,data.gpsData.yNorth);xlabel('东 /m');ylabel('北 /m');axis equal

figure;plot(data.TimeNum.imu,data.imuData.mode);

figure;plot(data.TimeNum.imu,[data.imuData.yaw,data.imuData.roll,data.imuData.pitch,data.imuData.gpsYaw]);
legend('yaw','roll','pitch','gpsYaw')

% csvwrite('LidarAnalysisData.csv',[data.LidarData.x_abs,data.LidarData.y_abs,data.LidarData.z_abs,data.LidarData.reflectivity_abs])
