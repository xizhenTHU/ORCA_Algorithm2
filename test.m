clear
% temp=-5 + (5+5)*rand(32000,3);
% temp=temp/20;
% color=zeros(length(temp),1);
% for ii=1:length(temp)
%    color(ii)=norm(temp(ii,:));
% end
% figure;scatter3(temp(:,1),temp(:,2),temp(:,3),1,color);
% caxis([-.5 .5]);% colormap winter;
% MiliRadarData=readData1843('C:\Users\WPD\Documents\WeChat Files\eryuzhen\FileStorage\File\2019-07\data_person1.txt');
MiliRadarData=readData1843('C:\工程文件\ORCA\代码\2_Algorithm2\Data\1564739132.995\radar_1564739137.670146\radar1_data_2019_08_02_17_45_37.txt');
%删除0数据
del=[];
for ii=1:length(MiliRadarData)
    if MiliRadarData{ii}==0
        del=[del;ii];
    end
end
MiliRadarData(del)=[];MiliRadarData=MiliRadarData.';
%开始绘图
figure1 = figure('color',[0 0 0]);%设置背景黑色
axes1 = axes('Parent',figure1);
az = -37.5; el = 30;%视角设置
for ii=1:length(MiliRadarData)
    datacut=MiliRadarData{ii};
    color=zeros(size(datacut,1),1);
    for jj=1:size(datacut,1)
        color(jj)=norm(datacut(jj,1:3));
    end
    h1=scatter3(datacut(:,1),datacut(:,2),datacut(:,3),5,color,'filled');axis equal;
    caxis([0 20]);
    hold on;
    OriginArrow([-15,-15,-15],5);%绘制箭头
    hold off;
    xlim([-20 20]);ylim([-20 20]);zlim([-20 20]);
    view(az,el)%视角控制
    set(h1,'Selected','Off');
    set(axes1,'Color',[0 0 0]);grid(axes1,'off');
    pause(0.001)
end

%%
%绘制坐标轴

%z轴
figure; hold on; axis equal;
P1 = [0,0,0]; P2 = [0,0,1];
for k = 1:13
    x(k)=0.05*cos(pi/180*k*30);
    y(k)=0.05*sin(pi/180*k*30);
    z(k)=1.8/2;
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'r')
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'r');
plot3(x,y,z,'r');
%y轴
P1 = [0,0,0]; P2 = [0,1,0];
for k = 1:13
    x(k)=0.05*cos(pi/180*k*30);
    z(k)=0.05*sin(pi/180*k*30);
    y(k)=1.8/2;
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'g')
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'g');
plot3(x,y,z,'g');
%x轴
P1 = [0,0,0]; P2 = [1,0,0];
for k = 1:13
    z(k)=0.05*cos(pi/180*k*30);
    y(k)=0.05*sin(pi/180*k*30);
    x(k)=1.8/2;
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'b')
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'b');
plot3(x,y,z,'b');