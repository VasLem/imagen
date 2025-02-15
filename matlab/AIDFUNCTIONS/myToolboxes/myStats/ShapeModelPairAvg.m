function [out] = ShapeModelPairAvg(X1,X2,AM,percvar,t)
% This function computed the Directional Procrustes Differences based on
% the averaged of balanced (paired) input arguments X1 & X2;
if nargin < 4, t = 0; end
nX1 = size(X1,1);
% Building Shape model
disp('Building Shape Model');
SM = shapePCA;
SM.RefScan = AM;
getAverage(SM,[X1',X2']);
getModel(SM,[X1',X2']);
stripPercVar(SM,percvar);
CX1 = SM.Tcoeff(1:nX1,:);
CX2 = SM.Tcoeff(nX1+1:end,:);
out.ShapeModel = SM;
out.CX1 = CX1;
out.CX2 = CX2;
% Getting averages and Distances
AvgX1 = mean(CX1);
AvgX2 = mean(CX2);
EDistance = getDistance(SM,AvgX1',AvgX2','euclidean');
MDistance = getDistance(SM,AvgX1',AvgX2','mahalanobis');
out.AvgX1 = AvgX1;
out.AvgX2 = AvgX2;
out.EDistance = EDistance;
out.MDistance = MDistance;
if t<=0, return; end
EDCount = false(1,t);
MDCount = false(1,t);
tic
parfor i=1:t
    r = randi(2,nX1,1);
    X1for = zeros(size(CX1));
    X2for = zeros(size(CX2));
    for k=1:1:nX1
        switch r(k)
            case 1
                X1for(k,:) = CX1(k,:);
                X2for(k,:) = CX2(k,:);
            case 2
                X1for(k,:) = CX2(k,:);
                X2for(k,:) = CX1(k,:);
        end
    end
    AvgX1for = mean(X1for);
    AvgX2for = mean(X2for);
    EDistancefor = getDistance(SM,AvgX1for',AvgX2for','euclidean');
    MDistancefor = getDistance(SM,AvgX1for',AvgX2for','mahalanobis');
    EDCount(i) = EDistancefor >= EDistance;
    MDCount(i) = MDistancefor >= MDistance;
end
disp('Done');
toc;
out.pEDistance = (sum(EDCount)/t);
out.pMDistance = (sum(MDCount)/t);
end