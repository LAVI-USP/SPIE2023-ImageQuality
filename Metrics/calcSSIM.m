function [Results] = calcSSIM(GT,mask,img_noisy)
% Recebe o ground-truth, a máscara e um conjunto de imagens ruídosas
% Dynamic range default = 1 (necessária imagem double normalizada 0 a 1)
% Calcula o SSIM somente na região da máscara, utilizando o mapa de valores

rl=size(img_noisy,3);
for k=1:rl
%     Img = img_noisy(:,:,k);
%     l = max(Img(mask)); % checar valor máximo global dentro da mama
%     l = max(Img(:)); % checar valor máximo global da imagem
% %     SSIM(k)=ssim(Img(mask),GT(mask),'DynamicRange',l);

    [~, ssimmap] = ssim(img_noisy(:,:,k),GT);%,'DynamicRange',1);
    ssim_mask(k) = mean(ssimmap(mask));
%     imtool(ssimmap,[]);
end

% Results=mean(SSIM);
Results=mean(ssim_mask);

end