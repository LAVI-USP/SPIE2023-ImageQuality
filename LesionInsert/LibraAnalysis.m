function [res] = LibraAnalysis (ImgFolder,ImgDensityMask)

folder = [ImgDensityMask '\Result_Images\'];
if exist(folder, 'dir')
    rmdir(folder, 's');
end

system(['libra.exe ' '"' ImgFolder '"' ' ' '"' ImgDensityMask '"' ' 1']); % Runs LIBRA to get density mask

direc = dir(fullfile([ImgDensityMask '\Result_Images'], '*.mat'));

load([ImgDensityMask '\Result_Images\' direc.name]) % Loads density map

end