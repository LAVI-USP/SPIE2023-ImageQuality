close all
clear
clc

%% Main Parameters
lesion = 1;
libra = 1;
full_dose = 1;
metrics = 1;
correlation = 1;

%% Noise Parameters
addpath('Parameters')

% OFFSET
Tau_nominal = 0;

% GE KERNEL
load('KernelGE_Lucas')
Ke = K_e;

% RADIATION DOSE LEVELS
% 50% ---> 0.5
doses = [1];

% REALIZATIONS
realizations = 1;

%% Microcalcifications contrast
% Contrast=0.2;
% for k=2:15
%     Contrast(k)=Contrast(k-1)*0.85;
% end
Contrast=0.0472;

%% -------------- REAL PHANTOM ------------------
ImgPath='Anthro_Raw';

% GT
ind = 1;
for k=1:11
    if(k~=3)
        z_GT(:,:,ind)=double(dicomread([ImgPath '/34kVp_50mAs/' num2str(997+k) '.dcm']));
        ind = ind + 1;
    end
end

gt_real = mean(z_GT,3) - Tau_nominal;
load('Anthro_Raw\BreastMaskFFDM_new.mat')
real_min = min(gt_real(BreastMask));
real_max = max(gt_real(BreastMask));
deltaReal = (real_max - real_min);

%% Images
ImgFolder = ['Phantoms'];
theFiles = dir(fullfile(ImgFolder, '*.dcm'));

for im = 1:length(theFiles)
    disp('1º Image reading...')
    fullFileName = fullfile(theFiles(im).folder, theFiles(im).name);
    phanVCT = double(dicomread(fullFileName)) - Tau_nominal;
    
    % Mask
    load([ImgFolder '\mask']);
    
    % Normalization
    phanVCT = (phanVCT - min(phanVCT(mask_VCT))) / (max(phanVCT(mask_VCT)) - min(phanVCT(mask_VCT)));
    
    %% Noise parameters
    for d=1:length(doses)
        Reduc = doses(d);
        if Reduc == 1
            load('Parameters_GE_Pristina_FFDM_Linear_50mAs_New');
        end

        %% Lambda adjustment
        disp('2º Noise parameters adjustment...')
        [M_img N_img] = size(phanVCT);
        [M_Lamb N_Lamb] = size(Lambda_e);

        dif_M = abs(M_Lamb - M_img);
        dif_N = abs(N_Lamb - N_img);

        % Breast position
        med1 = mean2(phanVCT(:,1:round(N_img/2)));
        med2 = mean2(phanVCT(:,round(N_img/2):end));

        if med1 < med2
            % Reduced dose
            Lambda_e = Lambda_e(1+fix(dif_M/2):end-ceil(dif_M/2),1+dif_N:end);
            Lambda = fliplr(Lambda_e);
            lamb_invert = 1;
            
            % GE QUANTUM AND ELECTRONIC NOISE (FULL-DOSE)
            if full_dose == 1 && d == 1
                % Full-dose
                params_fd = load('Parameters_GE_Pristina_FFDM_Linear_50mAs_New');
                Lambda_e_fd = params_fd.Lambda_e(1+fix(dif_M/2):end-ceil(dif_M/2),1+dif_N:end);
                params_fd.Lambda_e = fliplr(Lambda_e_fd);
            end
        else
            % Reduced dose
            Lambda_e = Lambda_e(1+fix(dif_M/2):end-ceil(dif_M/2),1:end-dif_N);
            Lambda = Lambda_e;
            lamb_invert = 0;

            if full_dose == 1 && d == 1
                % Full-dose
                params_fd = load('Parameters_GE_Pristina_FFDM_Linear_50mAs_New');
                Lambda_e_fd = params_fd.Lambda_e(1+fix(dif_M/2):end-ceil(dif_M/2),1:end-dif_N);
                params_fd.Lambda_e = Lambda_e_fd;
            end
        end

        clear N_img M_Lamb N_Lamb dif_M dif_N med1 med2 Lambda_e Lambda_e_fd

        %% Gray level correction
        if d == 1
            disp('3º Gray level correction...')
            
            phanVCT = deltaReal.*phanVCT + real_min;

            clear ImgPath ind k gt_real meanPixelReal
            clear meanPixelVCT fator
        
            %% Lesion insertion
            if lesion == 1
                disp('4º Lesion insertion...')

                if libra == 1
                    % LIBRA
                    addpath('LesionInsert')
                    [res] = LibraAnalysis(fullFileName,ImgFolder);
                else
                    [~,name,~] = fileparts(fullFileName);
                    load([ImgFolder '\Densities\Masks_' name])
                end
                
                ImgOutput = [ImgFolder '\Images_Output\']; mkdir(ImgOutput);

                addpath('LesionInsert')
                [ImgL,SimulationInfo] = LesionInsert(phanVCT,Contrast,res,0,fullFileName,ImgOutput,0);
                
                ImgL = double(ImgL);
                phanVCT_L = ImgL + Tau_nominal;

                clear newfolder k ImgOutput res
            end
        end

        %% Noise insertion
        disp('5º Noise insertion...')        

        if lesion == 1
            if full_dose == 1 && d == 1
                % Full-dose
                for c=1:length(Contrast)
                    for i=1:realizations
                        [img_noisy_100pcrt(:,:,i,c)] = NoiseInsert_GE(ImgL(:,:,c),params_fd.Sigma_E,params_fd.Lambda_e,Tau_nominal,Ke,correlation-1);
                    end
                end
                img_noisy_fd = img_noisy_100pcrt(:,:,1,1);
            end

            % Reduced/increased dose
            for c=1:length(Contrast)
                phanVCT_Red = ImgL(:,:,c).*Reduc;
                
                for i=1:realizations
                    [img_noisy_Red(:,:,i,c)] = NoiseInsert_GE(phanVCT_Red,Sigma_E,Lambda,Tau_nominal,Ke,correlation);
                end
            end
        else
            if full_dose == 1 && d == 1
                % Full-dose
                for i=1:realizations
                    [img_noisy_100pcrt(:,:,i)] = NoiseInsert_GE(phanVCT,params_fd.Sigma_E,params_fd.Lambda_e,Tau_nominal,Ke,correlation*-1);
                end
                img_noisy_fd = img_noisy_100pcrt(:,:,1);
            end

            % Reduced/increased dose
            phanVCT_Red = phanVCT.*Reduc;
            for i=1:realizations
                [img_noisy_Red(:,:,i)] = NoiseInsert_GE(phanVCT_Red,Sigma_E,Lambda,Tau_nominal,Ke,correlation);
            end
            
            % GT
            phanVCT_T = phanVCT + Tau_nominal;
        end
        clear mask phanVCT_Red i

        %% Objective metrics
        if metrics == 1
            disp('6º Objective quality metrics...')
            
            img_noisy_Red = ((img_noisy_Red - Tau_nominal)./Reduc) + Tau_nominal;
            
            if lesion == 0
                [mnse_noisy(im,d), res_noise_noisy(im,d), bias_noisy(im,d), ssim_index_noisy(im,d), qilv_index_noisy(im,d), naqi_index_noisy(im,d), psnr_index_noisy(im,d), cpbd_index_noisy(im,d), haarpsi_index_noisy(im,d)] = metrics_calc(phanVCT_T, mask_VCT, img_noisy_Red);
            end
            
            if lesion == 1
                for c=1:length(Contrast)
                    [mnse_noisy(im,d,c), res_noise_noisy(im,d,c), bias_noisy(im,d,c), ssim_index_noisy(im,d,c), qilv_index_noisy(im,d,c), naqi_index_noisy(im,d,c), psnr_index_noisy(im,d,c), cpbd_index_noisy(im,d,c), haarpsi_index_noisy(im,d,c)] = metrics_calc(phanVCT_L(:,:,c), mask_VCT, img_noisy_Red(:,:,:,c), img_noisy_100pcrt(:,:,:,c));
                end
            end
        end
    end
end