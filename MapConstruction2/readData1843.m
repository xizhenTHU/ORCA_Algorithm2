function scatterCoor = readData1843(filename)
fid1 = fopen(filename,'r');
currFrame = {};
tline = fgetl(fid1);
while ischar(tline)
    currFrame = [currFrame,tline];
    tline = fgetl(fid1);
end
fclose(fid1);

timenow = datestr(now);
timenow(timenow=='-'|timenow==' '|timenow==':')='_';
fid2 = fopen(['data_',timenow,'.txt'],'a');
for n = 1:size(currFrame,2)
    fprintf(fid2,currFrame{1,n});
end
fclose(fid2);

fid = fopen(['data_',timenow,'.txt'],'r');
C = textscan(fid,'%s');
C = C{1};
C = C{1,1};
fclose(fid);
delete(['data_',timenow,'.txt']);

data = zeros(1,length(C));
for indx = 0:9
    data(C==num2str(indx))=indx;
end
data(C=='a') = 10;
data(C=='b') = 11;
data(C=='c') = 12;
data(C=='d') = 13;
data(C=='e') = 14;
data(C=='f') = 15;

data = reshape(data,2,[]);
bytevec = data(1,:)*16+data(2,:);
bytevecStr = char(bytevec);
bytevec = uint8(bytevec);
startIdx = strfind(bytevecStr, char([2 1 4 3 6 5 8 7]));
numFrames = length(startIdx);

scatterCoor = {};
for n = 1:numFrames-1
    startIndex = startIdx(n);
    if startIdx(n+1)-startIdx(n)>80
        totalPacketLen = typecast(bytevec...
            (startIndex+12:startIndex+15),'uint32');
        if startIndex+totalPacketLen==startIdx(n+1)
            currFrame = bytevec(startIndex:startIndex+totalPacketLen-1);
            numDetectedObj = typecast(currFrame(29:32),'uint32');
            if numDetectedObj>0
                TLVLen = typecast(currFrame(45:48),'uint32');
                detectedObjs = currFrame(49:48+TLVLen);
                detectedObjs = typecast(detectedObjs,'single');
                detectedObjs = reshape(detectedObjs,4,[]);
                detectedObjs = detectedObjs';
                TLVLen_sideInfo = typecast(...
                    currFrame(48+TLVLen+5:48+TLVLen+8),'uint32');
                SideInfo = currFrame(48+TLVLen+9:48+TLVLen+8+TLVLen_sideInfo);
                SideInfo = typecast(SideInfo,'int16');
                SideInfo = reshape(SideInfo,2,[]);
                SideInfo = single(SideInfo');
                scatter_coor = [detectedObjs,SideInfo];
                scatterCoor = [scatterCoor,scatter_coor];
            else
                scatterCoor = [scatterCoor,0];
            end
        end
    end
end
end