function plotMiliRadar(app,index_miliRadar,axes_mili_front,axes_mili_left,axes_mili_right)
% ����ʵʱ���ײ��״�����
%û�о���������������Χ��С

%˳�� 123 �ֱ��Ӧ ��ǰ��
%���ײ��״�1
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
    title(axes_mili_right,'����');view(axes_mili_right,[-37.5 30]);
    pause(1.e-5)
end

%���ײ��״�2
datacut=app.MiliRadarData2{index_miliRadar};
if datacut==0
    cla(axes_mili_front);
else
    scatter3(axes_mili_front,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    zlabel(axes_mili_front,{'z'});ylabel(axes_mili_front,{'y'});xlabel(axes_mili_front,{'x'});
    title(axes_mili_front,'ǰ��');view(axes_mili_front,[-37.5 30]);
    pause(1.e-5)
end

%���ײ��״�3
datacut=app.MiliRadarData3{index_miliRadar};
if datacut==0
    cla(axes_mili_left);
else
    scatter3(axes_mili_left,datacut(:,1),datacut(:,2),datacut(:,3),4,datacut(:,3),'filled');
    zlabel(axes_mili_left,{'z'});ylabel(axes_mili_left,{'y'});xlabel(axes_mili_left,{'x'});
    title(axes_mili_left,'����');view(axes_mili_left,[-37.5 30]);
    pause(1.e-5)
end
end

