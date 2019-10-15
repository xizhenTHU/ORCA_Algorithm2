function Showoneframedata(scatterCoor,data,mmwtime)
figure;
for i=1:length(scatterCoor)
 cellpoint=scatterCoor(i);
 point=cellpoint{1};
 if length(point)>1
    x=point(:,1);
    y=point(:,2);
    z=point(:,3);
    v=point(:,4);
    snr=point(:,5);
    noise=point(:,6);
    subplot(1,2,1);
    scatter3(x,y,z,[],v,'.');
    xlabel('x÷·');
    ylabel('y÷·');
    colorbar;
    xlim([-10 10]);
    ylim([0 15]);
    zlim([-1 3]);
    view(0,90)
    %pause(0.05);
    %pause;
 end
    [val loc]=min(abs(mmwtime(i)-data.TimeNum.gps));
%     loc=ceil(i/912*257);
    subplot(1,2,2);
    plot(data.gpsData.xEast(1:loc),data.gpsData.yNorth(1:loc),'.-');
    xlim([-5 40]);
    ylim([-5 40]);
    pause(0.1);
    yaw_raw=360-(data.imuData.yaw+180);
    [val loc]=min(abs(mmwtime(i)-data.imuData.timenum));
%     loc=ceil(i/912*257);
    i
    yaw_raw(loc)
end
%plot(showdata1)
end