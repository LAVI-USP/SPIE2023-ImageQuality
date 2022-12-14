function [mnse, res_noise, bias, ssim_index, qilv_index, naqi_index, psnr_index, cpbd_index, haarpsi_index] = metrics_calc(phanVCT, mask_VCT, img_noisy_Red, img_noisy_100pcrt)
    addpath('Metrics')
    mnse=1;
    res_noise=0;
    bias=0;
    ssim_index=1;
    qilv_index=1;
    naqi_index=1;
    psnr_index=1;
    ps=1;
    cpbd_index=1;
    haarpsi_index=1;
    
    %% Normalization
    for k=1:size(img_noisy_Red,3)
        Img = img_noisy_Red(:,:,k);
        ImgNoisy(:,:,k) = reshape(polyval(polyfit(Img(mask_VCT),phanVCT(mask_VCT),1),Img),size(phanVCT));
        Img_temp = ImgNoisy(:,:,k);
        img_noisy_norm(:,:,k) = mat2gray(Img_temp, [min(Img_temp(mask_VCT)) max(Img_temp(mask_VCT))]);
    end
    noisy_red = img_noisy_norm(:,:,1);

    %% Normalization (full-dose)
    for k=1:size(img_noisy_100pcrt,3)
        Img_fd = img_noisy_100pcrt(:,:,k);
        ImgNoisy_fd(:,:,k) = reshape(polyval(polyfit(Img_fd(mask_VCT),phanVCT(mask_VCT),1),Img_fd),size(phanVCT));
        Img_temp_fd = ImgNoisy_fd(:,:,k);
        img_noisy_norm_fd(:,:,k) = mat2gray(Img_temp_fd, [min(Img_temp_fd(mask_VCT)) max(Img_temp_fd(mask_VCT))]);
    end
    noisy_fd = img_noisy_norm_fd(:,:,1);

    %% GT Normalization
    phanVCT_norm = mat2gray(phanVCT, [min(phanVCT(mask_VCT)) max(phanVCT(mask_VCT))]);
    phanVCT_norm2 = mat2gray(phanVCT, [min(phanVCT(:)) max(phanVCT(:))]);
    
    %% PS
    if ps==1
        [~,NPS1D,f1D] = PS_Lucas_1(img_noisy_norm(1300:1800,1800:2300),256,256,0.1);
        semilogy(f1D,NPS1D,'--','LineWidth',2);
        hold on;
        [~,NPS1D,f1D] = PS_Lucas_1(img_noisy_norm_fd(1300:1800,1800:2300),256,256,0.1);
        semilogy(f1D,NPS1D,'-','LineWidth',2);
        hold on;
        legend('Correlated','Non-correlated','GT')
        axis([1 5 10^-8 10^-6])
        xlabel('Frequency (mm^{-1})')
        ylabel('Power Spectrum (mm²)')
        grid on;grid minor
        set(gca,'FontSize',14);
    end
    
    %% CPBD
    if cpbd_index==1
        cpbd_index = CPBD_compute(uint16(Img_temp(1250:2100,1800:2394)));
    end
    
    %% HaarPSI
    if haarpsi_index==1
        haarpsi_index = HaarPSI(phanVCT(1250:2100,1800:2394),Img_temp(1250:2100,1800:2394));
    end

    %% MNSE
    if mnse==1 || res_noise==1 || bias==1
        [mnse, res_noise, bias] = calcMNSE(phanVCT,mask_VCT,img_noisy_Red);
    end

    %% SSIM
    if ssim_index==1
        [ssim_index] = calcSSIM(phanVCT_norm,mask_VCT,img_noisy_norm);
    end

    %% QILV
    if qilv_index==1
        qilv_index=qilv_a(phanVCT,Img_temp,0,mask_VCT);
    end

     %% NAQI
     if naqi_index==1
        addpath('Metrics\aqi')

        se = strel('disk',20);
        Mask=imerode(mask_VCT,se);
        [~,naqi_index,~]=aqindex_mask(Img_temp,16,4,0,'degree','gray',Mask);
     end

    %% PSNR
    if psnr_index==1
        [psnr_index, ~] = psnr(Img_temp(mask_VCT)-50,phanVCT(mask_VCT)-50,max(Img_temp(mask_VCT)-50));
    end
end