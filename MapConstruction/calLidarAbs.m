function data = calLidarAbs(data,index_lidar,index_gps,index_imu)
%计算激光雷达实际静态坐标
%Lidar输出
if index_lidar==1
    cut=1:data.LidarData.sequence(1)-1;
else
    cut=data.LidarData.sequence(index_lidar-1):data.LidarData.sequence(index_lidar)-1;
end
c_yaw=cosd(data.imuData.yaw(index_imu));
s_yaw=sind(data.imuData.yaw(index_imu));

% c_roll=cosd(data.imuData.roll(index_imu));
% s_roll=sind(data.imuData.roll(index_imu));
% c_pitch=cosd(data.imuData.pitch(index_imu));
% s_pitch=sind(data.imuData.pitch(index_imu));

c_roll=1;
s_roll=0;
c_pitch=1;
s_pitch=0;
C_b2NE=[1,0,0;0,c_pitch,s_pitch;0,-s_pitch,c_pitch]*...
    [c_roll,0,-s_roll;0,1,0;s_roll,0,c_roll]*...
    [c_yaw,s_yaw,0;-s_yaw,c_yaw,0;0,0,1];
temp_x_abs=zeros(size(data.LidarData.x(cut)));
temp_y_abs=zeros(size(data.LidarData.y(cut)));
temp_z_abs=zeros(size(data.LidarData.z(cut)));
temp_reflectivity_abs=data.LidarData.reflectivity(cut);
for ii=1:length(cut)
    temp=C_b2NE*[data.LidarData.x(cut(ii));data.LidarData.y(cut(ii));data.LidarData.z(cut(ii))];
    temp_x_abs(ii)=temp(1);
    temp_y_abs(ii)=temp(2);
    temp_z_abs(ii)=temp(3);
end
% dist=vecnorm([temp_x_abs,temp_y_abs,temp_z_abs],2,2);
temp_x_abs=data.gpsData.xEast(index_gps)+temp_x_abs;
temp_y_abs=data.gpsData.yNorth(index_gps)+temp_y_abs;

del=((temp_x_abs==0)&(temp_y_abs==0))|(temp_z_abs<-0.5);%|(dist<0.7);%&(data.LidarData.y_abs==0)
% del=[];
temp_x_abs(del)=[];
temp_y_abs(del)=[];
temp_z_abs(del)=[];
temp_reflectivity_abs(del)=[];
data.LidarData.x_abs=[data.LidarData.x_abs;temp_x_abs];
data.LidarData.y_abs=[data.LidarData.y_abs;temp_y_abs];
data.LidarData.z_abs=[data.LidarData.z_abs;temp_z_abs];
data.LidarData.reflectivity_abs=[data.LidarData.reflectivity_abs;temp_reflectivity_abs];

end

