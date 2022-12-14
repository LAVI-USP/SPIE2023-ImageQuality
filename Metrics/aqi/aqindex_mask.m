function [Q,Qn,Rm]=aqindex(X,N,nod,firstangle,angleunits,mode,Mask)
% [Q,Qn,Rm]=aqindex(X,N,nod,firstangle,angleunits,mode)
% Blind Anistropic Quality Index (AQI). 
% Details can be found in: S. Gabarda and G. Cristóbal, “Blind Image 
% quality assessment through anisotropy”, Journal of the Optical Society 
% of America, Vol. 24, No. 12, 2007, pp. B42-B51.
% This measure discriminates sharp noise free images from distorted images
% Inputs:
% X: color or gray-scale image as double precission matrix
% N: window size in pixels (2, 4, 6, 8, ...) (even number)
% nod: number of directions (1, 2, 3, ...)
% firstangle: set the first orientation in degrees or radians. 
% angleunits: 'degree' or 'radian'
% mode: 'gray' or 'color'
% Outputs: 
% (Note that Q and Qn are single or multiple upon solutions are selected
% for gray or color images with the mode option
% Q: AQI
% Qn: normalized AQI
% Rm: expected value of directional image entropy

% By Salvador Gabarda
% Last updated: 30OCT2015
% salvador.gabarda@gmail.com

[ro co la]=size(X);
angleerror=0;

switch mode
    case 'gray'
        X=round(sum(X,3)./la);
    case 'color'
        % no action
end

[ro co la]=size(X);
        
if isequal(angleunits,'radian')
        firstangle=rad2deg(firstangle);
    elseif isequal(angleunits,'degree')
        % no action taken
    else
        disp('unknown unit')
        angleerror=1;
end

dang=180/nod;

for k=1:nod
    if angleerror==1
        break
    end
    ang=(k-1)*dang;
    
    for q=1:la
        Y=orlaon(X(:,:,q),N/2);
        W=localwigner(Y,N,firstangle+ang,'degree');
        R=renyientropy(W);
        R=orlaoff(R,N/2);
        entropy(k,q)=mean(R(Mask)); % image entropy for dir k channel q (R,G,B)
    end
end

% standard deviation of entropy 
Q=std(entropy,1); 
        
% normalized index
Rm=mean(entropy,1); % expected value for entropy in channel q
Qn=Q./Rm;  
       

end

function Y=orlaon(X,p)

[ro co]=size(X);
Xup=X(1:p,:);
Xup=flipud(Xup);
Xbu=X(ro-p+1:ro,:);
Xbu=flipud(Xbu);
Xp=[Xup;X;Xbu];
Xle=Xp(:,1:p);
Xle=fliplr(Xle);
Xri=Xp(:,co-p+1:co);
Xri=fliplr(Xri);
Y=[Xle Xp Xri];

end

function Y=orlaoff(X,n)

[ro co]=size(X);
Y=X(n+1:ro-n,n+1:co-n);

end


   

   