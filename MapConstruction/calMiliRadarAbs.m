function data = calMiliRadarAbs(data,index_miliRadar,index_gps,index_imu)
%计算毫米波雷达实际静态坐标
%MiliRadarData顺序 123 分别对应 前右左
% 毫米波雷达体坐标系y轴正向向前，面朝y轴时x轴正向朝右，z轴成右手坐标系

%前向雷达坐标变换阵
c_yaw=cosd(data.imuData.yaw(index_imu));
s_yaw=sind(data.imuData.yaw(index_imu));
c_roll=1;s_roll=0;
c_pitch=1;s_pitch=0;
C_bfr2NE=[1,0,0;0,c_pitch,s_pitch;0,-s_pitch,c_pitch]*...
    [c_roll,0,-s_roll;0,1,0;s_roll,0,c_roll]*...
    [c_yaw,s_yaw,0;-s_yaw,c_yaw,0;0,0,1];

%左向雷达坐标变换阵
c_yaw=cosd(data.imuData.yaw(index_imu)-90);
s_yaw=sind(data.imuData.yaw(index_imu)-90);
c_roll=1;s_roll=0;
c_pitch=1;s_pitch=0;
C_ble2NE=[1,0,0;0,c_pitch,s_pitch;0,-s_pitch,c_pitch]*...
    [c_roll,0,-s_roll;0,1,0;s_roll,0,c_roll]*...
    [c_yaw,s_yaw,0;-s_yaw,c_yaw,0;0,0,1];

%右向雷达坐标变换阵
c_yaw=cosd(data.imuData.yaw(index_imu)+90);
s_yaw=sind(data.imuData.yaw(index_imu)+90);
c_roll=1;s_roll=0;
c_pitch=1;s_pitch=0;
C_bri2NE=[1,0,0;0,c_pitch,s_pitch;0,-s_pitch,c_pitch]*...
    [c_roll,0,-s_roll;0,1,0;s_roll,0,c_roll]*...
    [c_yaw,s_yaw,0;-s_yaw,c_yaw,0;0,0,1];


% %计算前向雷达数据
% %毫米波雷达1
% datacut=data.MiliRadarData1{index_miliRadar};
% if size(datacut,1)~=1 && size(datacut,2)~=1
%     fov=atan2d(datacut(:,1),datacut(:,2));%与y轴(前向轴)夹角
%     dist=vecnorm(datacut(:,1:3),2,2);
%     del=(datacut(:,1)<=-5)|(datacut(:,1)>5)|(fov<-30)|(fov>30)|(datacut(:,3)<=-0.7)|(datacut(:,3)>3)|(dist>20);
%     datacut(del,:)=[];
%     temp_x_abs=zeros(size(datacut(:,1)));
%     temp_y_abs=zeros(size(datacut(:,2)));
%     temp_z_abs=zeros(size(datacut(:,3)));
%     temp_reflectivity_abs=datacut(:,5);
%     for ii=1:size(datacut,1)
%         temp=C_bfr2NE*datacut(ii,1:3).';
%         %temp=C_bfr2NE*[datacut(ii,1);datacut(ii,2);datacut(ii,3)];
%         temp_x_abs(ii)=temp(1);
%         temp_y_abs(ii)=temp(2);
%         temp_z_abs(ii)=temp(3);
%     end
%     temp_x_abs=data.gpsData.xEast(index_gps)+temp_x_abs;
%     temp_y_abs=data.gpsData.yNorth(index_gps)+temp_y_abs;
%     data.MiliRadarDataAbs.x_abs=[data.MiliRadarDataAbs.x_abs;temp_x_abs];
%     data.MiliRadarDataAbs.y_abs=[data.MiliRadarDataAbs.y_abs;temp_y_abs];
%     data.MiliRadarDataAbs.z_abs=[data.MiliRadarDataAbs.z_abs;temp_z_abs];
%     data.MiliRadarDataAbs.reflectivity_abs=[data.MiliRadarDataAbs.reflectivity_abs;temp_reflectivity_abs];
% end
% 
% %计算左向雷达数据
% %毫米波雷达3
% datacut=data.MiliRadarData3{index_miliRadar};
% if size(datacut,1)~=1 && size(datacut,2)~=1
%     fov=atan2d(datacut(:,1),datacut(:,2));%与y轴(前向轴)夹角
%     dist=vecnorm(datacut(:,1:3),2,2);
%     del=(datacut(:,1)<=-5)|(datacut(:,1)>5)|(fov<-30)|(fov>30)|(datacut(:,3)<=-0.7)|(datacut(:,3)>3)|(dist>20);
%     datacut(del,:)=[];
%     temp_x_abs=zeros(size(datacut(:,1)));
%     temp_y_abs=zeros(size(datacut(:,2)));
%     temp_z_abs=zeros(size(datacut(:,3)));
%     temp_reflectivity_abs=datacut(:,5);
%     for ii=1:size(datacut,1)
%         temp=C_ble2NE*datacut(ii,1:3).';
%         temp_x_abs(ii)=temp(1);
%         temp_y_abs(ii)=temp(2);
%         temp_z_abs(ii)=temp(3);
%     end
%     temp_x_abs=data.gpsData.xEast(index_gps)+temp_x_abs;
%     temp_y_abs=data.gpsData.yNorth(index_gps)+temp_y_abs;
%     data.MiliRadarDataAbs.x_abs=[data.MiliRadarDataAbs.x_abs;temp_x_abs];
%     data.MiliRadarDataAbs.y_abs=[data.MiliRadarDataAbs.y_abs;temp_y_abs];
%     data.MiliRadarDataAbs.z_abs=[data.MiliRadarDataAbs.z_abs;temp_z_abs];
%     data.MiliRadarDataAbs.reflectivity_abs=[data.MiliRadarDataAbs.reflectivity_abs;temp_reflectivity_abs];
% end

%计算右向雷达数据
%毫米波雷达2
datacut=data.MiliRadarData2{index_miliRadar};
if size(datacut,1)~=1 && size(datacut,2)~=1
    fov=atan2d(datacut(:,1),datacut(:,2));%与y轴(前向轴)夹角
    dist=vecnorm(datacut(:,1:3),2,2);
    del=(datacut(:,1)<=-5)|(datacut(:,1)>5)|(fov<-30)|(fov>30)|(datacut(:,3)<=-0.7)|(datacut(:,3)>3)|(dist>20);
    datacut(del,:)=[];
    temp_x_abs=zeros(size(datacut(:,1)));
    temp_y_abs=zeros(size(datacut(:,2)));
    temp_z_abs=zeros(size(datacut(:,3)));
    temp_reflectivity_abs=datacut(:,5);
    for ii=1:size(datacut,1)
        temp=C_bri2NE*datacut(ii,1:3).';
        %temp=C_bri2NE*[-datacut(ii,1);datacut(ii,2);-datacut(ii,3)];
        temp_x_abs(ii)=temp(1);
        temp_y_abs(ii)=temp(2);
        temp_z_abs(ii)=temp(3);
    end
    temp_x_abs=data.gpsData.xEast(index_gps)+temp_x_abs;
    temp_y_abs=data.gpsData.yNorth(index_gps)+temp_y_abs;
    data.MiliRadarDataAbs.x_abs=[data.MiliRadarDataAbs.x_abs;temp_x_abs];
    data.MiliRadarDataAbs.y_abs=[data.MiliRadarDataAbs.y_abs;temp_y_abs];
    data.MiliRadarDataAbs.z_abs=[data.MiliRadarDataAbs.z_abs;temp_z_abs];
    data.MiliRadarDataAbs.reflectivity_abs=[data.MiliRadarDataAbs.reflectivity_abs;temp_reflectivity_abs];
end

end

