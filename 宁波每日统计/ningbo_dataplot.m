clear;close all;clc
opts = spreadsheetImportOptions("NumVariables", 10);
% opts.Sheet = "9��17��";
% opts.DataRange = "A2:J23095";
opts.VariableNames = ["lng", "lat", "yaw", "pd_percent", "speed", "err", "linux_state", "gps_mode", "time", "vert_err"];
opts.SelectedVariableNames = ["lng", "lat", "yaw", "pd_percent", "speed", "err", "linux_state", "gps_mode", "time", "vert_err"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "datetime", "double"];
opts = setvaropts(opts, 9, "InputFormat", "");
data = readtable("C:\�����ļ�\ORCA\����\2_Algorithm2\����ÿ��ͳ��\������¼_0917.xlsx", opts, "UseExcel", false);
clear opts
data(1,:)=[];

vert_err=abs(data.vert_err(data.linux_state==1));
vert_err(isnan(vert_err))=[];
del=[false;diff(vert_err)==0];
vert_err(del)=[];
str=['ƽ����� ',num2str(mean(vert_err)),' m,������ ',num2str(max(vert_err)),' m'];
disp(str)
edges = 0:0.1:max(vert_err);
figure;histogram(vert_err,edges,'Normalization','probability');xlabel('������');ylabel('�ٷֱ�');title(str)
edges = 0:0.25:max(vert_err);
figure;histogram(vert_err,edges,'Normalization','probability');xlabel('������');ylabel('�ٷֱ�');title(str)
less_05=sum(vert_err<=0.5)/length(vert_err)*100;
less_07=sum(vert_err<=0.7)/length(vert_err)*100;
less_09=sum(vert_err<=0.9)/length(vert_err)*100;
str=['���С��0.5mռ',num2str(less_05),...
    '%,���С��0.7mռ',num2str(less_07),...
    '%,���С��0.9mռ',num2str(less_09),'%'];
disp(str)

figure;plot(data.linux_state);hold on;plot(data.vert_err)