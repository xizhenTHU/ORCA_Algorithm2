function plotRealSense(app,index_RealSense,axes)
%RealSenseÊä³ö
nameRGB=[app.dirRGB(index_RealSense).folder,'\',app.dirRGB(index_RealSense).name];
nameDeepth=[app.dirDeepth(index_RealSense).folder,'\',app.dirDeepth(index_RealSense).name];
ImRGB=imresize(imread(nameRGB),185/720);
ImDeepth=imresize(imread(nameDeepth),185/720);
% image(app.RGBPic,ImRGB);set(app.RGBPic,'Xtick',[],'Ytick',[]);
% image(app.DeepPic,ImDeepth);set(app.DeepPic,'Xtick',[],'Ytick',[]);
image(axes,ImRGB);
% h_RGBPic=image(ImRGB);%set(h_RGBPic,'Xtick',[],'Ytick',[]);
% h_DeepPic=image(ImDeepth);%set(h_DeepPic,'Xtick',[],'Ytick',[]);
% figure_RGBPic = figure;
% axes_RGBPic = axes('Parent',figure_RGBPic);
% image(ImRGB,'Parent',axes_RGBPic);
% 
% figure_DeepPic = figure;
% axes_DeepPic = axes('Parent',figure_DeepPic);
% image(ImDeepth,'Parent',axes_DeepPic);

pause(1.e-5)
end
