function plotMiliRadar(app,index_miliRadar)
%毫米波雷达1
datacut=app.MiliRadarData1{index_miliRadar};
if datacut==0
    cla(app.MillimeterWaveRadar1);
else
    %color=zeros(size(datacut,1),1);
    %for jj=1:size(datacut,1)
    %color(jj)=norm(datacut(jj,1:3));
    %end
    scatter3(app.MillimeterWaveRadar1,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    pause(1.e-5)
end

%毫米波雷达2
datacut=app.MiliRadarData2{index_miliRadar};
if datacut==0
    cla(app.MillimeterWaveRadar3);
else
    scatter3(app.MillimeterWaveRadar3,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    pause(1.e-5)
end

%毫米波雷达3
datacut=app.MiliRadarData3{index_miliRadar};
if datacut==0
    cla(app.MillimeterWaveRadar4);
else
    scatter3(app.MillimeterWaveRadar4,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    pause(1.e-5)
end
end

