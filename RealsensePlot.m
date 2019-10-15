clear
selpath='C:\工程文件\ORCA\代码\2_Algorithm2\Data\1564739132.995';

dirRGB = dir([selpath,'\realsense*\rgb\*.jpg']);
% [~, ind] = sort([dirRGB(:).datenum], 'ascend');
% dirRGB = dirRGB(ind);

dirDeepth = dir([selpath,'\realsense*\depth\*.jpg']);
% [~, ind] = sort([dirDeepth(:).datenum], 'ascend');
% dirDeepth = dirDeepth(ind);

figure;
for ii=1:size(dirDeepth,1)
    nameRGB=[dirRGB(ii).folder,'\',dirRGB(ii).name];
    nameDeepth=[dirDeepth(ii).folder,'\',dirDeepth(ii).name];    
    imshow(nameRGB);
    imshow(nameDeepth);
    title(num2str(ii));
    pause(0.01)
end

