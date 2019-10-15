function plotMiliRadar(app,index_miliRadar,axes_mili_front,axes_mili_left,axes_mili_right)
% 绘制实时毫米波雷达数据
%没有具体限制坐标区范围大小

%顺序 123 分别对应 右前左
%毫米波雷达1
datacut=app.MiliRadarData1{index_miliRadar};
if datacut==0
    cla(axes_mili_right);
else
    %color=zeros(size(datacut,1),1);
    %for jj=1:size(datacut,1)
    %color(jj)=norm(datacut(jj,1:3));
    %end
    scatter3(axes_mili_right,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    zlabel(axes_mili_right,{'z'});ylabel(axes_mili_right,{'y'});xlabel(axes_mili_right,{'x'});
    title(axes_mili_right,'右视');view(axes_mili_right,[-37.5 30]);
    pause(1.e-5)
end

%毫米波雷达2
datacut=app.MiliRadarData2{index_miliRadar};
if datacut==0
    cla(axes_mili_front);
else
    scatter3(axes_mili_front,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    zlabel(axes_mili_front,{'z'});ylabel(axes_mili_front,{'y'});xlabel(axes_mili_front,{'x'});
    title(axes_mili_front,'前视');view(axes_mili_front,[-37.5 30]);
    pause(1.e-5)
end

%毫米波雷达3
datacut=app.MiliRadarData3{index_miliRadar};
if datacut==0
    cla(axes_mili_left);
else
    scatter3(axes_mili_left,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    zlabel(axes_mili_left,{'z'});ylabel(axes_mili_left,{'y'});xlabel(axes_mili_left,{'x'});
    title(axes_mili_left,'左视');view(axes_mili_left,[-37.5 30]);
    pause(1.e-5)
end
end

