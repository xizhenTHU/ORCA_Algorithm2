clear;close all;clc
% opts = spreadsheetImportOptions("NumVariables", 18);
% opts.Sheet = "mongo_ship_history";
% % opts.DataRange = "A2:R443";
% opts.VariableNames = ["id", "ship_number", "ship_id", "location", "yaw", "pd_percent", "pd_rematime", "pd_current", "speed", "temperature", "err", "imu_err", "linux_state", "gps_mode", "route_id", "extend", "time", "class"];
% opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "categorical", "string", "string", "categorical"];
% opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17], "WhitespaceRule", "preserve");
% opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], "EmptyFieldRule", "auto");
% data = readtable("C:\工程文件\ORCA\代码\2_Algorithm2\区域清洁迭代\test_1_1.xlsx", opts, "UseExcel", false);

opts = spreadsheetImportOptions("NumVariables", 18);
opts.Sheet = "mongo_ship_history";
% opts.DataRange = "A2:R417";
opts.VariableNames = ["id", "ship_number", "ship_id", "location", "yaw", "pd_percent", "pd_rematime", "pd_current", "speed", "temperature", "err", "imu_err", "linux_state", "gps_mode", "extend", "time", "class", "route_id"];
opts.VariableTypes = ["string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "string", "categorical", "string"];
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18], "WhitespaceRule", "preserve");
opts = setvaropts(opts, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], "EmptyFieldRule", "auto");
data = readtable("E:\项目工程\ORCA\代码\2_Algorithm2\区域清洁迭代\test_3_2.xlsx", opts, "UseExcel", false);

filename = 'E:\项目工程\ORCA\代码\2_Algorithm2\区域清洁迭代\区域2.txt';
delimiter = ' ';
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'TextType', 'string',  'ReturnOnError', false);
fclose(fileID);
area = array2table([dataArray{1:end-1}].',...
    'VariableNames',{'lng','lat'});
clearvars filename delimiter formatSpec fileID dataArray ans opts;

data=data(end:-1:2,:);
%删除
data.id=[];data.ship_number=[];data.ship_id=[];data.err=[];
data.pd_percent=[];data.pd_rematime=[];data.pd_current=[];data.imu_err=[];
data.temperature=[];data.class=[];data.route_id=[];%data.linux_state=[];
%转换字符串
data.linux_state=double(data.linux_state);
data.yaw=double(data.yaw);
data.speed=double(data.speed);
data.time=double(data.time);
data.gps_mode=double(data.gps_mode);

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
lla=[data.lat,data.lng,zeros(size(data.lat))];p = lla2ecef(lla, 'WGS84');
[data.xEast,data.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.lat(1),data.lng(1),0,wgs84Ellipsoid);
lla=[area.lat,area.lng,zeros(size(area.lat))];p = lla2ecef(lla, 'WGS84');
[area.xEast,area.yNorth,~] = ecef2enu(p(:,1),p(:,2),p(:,3),data.lat(1),data.lng(1),0,wgs84Ellipsoid);
clear ia latlng ib p lla ii temp

data.time=double(data.time);
data.time = datetime(datestr((data.time+28800000)/86400000 + datenum(1970,1,1),31));

data.vert=zeros(size(data.time));
expression='vert:(([-]\d*,|\d*,)|([-]\d.\d*,|\d.\d*,))';
for ii=1:height(data)
    str=erase(data.extend(ii),'"');
    str=erase(str,' ');
%     newStr = split(str,',');
%     num=strfind(newStr(1),':');
%     str=char(newStr(1));
    out = regexp(str,expression,'match');
    out=split(out,{':',','}) ;
    data.vert(ii) = double(out(2));
%     data.vert(ii) = double(string(str(num+1:end)));
end
data.extend=[];
clear ii newStr num str

% figure;plot(area.xEast,area.yNorth,'.-');axis equal
figure;plot(data.xEast,data.yNorth,'.-');hold on;plot(area.xEast,area.yNorth,'.-');axis equal
figure;plot(data.vert,'.-');
figure;plot(data.speed,'.-');


vert_err=abs(data.vert);
str=['平均误差 ',num2str(mean(vert_err)),' m,最大误差 ',num2str(max(vert_err)),' m'];
disp(str)
edges = 0:0.25:max(vert_err);
figure;histogram(vert_err,edges,'Normalization','probability');xlabel('误差距离');ylabel('百分比');title(str)
less_05=sum(vert_err<=0.5)/length(vert_err)*100;
less_07=sum(vert_err<=0.7)/length(vert_err)*100;
less_09=sum(vert_err<=0.9)/length(vert_err)*100;
str=['误差小于0.5m占',num2str(less_05),...
    '%,误差小于0.7m占',num2str(less_07),...
    '%,误差小于0.9m占',num2str(less_09),'%'];
disp(str)

% 宁波性能
% 平均误差 0.36467 m,最大误差 2.7158 m
% 误差小于0.5m占73.9679%,误差小于0.7m占88.797%,误差小于0.9m占95.3273%

% 区域1
% 108.898856,34.246944;108.898814,34.246858;108.898927,34.246829;108.898973,34.246925;
