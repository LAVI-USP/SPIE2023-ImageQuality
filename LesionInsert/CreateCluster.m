function [ROI,PDFMae]=CreateCluster(PathIndividualCalcs)

tamCluster = 100;

N=datasample(5:7,1,'Replace',false);
[X,Y,PDFMae]=GeneratePositions(N,tamCluster);

ROI=zeros(tamCluster);
calcs=datasample(1:60,N,'Replace',false);
contrasts=[1 datasample(linspace(.5,1,100),N-1,'Replace',false)];

StackROI=[];

for k=1:N
    Calc=double(imread([PathIndividualCalcs '\Calc' num2str(calcs(k)) '.png']));
    Calc=imresize(Calc,0.7,'bilinear'); % resample 100 microns
    Calc=contrasts(k)*Calc(:,:,1)/max(max(Calc(:,:,1)));
    ROI(1+X(k)-4:X(k)+3,1+Y(k)-4:Y(k)+3)=ROI(1+X(k)-4:X(k)+3,1+Y(k)-4:Y(k)+3)+Calc;
    StackROI=cat(3,StackROI,ROI);
end
