function [ImgL,SimulationInfo] = LesionInsert(img,Contrast,res,saveDicom,ImgAddress,ImgOutput,SimulaInfo)

PathToolkit='LesionInsert\dcmtk-3.6.3-win64-dynamic\bin';
PathIndividualCalcs='LesionInsert\Individual Calcifications';

img=single(img); % Loads image

if ~iscell(SimulaInfo)
    [Mask,PDFMae]=CreateCluster(PathIndividualCalcs); % Creates the cluster (PDFMae just for visual understanding of the position PDF)
    SimulationInfo{1}.Mask=Mask; % Saves simulation info inside a structure for later reference

    %% This makes sure that the cluster is not inserted too close to the skin or
    % too close to the chestwall.
    res.BreastMask(:,end)=0;
    res.BreastMask(:,1)=0;
    ErodedMask=imerode(res.BreastMask, strel('disk',floor(size(Mask,1)/2)));
    CleanDensity=bwmorph(res.DenseMask,'clean');
    PossiblePoints=ErodedMask.*CleanDensity;

    %% This chooses one of the possible coordinates to be the position of
    % the center of the cluster.
    [I J]=find(PossiblePoints==1);
    Poss=[I J];
    Point = datasample(1:size(Poss,1),1,'Replace',false);
    Coordinates=Poss(Point,:);
    SimulationInfo{1}.Coordinates=Coordinates; % Saves simulation info inside a structure for later reference
else
    Mask = SimulaInfo{1}.Mask;
    Coordinates = SimulaInfo{1}.Coordinates;
    SimulationInfo = SimulaInfo;
end

for cc=1:length(Contrast) % This loop will insert the exact same cluster at the exact same location at different contrasts
    
    disp(['Processing lesion contrast ' num2str(cc) ' from ' num2str(length(Contrast))]);
    
    %%
    MaskN=Mask;
    MaskN(Mask~=0)=MaskN(MaskN~=0)*(Contrast(cc));
    MaskN=abs(MaskN-1);
    
    %%
    ImgL(:,:,cc)=img;
    ImgL(Coordinates(1)-ceil(size(Mask,1)/2):Coordinates(1)+floor(size(Mask,1)/2)-1,Coordinates(2)-ceil(size(Mask,1)/2):Coordinates(2)+floor(size(Mask,1)/2)-1,cc)=img(Coordinates(1)-ceil(size(Mask,1)/2):Coordinates(1)+floor(size(Mask,1)/2)-1,Coordinates(2)-ceil(size(Mask,1)/2):Coordinates(2)+floor(size(Mask,1)/2)-1).*MaskN;
    
    PatchOutput = ImgOutput;
    if saveDicom==1
        Address_Original = [ImgAddress];        
%         if ~exist('Address_Original')&&~exist('PatchOutput')
%             disp('Entre o local da imagem:')
%             Address_Original = input('','s');
%             
%             disp('Entre com a pasta para salvar os DICOM´s:')
%             PatchOutput = input('','s');
%         end
        Address_New = [PatchOutput '\Mammo_Lesion_' num2str(100*Contrast(cc)) '.dcm'];
        generateDicom(ImgL(:,:,cc),Address_Original,Address_New,PathToolkit)
    end
    
end

if ~iscell(SimulaInfo)
    save([PatchOutput '\SimulationInfo.mat'],'SimulationInfo')
end

end
