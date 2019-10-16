

% 调整距离过近的点，使之距离大于阈值
% load('x.mat')
% dist=diff(x);
% del=[];
% dist_temp=dist(1);
% for ii=2:length(x)-1
%     if dist_temp>=0.15
%         del=[del;ii-1];
%         dist_temp=dist(ii);
%     else
%         dist_temp=dist_temp+dist(ii);
%     end
% end
% x(del)=[];
% dist=diff(x);

% load('x.mat')
dist=[ones(10,1)*0.1,ones(10,1)*0.07];
dist=reshape(dist.',1,[]).';
x=zeros(length(dist)+1,1);
for ii=2:length(x)
    x(ii)=x(ii-1)+dist(ii-1);
end
while sum(dist<0.15)
    del=[];
    dist_temp=dist(1);
    for ii=2:length(x)-1
        if dist_temp<0.15
            del=[del;ii];
            dist_temp=dist_temp+dist(ii);
        else
            dist_temp=dist(ii);
        end
    end
    x(del)=[];
    dist=diff(x);
end
sum(dist<0.15)
