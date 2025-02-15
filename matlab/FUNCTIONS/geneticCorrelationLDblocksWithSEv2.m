function [GC,pGC,seGC] = geneticCorrelationLDblocksWithSE(CHR,POS,V1,V2,LDblocks,type)
         if nargin<6, type = 'mean';end
         nV1 = size(V1,2);
         nV2 = size(V2,2);
         disp('IDENTIFYING LD BLOCKS');
         LDblockID = getLDblockID(CHR,POS,LDblocks);
         Blocks = setdiff(unique(LDblockID),0);
         nBlocks = length(Blocks);
         v1 = zeros(nBlocks,nV1);
         v2 = zeros(nBlocks,nV2);
         %l2 = zeros(nBlocks,1);
         disp('DIVIDING INTO LD BLOCKS');
         for i=1:1:nBlocks
             switch type
                 case 'mean'
                    v1(i,:) = mean(V1(LDblockID==Blocks(i),:));
                    v2(i,:) = mean(V2(LDblockID==Blocks(i),:));
                 case 'median'
                    v1(i,:) = median(V1(LDblockID==Blocks(i),:));
                    v2(i,:) = median(V2(LDblockID==Blocks(i),:));
                 case 'max'
                    v1(i,:) = max(V1(LDblockID==Blocks(i),:));
                    v2(i,:) = max(V2(LDblockID==Blocks(i),:));
                 otherwise
                    v1(i,:) = mean(V1(LDblockID==Blocks(i),:));
                    v2(i,:) = mean(V2(LDblockID==Blocks(i),:));
             end
             %l2(i) = mean(L2(LDblockID==Blocks(i)));
         end
         GC = zeros(nV1,nV2);
         pGC = ones(nV1,nV2);
         seGC = ones(nV1,nV2);
         disp('COMPUTING PAIRWISE CORRELATIONS');
         [path,ID] = setupParForProgress(nV1);
         parfor i=1:nV1
             % i=1;
             vv1 = v1(:,i);
             forGC = zeros(1,nV2);
             forpGC = ones(1,nV2);
             forseGC = ones(1,nV2);
             for j=1:nV2
                 % j=200; 
                 vv2 = v2(:,j); %#ok<*PFBNS>
                 [forGC(j),forseGC(j),forpGC(j)] = getBootSTATS(vv1(:),vv2(:));
             end
             GC(i,:) = forGC;
             pGC(i,:) = forpGC;
             seGC(i,:) = forseGC;
             parfor_progress;
         end
         closeParForProgress(path,ID)
end
function [stat,se,p] = getBootSTATS(vv1,vv2)
         vv1 = double(vv1);
         vv2 = double(vv2);
         stat = vpa(corr(vv1(:),vv2(:),'type','Spearman'),10000);
         %stat = corr(vv1(:),vv2(:),'type','Pearson');
         n = length(vv1);
         val = zeros(1,100);
         for i=1:100
             index = randsample(n,n,true);
             val(i)= vpa(corr(vv1(index),vv2(index),'type','Spearman'),10000);
             %val(i)= corr(vv1(index),vv2(index),'type','Pearson');
         end
         se = vpa(std(val),10000);
         %p = 2*normcdf(-1*abs(stat/se),0,1);
         p = vpa(normcdf(-1*(stat/se),0,1),10000);      
end