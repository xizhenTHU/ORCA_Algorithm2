function plotLidar(data,index_lidar,axes)
%Lidar输出
if index_lidar==1
    cut=1:data.LidarData.sequence(1)-1;
else
    cut=data.LidarData.sequence(index_lidar-1):data.LidarData.sequence(index_lidar)-1;
end
% scatter3(axes,data.LidarData.x(cut),data.LidarData.y(cut),data.LidarData.z(cut),...
%     1,data.LidarData.z(cut),'filled');
scatter3(axes,data.LidarData.x(cut),data.LidarData.y(cut),data.LidarData.z(cut),...
    1,data.LidarData.reflectivity(cut),'filled');
xlabel('x(前向) /m');ylabel('y(左向) /m');zlabel('z /m');
axis equal
data.Lidar.View=[-86.768231720139100,10.053691808182107];
%data.Lidar.View=[-76.438711424936140,25.727985229411090];
%data.Lidar.View=[0,90];
pause(1.e-5)
end