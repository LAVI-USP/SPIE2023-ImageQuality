function [ProjNoisyOffset] = NoiseInsert_GE(phantomVCT,sigmaE,alpha,tau,K,correlation)

if nargin < 6
    correlation = 1;
end

if correlation
    poissonNoise = sqrt(alpha.*phantomVCT) .* gather(imfilter(gpuArray(randn(size(phantomVCT))),K,'symmetric'));
else
    poissonNoise = sqrt(alpha.*phantomVCT) .* randn(size(phantomVCT));
end

electronicNoise = sigmaE .* randn(size(phantomVCT));

imageNoisePoissonGaussian = phantomVCT + poissonNoise + electronicNoise;

ProjNoisyOffset= imageNoisePoissonGaussian + tau;

end

