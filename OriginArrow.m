function OriginArrow(OriginPoint,Arrowlength)
%OriginPoint=[1,1,2];Arrowlength=5;
% z÷·
P1 = [0,0,0]+OriginPoint; P2 = [0,0,Arrowlength]+OriginPoint;
for k = 1:13
    x(k)=Arrowlength*0.05*cos(pi/180*k*30)+OriginPoint(1);
    y(k)=Arrowlength*0.05*sin(pi/180*k*30)+OriginPoint(2);
    z(k)=Arrowlength*0.8+OriginPoint(3);
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'r')
    hold on;
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'r');
plot3(x,y,z,'r');

% y÷·
P1 = [0,0,0]+OriginPoint; P2 = [0,Arrowlength,0]+OriginPoint;
for k = 1:13
    x(k)=Arrowlength*0.05*cos(pi/180*k*30)+OriginPoint(1);
    z(k)=Arrowlength*0.05*sin(pi/180*k*30)+OriginPoint(3);
    y(k)=Arrowlength*0.8+OriginPoint(2);
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'g')
    hold on;
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'g');
plot3(x,y,z,'g');

% x÷·
P1 = [0,0,0]+OriginPoint; P2 = [Arrowlength,0,0]+OriginPoint;
for k = 1:13
    z(k)=Arrowlength*0.05*cos(pi/180*k*30)+OriginPoint(3);
    y(k)=Arrowlength*0.05*sin(pi/180*k*30)+OriginPoint(2);
    x(k)=Arrowlength*0.8+OriginPoint(1);
    plot3([P2(1),x(k)],[P2(2),y(k)],[P2(3),z(k)],'b')
    hold on;
end
plot3([P1(1),P2(1)],[P1(2),P2(2)],[P1(3),P2(3)],'b');
plot3(x,y,z,'b');
% annotation(figure1,'textbox',...
%     [0.5 0.5 0.05 0.1],...
%     'Color',[1 0 0],...
%     'String','X',...
%     'FontSize',15,...
%     'FitBoxToText','off',...
%     'EdgeColor','none');

end

