clear;close all;clc
opts = spreadsheetImportOptions("NumVariables", 17);
opts.Sheet = "mongo_ship_history";
opts.DataRange = "A2:Q172";
opts.VariableNames = ["id", "ship_number", "ship_id", "location", "yaw", "pd_percent", "pd_rematime", "pd_current", "speed", "temperature", "err", "imu_err", "linux_state", "gps_mode", "extend", "time", "class"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "categorical"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], "EmptyFieldRule", "auto");
data = readtable("E:\项目工程\ORCA\代码\2_Algorithm2\轨迹推算\mongo_ship_history.xlsx", opts, "UseExcel", false);
clear opts
data=data(end:-1:1,:);
%删除
data.id=[];data.ship_number=[];data.ship_id=[];data.err=[];
data.pd_percent=[];data.pd_rematime=[];data.pd_current=[];data.imu_err=[];
data.temperature=[];data.class=[];data.linux_state=[];
%转换字符串
data.yaw=double(data.yaw);
data.speed=double(data.speed);
data.time=double(data.time);
data.gps_mode=double(data.gps_mode);

%删除非GO数据
data.dire=zeros(size(data.yaw));
data.thrust=zeros(size(data.yaw));
data.state=strings(size(data.yaw));
del=[];
for ii=1:length(data.yaw)
    str=erase(data.extend(ii),'"');
    str=erase(str,' ');
    newStr = split(str,',');
    data.dire(ii) = double(regexp(newStr(1),'([-]\d*|\d*)','match'));
    data.thrust(ii) = double(regexp(newStr(2),'([-]\d*|\d*)','match'));
    if ~contains(newStr(3),'State.')
        del=[del;ii];
        continue
    else
        data.state(ii) = extractBetween(newStr(3),".","}");
        if ~strcmp(data.state(ii),'GO')
            del=[del;ii];
        end
    end
end
data(del,:)=[];
data.extend=[];

latlng = data.location;
latlng = erase(latlng,["[","]"," "]);
data.lat=zeros(length(latlng),1);
data.lng=zeros(length(latlng),1);
for ii=1:length(latlng)
    temp=strsplit(latlng{ii,:},',');
    data.lat(ii)=str2double(temp(2));
    data.lng(ii)=str2double(temp(1));
end
data.location=[];

data(1:32,:)=[];
data1=data(1:43,:);
data2=data(44:end,:);
data1.time=(data1.time-data1.time(1))/1000;
data2.time=(data2.time-data2.time(1))/1000;

clear ii data str del newStr latlng temp

%%
% data2(1:11,:)=[];

lla=[data1.lat,data1.lng,zeros(size(data1.lat))];p = lla2ecef(lla, 'WGS84');
[data1.xEast,data1.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data1.lat(1),data1.lng(1),0,wgs84Ellipsoid);
data1.dist=zeros(size(data1.xEast));
data1.acc=zeros(size(data1.xEast));
for ii=2:length(data1.xEast)
    data1.dist(ii)=norm([data1.xEast(ii)-data1.xEast(ii-1),data1.yNorth(ii)-data1.yNorth(ii-1)]);
    data1.acc(ii)=(data1.speed(ii)-data1.speed(ii-1))/(data1.time(ii)-data1.time(ii-1));
end
lla=[data2.lat,data2.lng,zeros(size(data2.lat))];p = lla2ecef(lla, 'WGS84');
[data2.xEast,data2.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data2.lat(1),data2.lng(1),0,wgs84Ellipsoid);
data2.dist=zeros(size(data2.xEast));
data2.acc=zeros(size(data2.xEast));
for ii=2:length(data2.xEast)
    data2.dist(ii)=norm([data2.xEast(ii)-data2.xEast(ii-1),data2.yNorth(ii)-data2.yNorth(ii-1)]);
    data2.acc(ii)=(data2.speed(ii)-data2.speed(ii-1))/(data2.time(ii)-data2.time(ii-1));
end
clear temp latlng ii p lla str del newStr


figure;plot(data1.xEast,data1.yNorth,'MarkerSize',12,'Marker','.','LineWidth',1.5);axis equal;xlabel('xEast');ylabel('yNorth');
figure;yyaxis left;plot(data1.time,data1.speed,'MarkerSize',12,'Marker','.','LineWidth',1.5);
yyaxis right;plot(data1.time,data1.thrust,'MarkerSize',12,'Marker','.','LineWidth',1.5);
% figure;yyaxis left;plot(data1.time,data1.acc,'.-');yyaxis right;plot(data1.time,data1.thrust,'.-');

figure;plot(data2.xEast,data2.yNorth,'MarkerSize',12,'Marker','.','LineWidth',1.5);axis equal;xlabel('xEast');ylabel('yNorth');
figure;yyaxis left;plot(data2.time,data2.speed,'MarkerSize',12,'Marker','.','LineWidth',1.5);
yyaxis right;plot(data2.time,data2.thrust,'MarkerSize',12,'Marker','.','LineWidth',1.5);

% figure;yyaxis left;plot(data2.time,data2.speed,'.-');yyaxis right;plot(data2.time,(data2.dist),'.-');
% figure;yyaxis left;plot(data2.time,data2.speed,'.-');yyaxis right;plot(data2.time,round(data2.dist,1),'.-');


figure;yyaxis left;plot(data2.time(1:end-2),data2.speed(3:end),'MarkerSize',12,'Marker','.','LineWidth',1.5);
yyaxis right;plot(data2.time(1:end-2),data2.thrust(1:end-2),'MarkerSize',12,'Marker','.','LineWidth',1.5);

thrust=data2.thrust(1:end-2);speed=data2.speed(3:end);
figure;plot(thrust,speed,'.');xlabel('thrust');ylabel('speed');

