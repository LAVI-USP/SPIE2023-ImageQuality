function [nps2D,NNPS1D,f1D] = PS_Lucas_1(img,ROI_size,W,px)
%-------------------------------------------------------------------------
%ROI Definition
%-------------------------------------------------------------------------
[M N] = size(img);
las = mean2(img); %Large Area Signal
%-------------------------------------------------------------------------
% Sub-images Selection (processing each sub-image)
%-------------------------------------------------------------------------
% size of each ROI
% radial coordinates


k = 0;
% for i = 1:round(W/2):M/W
%     for j = 1:round(W/2):N/W
for i = 1:round(W/2):M-W
    for j = 1:round(W/2):N-W
        k = k+1;
%         sub_img(:,:,k) = img((((i-1)*W)+1):i*W,(((j-1)*W)+1):j*W);
        sub_img(:,:,k) = img(i:(i+W)-1,j:(j+W)-1);
% %         mean_sub_img(:,:,k) = mean(mean(sub_img(:,:,k)));
% %         Figure_noise_img(:,:,k) = sub_img(:,:,k);% - mean_sub_img(:,:,k); % Detrending each ROI
    end
end

n=2;
stack_size=size(sub_img,3);
x=linspace(-W/2,W/2,W);
x=repmat(x',[1 ones(1,n-1)*W]);
r2=0; for p=1:n, r2=r2+shiftdim(x.^2,p-1); end, r=sqrt(r2);

h=0.5*(1+cos(pi*r/(W/2)));
h(r>W/2)=0;
h=repmat(h,[ones(1,n) stack_size]);
F=fftshift(fft2(h.*sub_img));

nps2D=abs(F).^2/...
    W^n*px^n./... NPS in units of px^n
    (sum(h(:).^2)/length(h(:))); % the normalization with h is according to Gang 2010
%-------------------------------------------------------------------------
% Calculating the 2D NPS
%-------------------------------------------------------------------------
% [nps2D, f] = calc_digital_nps(Figure_noise_img, 2, px, 1, 1);
nnps2D = nps2D;%/las^2;

%-------------------------------------------------------------------------
% Calculating the 1D NPS - RADIAL - City Block Distance
%-------------------------------------------------------------------------
cx = floor (W/2) + 1;
cy = cx;
for x = 1:W
    for y = 1:W
        d=round(sqrt((x-cx)^2+(y-cy)^2));
        distances(x,y) = d;
    end
end

for k = 1:W/2
    t = 1;
    for x = 1:W
        for y = 1:W
            if (distances(x,y) == k)
                vet_original(t) = nnps2D(x,y);
                t = t+1;
            end
        end
    end
    NNPS1D(k) = mean(vet_original);
end

%frequencies
delta_u = 1/(W*px);
f1D(1) = delta_u;
for i = 1:((W/2)-1)
    f1D(i+1) = f1D(i)+delta_u;
end


