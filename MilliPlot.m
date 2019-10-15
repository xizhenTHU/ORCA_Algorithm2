%绘制毫米波雷达
clear
% MiliRadarData=readData1843('C:\Users\WPD\Documents\WeChat Files\eryuzhen\FileStorage\File\2019-07\data_person1.txt');
selpath='C:\工程文件\ORCA\代码\2_Algorithm2\Data\1564739132.995';
selpath='C:\Users\WPD\Desktop\1565249228.996';
dirMiliRadar = dir([selpath,'\radar*\*data*.txt']);

MiliRadarData1=readData1843([dirMiliRadar(1).folder,'\',dirMiliRadar(1).name]).';
MiliRadarData2=readData1843([dirMiliRadar(2).folder,'\',dirMiliRadar(2).name]).';
MiliRadarData3=readData1843([dirMiliRadar(3).folder,'\',dirMiliRadar(3).name]).';
MiliRadarData4=readData1843([dirMiliRadar(4).folder,'\',dirMiliRadar(4).name]).';
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
    if datacut==0
        continue
    end
    color=zeros(size(datacut,1),1);
    for jj=1:size(datacut,1)
        color(jj)=norm(datacut(jj,1:3));
    end
    h1=scatter3(datacut(:,1),datacut(:,2),datacut(:,3),5,color,'filled');axis equal;
    caxis([0 20]);
    hold on;
    OriginArrow([-15,-15,-15]/5,5/5);%绘制箭头
    hold off;
    xlim([-20 20]/4);ylim([-20 20]/4);zlim([-20 20]/4);
    view(az,el)%视角控制
    set(h1,'Selected','Off');
    set(axes1,'Color',[0 0 0]);grid(axes1,'off');
    pause(0.01)
end
