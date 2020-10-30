function out = FirstOrderMomentDStatistic(X1,X2,t)
% function to test first order differences (difference between averages) between shape samples X1 and X2
% X1 = N by K matrix, N number of objects in sample 1, K the amount of
% shape landmarks times 3; Therefore Shape landmark data is to be
% vectorized: [Xa Ya Za Xb Yb Zb ... Xz Yz Zz]; for landmarks a to z.
% X2 = M by K matrix, M number of objects in sample 2, K the amount of
% shape landmarks times 3; Therefore Shape landmark data is to be
% vectorized: [Xa Ya Za Xb Yb Zb ... Xz Yz Zz]; for landmarks a to z.
% t = the amount of permutations, best used in combination with matlab parpool and parallel computing.
% if t==0, then permutation testing is ommited.
% 
% out a structure containing the statistical results
%
% Created by Peter Claes, peter.claes@kuleuven.be
% This routine was written for and used in   
% Claes, P., et al. (2012). "Sexual Dimorphism in Multiple Aspects of 3D Facial Symmetry & Asymmetry defined by Spatially-dense Geometric Morphometrics." Journal of Anatomy 221(2): 97-114.
% Claes, P., et al. (2015). "An investigation of matching symmetry in the human pinnae with possible implications for 3D ear recognition and sound localization." Journal of Anatomy 226(1): 60-72.
% Please cite these works when using this function, thank you

         if nargin < 3, t = 0; end
         nX1 = size(X1,1);
         nX2 = size(X2,1);
         % Getting First Order moments & Residus
           AvgX1 = mean(X1);
           AvgX2 = mean(X2);
           ResX1 = X1-repmat(AvgX1,nX1,1);
           ResX2 = X2-repmat(AvgX2,nX2,1);
         % Getting Distance Based Test Statistic
           DStat =  sqrt((AvgX1-AvgX2)*(AvgX1-AvgX2)');
         % Getting within Sample Distance standard deviations 
           s1 = sqrt(sum((sum(ResX1.^2,2)))/(nX1-1));
           s2 = sqrt(sum((sum(ResX2.^2,2)))/(nX2-1));
         % Getting pooled standard deviation
           s = sqrt(((nX1-1)*s1^2+(nX2-1)*s2^2)/(nX1+nX2));
         % Getting Cohen's Distance
           CohenD = DStat/s;
         % generating Effect output  
           out.AvgX1 = AvgX1;
           out.AvgX2 = AvgX2;
           out.Difference = AvgX1-AvgX2;
           out.Dstat = DStat;
           out.s1 = s1;
           out.s2 = s2;
           out.s = s;
           out.CohenD = CohenD;
         % Permutation test  
           if t<=0, return; end
           % generating test-statistic (Euclidean Distance)
           StatCount = false(1,t);
           nT = nX1+nX2;
           X = [X1; X2];
           disp('Permuting');
           parfor i=1:t
                  ind = randperm(nT);
                  X1perm = X(ind(1:nX1),:); %#ok<*PFBNS>
                  X2perm = X(ind(nX1+1:end),:);
                  AvgX1perm = mean(X1perm);
                  AvgX2perm = mean(X2perm);
                  Dperm = sqrt((AvgX1perm-AvgX2perm)*(AvgX1perm-AvgX2perm)');
                  StatCount(i) = Dperm>=DStat;
           end
           out.pperm = (sum(StatCount)+1)/(t+1);           
end