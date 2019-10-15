clear;close all
tbl = readtable("LidarAnalysisData.csv");
X = tbl.Var1;
Y = tbl.Var2;
Z = tbl.Var3;
reflectivity = tbl.Var4;
clear tbl
%%
%黑色背景图
figure1 = figure('WindowState','maximized','Color',[0 0 0]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');
scatter3(X,Y,Z,1,reflectivity,'MarkerFaceColor','flat','MarkerEdgeColor','none');
zlabel('z /m');
ylabel('北 /m');
xlabel('东 /m');
view(axes1,[-114.01166334542 15.9745271863409]);
axis(axes1,'tight');
caxis([min(reflectivity),100])
% 设置其余坐标区属性
set(axes1,'Color',[0 0 0],'DataAspectRatio',[1 1 1],'XColor',[1 1 1],...
    'YColor',[1 1 1],'ZColor','none');

%%
%白色背景图
figure;scatter3(X,Y,Z,...
    1,reflectivity,'filled');caxis([min(reflectivity),100])
xlabel('东 /m');ylabel('北 /m');zlabel('z /m');axis equal

