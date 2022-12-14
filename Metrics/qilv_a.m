function ind=qilv(I,I2,Ws,mask_VCT)
% QILV() 
%==================================================================
% Quality Index based on Local Variance
% Santiago Aja-Fernandez
%
% santi@bwh.harhard.edu
% Accorging to
%
% S. Aja-Fernández, R. San José Estépar, C. Alberola-López and C.F. Westin,
% "Image quality assessment based on local variance", EMBC 2006, 
% New York, Sept. 2006.
%
%------------------------------------------------------------------
%
% The function calculates a global compatibility measure
% between two images, based on their local variance distribution.
%
%------------------------------------------------------------------
%
% INPUT:   (1) I: The first image being compared
%          (2) I2: the second image being compared
%          (3) Ws: window for the estimation of statistics:
%		If Ws=0: default gaussian window
%               If Ws=[M N] MxN square window
%  
%
% OUTPUT:
%          (1) ind: Quality index (between 0 and 1)
%
% Default usage:
%
%   ind=s_correct(I,I2,0);
%
% 
%==================================================================
%the following variables can be added to avoid NaN, but
%usually it is not necessary
% L=4095;%12bits
L=max(I2(:));
K=[0.01 0.03];
C1 = (K(1)*L)^2;
C2 = (K(2)*L)^2;
%C1=0;
%C2=0;

%Window
if Ws==0
	window = fspecial('gaussian', 11, 1.5);
else
	window=ones(Ws);
%     window = fspecial('gaussian', Ws, Ws/7.5);
end
window = window/sum(window(:));

%Local means
M1=filter2(window, I, 'valid');
M2=filter2(window, I2, 'valid');

%Added to crop stencil to fit new size with valid values
edge_h = (size(I,1) - size(M1,1))/2;
edge_w = (size(I,1) - size(M1,1))/2;
%Added to use stencil
stencil = imerode(mask_VCT(edge_h+1:end-edge_h,edge_w+1:end-edge_w),strel('disk',20));
% stencil = mask_VCT(edge_h+1:end-edge_h,edge_w+1:end-edge_w);

%Local Variances
V1 = filter2(window, I.^ 2, 'valid') - M1.^ 2;
V2 = filter2(window, I2.^ 2, 'valid') - M2.^ 2;

%Global statistics:
m1=mean(V1(stencil));
m2=mean(V2(stencil));
s1=std(V1(stencil));
s2=std(V2(stencil));
s12=mean2((V1(stencil)-m1).*(V2(stencil)-m2));

%Index
ind1=((2*m1*m2+C1)./(m1.^2+m2.^ 2+C1));
ind2=(2*s1*s2+C2)./(s1.^ 2+s2.^ 2+C2);
ind3=(s12+C2/2)./(s1*s2+C2/2);
ind=ind1.*ind2.*ind3;
