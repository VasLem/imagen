classdef SNPv3 < superClassSNP
   % General Properties
   properties
      RS = [];
      GT = [];
      TestInd = 0;
   end
   properties (Dependent = true)
      nrAA;
      nrAB;
      nrBB;
      Label;
      FFold;
      FPFold;
      ParFold;
      F;
      FP;
      FPar;
      GFold;
      GPFold;
      Folds;
   end
   properties 
      EvalEER = [];
      EvalpEER = [];
      EvalG = [];
      EvalpG = [];
      EvalR = [];
      EvalpR = [];
      EvalFishEER = 1;
      EvalFishG = 1;
      EvalFishR = 1;
   end
   properties (Hidden = true, Dependent = true)
      Balances;
      AAind;
      ABind;
      BBind;
   end
   properties (Hidden = true)
      RegRuns = 50; % Number of Regression runs (SNPBRIM)
      RegSampling = true;% Bootstrap/None (SNPBRIM)
      RegBalance = true; % balance the data yes or no (SNPBRIM)
      RegBalanceTH = 0.4; % desired balance factor (SNPBRIM)
      RegBalanceMethod = 'UpSample'; % UpSample/DownSample/ADASYN (SNPBRIM)
      OuterFold = 8; % number of Outer Folds (SNPBRIM)
      InnerFold = 10; % number of Inner Folds (SNPBRIM)
      UseRedShape = true; % Use reduced space or covariates (SNPBRIM)
      MaxIterations = 5; % Maximum number of BRIM iterations (SNPBRIM)
      Htest = true; % Perform Wilcoxon test om partial regression coefficients (SNPBRIM)
      RIPNormalize = true; % normalize RIP values based on group averages (SNPBRIM)
      StopCorr = 0.98; % Stopping correlation between subsequent iterations (SNPBRIM)
      RIPStatPerm = 1000; % Number of permutations in testing significance of RIP values (SNPBRIM)
      GroupDef = 'GT';% Definition of groups, GG = according to Test performed, GT = according to orginal genotypes (SNPBRIM)
      RedShape = false;
      MOD = [];
   end
   methods % CONSTRUCTOR
        function obj = SNPv3(varargin)
            obj = obj@superClassSNP(varargin{:});         
        end
   end
   methods % GETTING/SETTING
       function out = get.AAind(obj)
           if isempty(obj.GT), out = []; return; end
           out = find(obj.GT==-1);
       end
       function out = get.ABind(obj)
           if isempty(obj.GT), out = []; return; end
           out = find(obj.GT==0);
       end
       function out = get.BBind(obj)
           if isempty(obj.GT), out = []; return; end
           out = find(obj.GT==1);
       end
       function out = get.nrAA(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.AAind);
       end
       function out = get.nrAB(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.ABind);
       end
       function out = get.nrBB(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.BBind);
       end
       function out = get.Balances(obj)
           out = zeros(1,6);
           if isempty(obj.GT), return; end
           out(1) = SNPv3.getBalance(obj.nrAA+obj.nrAB,obj.nrBB);% Recessive
           out(2) = SNPv3.getBalance(obj.nrBB+obj.nrAB,obj.nrAA);% Dominant
           out(3) = SNPv3.getBalance(obj.nrAA+obj.nrBB,obj.nrAB);% Over Dominant
           out(4) = SNPv3.getBalance(obj.nrAA,obj.nrBB);% AA versus BB
           out(5) = SNPv3.getBalance(obj.nrAA,obj.nrAB);% AA versus AB
           out(6) = SNPv3.getBalance(obj.nrAB,obj.nrBB);% AB versus BB
       end
       function out = get.Label(obj)
           switch obj.TestInd
               case 0
                   out = 'NO EFFECT';
               case 1
                   out = 'RECESSIVE';
               case 2
                   out = 'DOMINANT';
               case 3
                   out = 'OVER DOMINANT';
               case 4
                   out = 'ADDITIVE';
               case 5
                   out = 'AA BB';
               case 6
                   out = 'AA AB';
               case 7
                   out = 'AB BB';
               case 8
                   out = 'NON ADDITIVE';
               case 9
                   out = 'ADDITIVE AA AB';
               case 10
                   out = 'ADDITIEVE AB BB';    
           end
       end
       function out = get.FFold(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FoldF;
       end
       function out = get.FPFold(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FoldFP;
       end
       function out = get.ParFold(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FoldFPar;
       end
       function out = get.F(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.F;
       end
       function out = get.FP(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FP;
       end
       function out = get.FPar(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FPar;
       end
       function out = get.GFold(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FoldG;
       end
       function out = get.Folds(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.Folds;
       end
       function out = get.GPFold(obj)
           if isempty(obj.MOD), out = []; return; end
           out = obj.MOD.FoldGP;
       end
   end
   methods % MODEL BUILDING
       function out = dataCheck(obj,MinSampleSize)
           if nargin<2, MinSampleSize = 10;end
           AAOk = obj.nrAA>=MinSampleSize;
           ABOk = obj.nrAB>=MinSampleSize;
           BBOk = obj.nrBB>=MinSampleSize;
           switch obj.TestInd
               case 0
                   out = false;
               case {1 2 3 4} % All three groups required
                   out = AAOk&ABOk&BBOk;
               case 5 % test 4: AA BB
                   out = AAOk&BBOk;
               case 6 % test 5: AA AB
                   out = AAOk&ABOk;
               case 7 % test 6: AB BB
                   out = ABOk&BBOk;
               otherwise
                   error('Wrong Test Index');
           end
       end
       function [LocD,LocP] = locationTest(obj,t,DepVar)
           GG = getGG(obj,obj.TestInd);
           if ~(obj.TestInd==4)
              [LocD,LocP] = SNPv3.DStatTest(DepVar(GG==-1,:),DepVar(GG==1,:),t); 
           else
              [LocD,LocP] = SNPv3.FStatTest(DepVar(GG==-1,:),DepVar(GG==0,:),DepVar(GG==1,:),t);
           end
       end
       function build(obj,BaseCont)
                % Run SNPv3BRIM
                 obj.MOD = SNPv3BRIM(obj,BaseCont.DepVar,[BaseCont.CovRIP, BaseCont.GBRIP]);
                 obj.MOD = rmfield(obj.MOD,{'DepVar' 'IndVar','Grp','H'});
               % Setting up reference scan 
                 RIPref = SNPv3.updateRIP(BaseCont.ST4Ref.Coeff,obj.MOD.M);
                 RIPref = SNPv3.normalizeRIP(RIPref,obj.MOD.M,obj.MOD.Var);
                 obj.MOD.RIPRef = RIPref;
               % Retrieving GT Info and statistics
                 [obj.MOD.GTInfo,obj.MOD.Freq] = SNPv3.getGTInfo(obj.TestInd,obj.MOD.GG,obj.MOD.RIP);
                 for i=1:1:obj.OuterFold
                     [obj.MOD.Folds{i}.GTInfo,obj.MOD.Folds{i}.Freq] = SNPv3.getGTInfo(obj.TestInd,obj.MOD.Folds{i}.GG,obj.MOD.Folds{i}.RIP');
                     [obj.MOD.Folds{i}.TrGTInfo,obj.MOD.Folds{i}.TrFreq] = SNPv3.getGTInfo(obj.TestInd,obj.MOD.Folds{i}.TrGG,obj.MOD.Folds{i}.TrRIP');
                 end  
       end
       function out = SNPv3BRIM(obj,DepVar,Cov)
           % To bootstrap or not to bootstrap that is the question
              Bootstrap = true;if obj.MaxIterations == 0, Bootstrap = false;end
           % Defining Group Memberhip
              GG = getGG(obj,obj.TestInd); 
              ind = find(~isnan(GG));GG = GG(ind);
              switch obj.GroupDef
                  case 'GG' % Group membership is defined by the test performed
                      GM = GG;
                  case 'GT' % Group membership is defined by the original genotypes
                      GM = obj.GT(ind);
              end
              out.UsedInd = ind;% store the samples used
              out.GG = GG;out.GM = GM;
           % Defining Independent and Dependent Variables
              DepVar = DepVar(ind,:);
              if isempty(Cov);
                 IndVar = GG;
              else
                 IndVar = [Cov(ind,:) GG];
              end
              out.DepVar = DepVar;out.IndVar = IndVar;
            % Defining test variable info
              var.El = unique(GG);var.nrEl = length(var.El);
              var.Booting = size(IndVar,2);var.nr2Boot = 1;
              var.Mel = min(var.El);var.Pel = max(var.El);var.Range = var.Pel-var.Mel;
              var.Mindex = find(GG==var.Mel);var.MDepVar = mean(DepVar(var.Mindex,:)); %#ok<*FNDSB>
              var.Pindex = find(GG==var.Pel);var.PDepVar = mean(DepVar(var.Pindex,:));
              var.nrWEl = zeros(1,var.nrEl);
              for i=1:1:var.nrEl
                  var.nrWEl(i) = length(find(GG==var.El(i)));
              end
              [~,tmp] = min(var.nrWEl);var.PosClass = var.El(tmp);% needed for ROC analysis (minority group definition)
              out.Var = var;
            % Defining group info
              grp.El = unique(GM);grp.nrEl = length(grp.El);
              out.Grp = grp;
              [n,dim] = size(DepVar);
            % Outer Partitioning of Data
              Fouter = DOB_SCV(obj.OuterFold,DepVar,GM);
              FoldResults = cell(1,obj.OuterFold);
              for fo=1:obj.OuterFold
                 % Extracting training and testing 
                  FoTestInd = find(Fouter==fo);FoTrInd = setdiff((1:n),FoTestInd);nrFoTr = length(FoTrInd);
                  FoldResults{fo}.TestInd = FoTestInd;
                  FoldResults{fo}.TrInd = FoTrInd;
                  FoTrIndVar = IndVar(FoTrInd,:);FoTrDepVar = DepVar(FoTrInd,:);FoTrGM = GM(FoTrInd);
                  FoldResults{fo}.GG = IndVar(FoTestInd,end);% Only keeping origninal GG
                  FoldResults{fo}.TrGG = IndVar(FoTrInd,end);
                  FoTestDepVar = DepVar(FoTestInd,:);
                  %FoldResults{fo}.DepVar = FoTestDepVar;
                  BootProgress = zeros(1,obj.MaxIterations);
                 % Initialize Bootstrapping
                  %FoldResults{fo}.UpSampled = zeros(1,grp.nrEl);
                  ContBoot = true;counter = 0;
                  while ContBoot && Bootstrap>0
                    % Keeping track of iterations  
                     counter = counter + 1; 
                   % seperate data into inner folds
                     Finner = DOB_SCV(obj.InnerFold,FoTrDepVar,FoTrGM);
                     TMPIndVar = FoTrIndVar(:,end);% Allocate Memory, only last collumn for SNP
                     for fi=1:obj.InnerFold % Fi...
                         FiTestInd = find(Finner==fi);
                         FiTrInd = setdiff(1:nrFoTr,FiTestInd);
                         [M,H] = robustPLSRegression(obj,FoTrIndVar(FiTrInd,:),FoTrDepVar(FiTrInd,:),FoTrGM(FiTrInd));% Compute BootSampled Regression
                         if obj.Htest, M = H.*M;end% Only keep significant regression coefficients
                         rip = SNPv3.updateRIP(FoTrDepVar(FiTestInd,:),M)';% Get RIP scores
                         if obj.RIPNormalize, rip = SNPv3.normalizeRIP(rip,M,var);end% rescale RIP scores
                         TMPIndVar(FiTestInd) = rip;% Store updated RIP scores, always in the last collumn
                     end
                   % monitoring progress of Booting
                     tmpC = corrcoef(FoTrIndVar(:,end),TMPIndVar);
                     BootProgress(counter) = tmpC(1,2);
                     if BootProgress(counter)>=obj.StopCorr, ContBoot = false; end
                     if counter >= obj.MaxIterations, ContBoot = false; end
                     FoTrIndVar(:,end) = TMPIndVar;% Update Training IndVar for next round
                  end
                  %if counter>0, FoldResults{fo}.BootProgress = BootProgress(1:counter);end
                  %FoldResults{fo}.BootIter = counter;
                 % Extracting final M from outer training data
                  [M,H] = robustPLSRegression(obj,FoTrIndVar,FoTrDepVar,FoTrGM);
                  if obj.Htest, M = H.*M;end
                  FoldResults{fo}.M = M;FoldResults{fo}.H = H;
                 % Evaluate outer test data
                  rip = updateRIP(FoTestDepVar,M)';% Get RIP Scores Test partition 
                  if obj.RIPNormalize, rip = SNPv3.normalizeRIP(rip,M,var);end% rescale RIP scores
                  FoldResults{fo}.RIP = rip;
                  [FoldResults{fo}.F,FoldResults{fo}.FP,FoldResults{fo}.FPar,FoldResults{fo}.G,FoldResults{fo}.GP,~] = SNPv3.performRIPStat(FoldResults{fo}.GG,FoldResults{fo}.RIP,var,obj.RIPStatPerm);
                  rip = updateRIP(FoTrDepVar,M)';% Get RIP Scores training partition
                  if obj.RIPNormalize, rip = SNPv3.normalizeRIP(rip,M,var);end% rescale RIP scores
                  FoldResults{fo}.TrRIP = rip;
              end
             % Gathering Fold Results
               FoldF = zeros(1,obj.OuterFold);
               FoldFP = zeros(1,obj.OuterFold);
               FoldFPar = zeros(1,obj.OuterFold);
               FoldG = zeros(1,obj.OuterFold);
               FoldGP = zeros(1,obj.OuterFold);
               Folds = cell(1,obj.OuterFold);
               M = zeros(obj.OuterFold,dim);
               for fo=1:obj.OuterFold
                   FoldF(fo) = FoldResults{fo}.F;FoldFP(fo) = FoldResults{fo}.FP;FoldFPar(fo) = FoldResults{fo}.FPar;
                   FoldG(fo) = FoldResults{fo}.G;FoldGP(fo) = FoldResults{fo}.GP;M(fo,:) = FoldResults{fo}.M;
                   Folds{fo}.M = FoldResults{fo}.M;Folds{fo}.GG = FoldResults{fo}.GG;Folds{fo}.RIP = FoldResults{fo}.RIP;
                   Folds{fo}.TestInd = FoldResults{fo}.TestInd;Folds{fo}.TrGG = FoldResults{fo}.TrGG;Folds{fo}.TrRIP = FoldResults{fo}.TrRIP;
               end
               out.F = nanmean(FoldF);
               out.G = nanmean(FoldG);
               out.FPar = nan;
               index = find(~isnan(FoldFPar)); %#ok<*EFIND>
               if ~isempty(index), out.FPar = SNPv3.pfast(FoldFPar); end
               out.FP = nan;
               out.GP = nan;
               if obj.RIPStatPerm>0
                  FoldFP(FoldFP==0) = 0.1/obj.RIPStatPerm;
                  index = find(~isnan(FoldFP));
                  if ~isempty(index), out.FP = SNPv3.pfast(FoldFP(index)); end
                  FoldGP(FoldGP==0) = 0.1/obj.RIPStatPerm;
                  index = find(~isnan(FoldGP));
                  if ~isempty(index), out.GP = SNPv3.pfast(FoldGP(index)); end
               end
               out.FoldF = FoldF;
               out.FoldG = FoldG;
               out.FoldFPar = FoldFPar;
               out.FoldFP = FoldFP;
               out.FoldGP = FoldGP;
               out.Folds = Folds;
              % Extracting final M 
               out.M = median(M);
               if ~obj.Htest, return; end
               if obj.OuterFold>=8, 
                  out.H = SNPv3.wilcoxonM(M);
               else
                  out.H = ones(1,dim); 
               end
               out.M = out.H.*out.M;
               RIP = SNPv3.updateRIP(DepVar,out.M);
               RIP = SNPv3.normalizeRIP(RIP,out.M,var);
               out.RIP = RIP;
               [out.RIPF,out.RIPFP,out.RIPFPar,out.RIPG,out.RIPGP,~] = SNPv3.performRIPStat(out.GG,RIP,var,0);
              % Obtaining regressions to contruct morphs
               %IndVar = [Cov(out.UsedInd,:) RIP'];
               %[out.MMorphs,out.MIMorphs,~] = getRegression(IndVar,DepVar,(1:size(IndVar,2)));   
       end
       function [M,H,Mfor] = robustPLSRegression(obj,indvar,depvar,gg)
           % initialize
             sampling = obj.RegSampling;runs = obj.RegRuns;balance = obj.RegBalance;% only read once
             if runs==1, sampling = false; end% in a single run no point in sampling
             if balance % determine group memberships and balances, within test such that not executed when not necessary
                balanceTH = obj.RegBalanceTH;balanceMethod = obj.RegBalanceMethod;
                labgg = unique(gg);nrgg = length(labgg);% group labels
                indgg = cell(1,nrgg);nrwgg = zeros(1,nrgg);
                for i=1:1:nrgg
                    indgg{i} = find(gg==labgg(i));
                    nrwgg(i) = length(indgg{i});
                end
                [nrM,indM] = max(nrwgg);% Majority class
                indm = setdiff(1:nrgg,indM);nrm = nrwgg(indm);% minority class(es)
                nrmgg = length(indm);dcrit = zeros(1,nrmgg);nrSyn = zeros(1,nrmgg);nrKeep = nrM;% Initialze minority classes
                for i=1:1:nrmgg
                    dcrit(i) = nrm(i)/nrM;
                    if dcrit(i)>=balanceTH; continue; end
                    nrSyn(i) = (nrM-nrm(i))*balanceTH;% UpSampling
                    nrKeep = min(nrKeep,round(nrm(i)/balanceTH));% DownSampling
                end
                balInfo = cell(1,nrgg);
                for i=1:1:nrgg % gathering information to be used during runs
                    Info.Ind = indgg{i};
                    switch balanceMethod
                        case 'DownSample'
                            Info.nrKeep = nrKeep;
                            if i==1, upsampling = false; end
                        case {'UpSample' 'ADASYN'}
                            if i==1, upsampling = true; end
                            if i==indM
                                Info.nrSyn = 0;
                            else
                                K = 10;% number of closest neighbors
                                subind = find(indm==i);
                                Info.nrSyn = round(nrSyn(subind));
                                if Info.nrSyn>0
                                    tmpindm = indgg{indm(subind)};
                                   % within group K closest neighbors
                                    distances = squareform(pdist(depvar(tmpindm,:)));
                                    [~,index] = sort(distances,'ascend');
                                    mK = min(length(tmpindm)-1,K);% it is possible that you do not have enough samples
                                    index = index(2:mK+1,:);
                                    Info.SampleIndB = index;
                                    Info.K = mK;
                                   % establishing sampling distribution
                                    if strcmp(balanceMethod,'UpSample')
                                      % all within sample are equally likely to be chosen
                                        Info.SampleInd = 1:length(tmpindm);
                                    else
                                      % samples closer to other group members get higher weigths (ADASYN) 
                                        tmpindM = indgg{indM};
                                        for j=1:1:nrmgg
                                            if j==subind; continue; end
                                            tmpindM = [tmpindM; indgg{indm(j)}];
                                        end
                                      % between group K closest neighbors
                                        distances = pdist2(depvar(tmpindm,:),depvar);
                                        [~,index] = sort(distances','ascend'); %#ok<UDIM>
                                        index = index(2:K+1,:); % probably no K problem
                                        r = ismember(index,tmpindM);r = sum(r)/K;r = r/sum(r);
                                        g = round(r*nrSyn(subind));totg = sum(g);
                                        if totg==0, g = ones(1,length(tmpindm)); totg = length(tmpindm); end % perfectly seperatable groups
                                        index = zeros(1,totg);
                                        counter = 1;
                                        for j=1:1:length(g)
                                            if g(j)==0, continue; end
                                            for k=1:1:g(j)
                                                index(counter) = j;
                                                counter = counter +1;
                                            end
                                        end
                                        Info.SampleInd = index;
                                    end
                                end
                            end
                    end
                    balInfo{i} = Info;
                end
             end
             nrD = size(depvar,2);Mfor = zeros(runs,nrD);
           % execute runs
             for s=1:1:runs
                 if balance % Balance the given input
                    if upsampling % Balancing by Increasing Minority Groups
                        SampleIndVar = indvar;SampleDepVar = depvar;
                        for i=1:1:nrgg
                            if balInfo{i}.nrSyn==0, continue; end
                            [DepVarNew,IndVarNew] = SNPv3.regUpSample(depvar(balInfo{i}.Ind,:),indvar(balInfo{i}.Ind,:),balInfo{i});
                            SampleDepVar = [SampleDepVar; DepVarNew]; %#ok<*AGROW>
                            SampleIndVar = [SampleIndVar; IndVarNew];
                        end
                    else % Balancing by Decreasing Majority Groups
                        SampleIndVar = [];SampleDepVar = [];
                        for i=1:1:nrgg
                            [DepVarNew,IndVarNew] = SNPv3.regDownSample(depvar(balInfo{i}.Ind,:),indvar(balInfo{i}.Ind,:),balInfo{i}.nrKeep);
                            SampleDepVar = [SampleDepVar; DepVarNew];
                            SampleIndVar = [SampleIndVar; IndVarNew];
                        end
                    end
                 else % No Balancing
                     SampleIndVar = indvar;SampleDepVar = depvar;
                 end
                 nrS = size(SampleIndVar,1);
                 if sampling % Bootstrap Sampling of given input
                    SampleInd = randsample(nrS,nrS,true);
                 else
                    SampleInd = 1:nrS;
                 end
                 Mfor(s,:) = SNPv3.getRegression(SampleIndVar(SampleInd,:),SampleDepVar(SampleInd,:));
             end
           % finalizing output
             if ~obj.Htest, H=ones(1,nrD);return; end
             if runs==1, H=ones(1,nrD); return; end
             M = median(Mfor); % extract the median of all regression coefficients
             if nargout<2, return; end
             H = SNPv3.wilcoxonM(Mfor);% wilcoxon test for median
       end
       function out = getGG(obj,TestInd)
           out = obj.GT;% Initialize
           switch TestInd
               case 0 % NO EFFECT
                   out = nan*out;
               case 1 % test 1: AAAB BB (RECESSIVE)
                   out(union(obj.AAind,obj.ABind)) = -1;
                   out(obj.BBind) = 1;
               case 2 % test 2: AA ABBB (DOMINANT)
                   out(obj.AAind) = -1;
                   out(union(obj.BBind,obj.ABind)) = 1;
               case 3 % test 3: AABB AB (OVER DOMINANT)
                   out(union(obj.AAind,obj.BBind)) = -1;
                   out(obj.ABind) = 1;
               case 4 % test 7 AA AB BB (ADDITIVE)
                   return;
               case 5 % test 4: AA BB
                   out(obj.ABind) = nan;
               case 6 % test 5: AA AB
                   out(obj.ABind) = 1;
                   out(obj.BBind) = nan;
               case 7 % test 6: AB BB
                   out(obj.ABind) = -1;
                   out(obj.AAind) = nan;
               case 8 % NON ADDITIVE
                   return;
               case 9 % ADDITIVE AA AB
                   out(obj.AAind) = -1;
                   out(obj.BBind) = 0;
                   out(obj.ABind) = 1;
               case 10 % ADDITIVE AB BB
                   out(obj.ABind) = -1;
                   out(obj.AAind) = 0;
                   out(obj.BBind) = 1;
           end       
       end
   end
   methods % MODEL EVALUATION
       function foldEvaluation(obj,t)
           nrF = length(obj.Folds);
           obj.EvalEER = nan*zeros(1,nrF);
           obj.EvalpEER = nan*zeros(1,nrF);
           obj.EvalG = nan*zeros(1,nrF);
           obj.EvalpG = nan*zeros(1,nrF);
           obj.EvalR = nan*zeros(1,nrF);
           obj.EvalpR = nan*zeros(1,nrF);
           for f=1:1:nrF
               [obj.EvalEER(f),obj.EvalG(f),obj.EvalR(f),obj.EvalpEER(f),obj.EvalpG(f),obj.EvalpR(f)] = SNPv3.evalQD(obj.Folds{f}.TrGG,obj.Folds{f}.TrRIP,obj.Folds{f}.GG,obj.Folds{f}.RIP,obj.MOD.Var.PosClass,t);
           end
           if t==0, return; end
           obj.EvalpEER(find(obj.EvalpEER==0)) = 0.1/t;
           obj.EvalpG(find(obj.EvalpG==0)) = 0.1/t;
           obj.EvalpR(find(obj.EvalpR==0)) = 0.1/t;
           obj.EvalFishEER = SNPv3.pfast(obj.EvalpEER);
           obj.EvalFishG = SNPv3.pfast(obj.EvalpG);
           obj.EvalFishR = SNPv3.pfast(obj.EvalpR);
       end  
   end
   methods % MODEL APPLICATION
       function [C,Atypicality,scan] = createMorph(obj,BaseCont,genotype,BF,maxAtypicality)
                if nargin<5, maxAtypicality = +inf; end
                if nargin<4, BF = 0; end
                C = []; Atypicality = +inf;scan = [];
                if isempty(obj.MOD), return; end
                switch genotype
                    case -1 % AA
                        GTInfo = obj.MOD.GTInfo{1};
                    case 0  % AB
                        GTInfo = obj.MOD.GTInfo{2};
                    case 1  % BB
                        GTInfo = obj.MOD.GTInfo{3};
                    otherwise
                        return;
                end
                if GTInfo.Nr==0, return; end
                if obj.RedShape
                   Xref = obj.MOD.RIPRef;
                   Yref = BaseCont.Ref.RedCoeff;
                else
                   Yref = BaseCont.Ref.Coeff; 
                   switch BaseCont.RedShapeSpaceType
                        case 'X'
                           Cov = [BaseCont.Ref.AvgCov, BaseCont.Ref.AvgGB];
                        case 'RIP'
                           Cov = [BaseCont.Ref.CovRIP, BaseCont.Ref.GBRIP];
                    end 
                    Xref = [Cov obj.MOD.RIPRef]; 
                end             
                maxcounter = 100;counter = 0;
                while Atypicality>=maxAtypicality && counter<=maxcounter
                      counter = counter+1;
                      X = Xref;X(end) = GTInfo.AVG+GTInfo.Sign*BF*GTInfo.STD;
                      deltaX = X-Xref;dY = deltaX*obj.MOD.MMorphs;
                      C = Yref+dY;
                      Atypicality = sqrt(sum(C.^2));
                      BF = BF-0.01;
                end
                if obj.RedShape
                   ShapeSpace = BaseCont.RedShapeSpace;
                else
                   ShapeSpace = BaseCont.ShapeSpace;
                end
                scan = getScan(ShapeSpace,C);
       end
       function [C,Atypicality,scan] = overLaySNPv3(obj,BaseCont,genotype,Ref,BF,maxAtyp,adjust,TrimBF)
                if nargin<8, TrimBF = 2; end
                if nargin<7, adjust = 'no'; end
                if nargin<6, maxAtyp = +inf; end
                if nargin<5, BF = 0; end
                if nargin<4, Ref.Coeff = BaseCont.Ref.Coeff; Ref.Cov = [BaseCont.Ref.CovRIP, BaseCont.Ref.GBRIP];end
                C = []; Atypicality = 0;scan = [];
                if isempty(obj.MOD), return; end
                switch genotype
                    case -1 % AA
                        GTInfo = obj.MOD.GTInfo{1};
                    case 0  % AB
                        GTInfo = obj.MOD.GTInfo{2};
                    case 1  % BB
                        GTInfo = obj.MOD.GTInfo{3};
                    otherwise
                        return;
                end
                if GTInfo.Nr==0, return; end
                Xref = SNPv3.updateRIP(Ref.Coeff,obj.MOD.M);
                Xref = SNPv3.normalizeRIP(Xref,obj.MOD.M,obj.MOD.Var);
                Xref = [Ref.Cov Xref];Yref = Ref.Coeff;
                Atypref = sqrt(sum(Ref.Coeff.^2));
                maxcounter = 100;counter = 0;
                AtypIncrease = +inf;
                while AtypIncrease>=maxAtyp && counter<=maxcounter
                      counter = counter+1;
                      X = Xref;X(end) = GTInfo.AVG+GTInfo.Sign*BF*GTInfo.STD;
                      deltaX = X-Xref;dY = deltaX*obj.MOD.MMorphs;
                      C = Yref+dY;
                      Atypicality = sqrt(sum(C.^2));
                      AtypIncrease = Atypicality-Atypref;
                      BF = BF-0.01;
                end
                if nargout < 3, return; end
                if obj.RedShape
                   ShapeSpace = BaseCont.RedShapeSpace;
                else
                   ShapeSpace = BaseCont.ShapeSpace;
                end
                switch lower(adjust);
                    case 'rescale'
                        C = C.*ShapeSpace.EigStd';
                    case 'trim'
                        B = TrimBF*ShapeSpace.EigStd';
                        index = find(abs(C)>B);
                        C(index) = B(index).*sign(C(index));
                    otherwise
                end
                scan = getScan(ShapeSpace,C);   
       end
       function [IB,pTpF,pT] = matchRIP(obj,rip,genotype,BF)
                 n = length(rip);IB = nan*zeros(1,n);
                 if nargout>1, pTpF = nan*zeros(1,n); end
                 if nargout>2, pT = nan*zeros(1,n); end
                 switch genotype
                     case -1
                         GTInfo = obj.MOD.GTInfo{1};
                     case 0
                         GTInfo = obj.MOD.GTInfo{2};
                     case 1
                         GTInfo = obj.MOD.GTInfo{3};
                     otherwise
                         return;
                 end
                 if GTInfo.Nr==0, return; end
                 mu = GTInfo.AVG+GTInfo.Sign*BF*GTInfo.STD;sigma = GTInfo.STD;
                 pT = normpdf(rip,mu,sigma);
                 pTmax = normpdf(mu,mu,sigma);
                 pF = zeros(length(GTInfo.Opp),n);
                 for i=1:1:length(GTInfo.Opp) 
                     OppInfo = obj.MOD.GTInfo{GTInfo.Opp(i)};
                     pF(i,:) = normpdf(rip,OppInfo.AVG,OppInfo.STD);
                 end
                 if size(pF,1)==1,
                    IB = pT./(pT+pF);
                    pTpF = pT./pF;
                 else
                    %IB = ((pT./(pT+pF(1,:)))+(pT./(pT+pF(2,:))))/2;
                    %pTpF = ((pT./pF(1,:)).*(pT./pF(2,:)));
                    pF = sum(pF);
                    %pF = pF(1,:).*pF(2,:);
                    IB = pT./(pT+pF);
                    pTpF = (2*pT)./pF;
                    %pTpF = (pT.^2)./(pF(1,:).*pF(2,:));
                 end
                 pT = pT./pTmax;
                 %pTIB = pT.*IB;
                 %if size(pF,1)>1, pF = sum(pF);end
                 %IB = pT./(pT+pF);
                 %pTpF = pT./pF;
                 %pT = pT./pTmax; 
       end
       function [IB,pFpT] = inversematchRIP(obj,rip,genotype,BF)
                 n = length(rip);IB = nan*zeros(1,n);pFpT = nan*zeros(1,n);
                 %if nargout>1, pTIB = nan*zeros(1,n); end
                 %if nargout>2, pT = nan*zeros(1,n); end
                 switch genotype
                     case -1
                         GTInfo = obj.MOD.GTInfo{1};
                     case 0
                         GTInfo = obj.MOD.GTInfo{2};
                     case 1
                         GTInfo = obj.MOD.GTInfo{3};
                     otherwise
                         return;
                 end
                 if GTInfo.Nr==0, return; end
                 mu = GTInfo.AVG+GTInfo.Sign*BF*GTInfo.STD;sigma = GTInfo.STD;
                 pT = normpdf(rip,mu,sigma);
                 %pTmax = normpdf(mu,mu,sigma);
                 pF = zeros(length(GTInfo.Opp),n);
                 for i=1:1:length(GTInfo.Opp) 
                     OppInfo = obj.MOD.GTInfo{GTInfo.Opp(i)};
                     pF(i,:) = normpdf(rip,OppInfo.AVG,OppInfo.STD);
                 end
                 npF = size(pF,1);
                 if npF==1, IB = pF./(pT+pF); return; end
                 IB = zeros(1,npF);
                 pFpT = zeros(1,npF);
                 indpF = (1:npF);
                 for i=1:1:npF
                     IB(i) = pF(i,:)./(pT+pF(i,:)+pF(setdiff(indpF,i),:));
                     pFpT(i) = pF(i,:)./pT;
                 end
                 IB = mean(IB);
                 pFpT = mean(pFpT);
                 %if size(pF,1)>1, pF = sum(pF);end
                 %IB = pF./(pT+pF);
                 %if nargout==1, return; end
                 %pT = pF./pFmax;
                 %pTIB = pF.*IB;
       end
       function [IB,pTIB,pT] = matchFaces(obj,faces,genotype,BF)
                rip = SNPv3.updateRIP(faces,obj.MOD.M);
                rip = SNPv3.normalizeRIP(rip,obj.MOD.M,obj.MOD.Var);
                [IB,pTIB,pT] = matchRIP(obj,rip,genotype,BF);
                %if nargout == 1, IB = matchRIP(obj,rip,genotype,BF); return; end
                %if nargout == 2, [IB,pTIB] = matchRIP(obj,rip,genotype,BF); return; end
                %if nargout == 3, [IB,pTIB,pT] = matchRIP(obj,rip,genotype,BF); end
       end
       function [class] = classifyRIP(obj,rip)
                n = length(rip); class = nan*ones(1,n);
                if obj.MOD.Var.nrEl==3, return; end % cannot classify
                rip = rip*obj.MOD.Var.PosClass;
                class = -1*ones(1,n);
                class(rip > obj.MOD.RIPGT) = 1;
                class = class*obj.MOD.Var.PosClass;
       end
       function [out1,out2] = classifyErrorRIP(obj,rip,genotype,BF,T)
                IB = matchRIP(obj,rip,genotype,BF);
                out1 = zeros(size(IB));
                out1(IB<T) = 1;
                out2 = IB;out2(IB>=T) = 1;
       end
       function out = illustrateModel(obj,BF)
           disp([obj.RS '  Valid:' num2str(obj.ST3Valid)]);
           disp('   ');
           disp(obj.Label);
           disp('   ');
           disp(['Atyp: ' num2str(obj.MOD.Atyps) '  Balance:' num2str(obj.MOD.BalAtyp)]);
           disp('   ');
           disp(['G: ' num2str(obj.MOD.RIPG)  '  GT: '  num2str(obj.MOD.RIPGT)]);
           disp('   ');
           disp(['FP: ' num2str(obj.MOD.FP)  '  GP: '  num2str(obj.MOD.GP)]);
           disp('   ');
           disp(num2str([obj.nrAA obj.nrAB obj.nrBB]));
           disp('   ');
           rip = min(obj.MOD.RIP):0.01:max(obj.MOD.RIP);
           M = zeros(1,3);Mrip = zeros(1,3);
           gt = [-1 0 1];
           f1 = figure;hold on;
           plot(rip,0.5*ones(size(rip)),'k-');
           %data = zeros(3,4);
           for i=1:1:3
               if obj.MOD.GTInfo{i}.Nr == 0, disp(['NO ' num2str(gt(i))]); continue; end
               [score] = matchRIP(obj,rip,gt(i),BF);
               plot(f1.CurrentAxes,rip,score);
               [M(1,i),ind] = min(score);Mrip(1,i) = rip(ind);
               %[score] = matchRIP(obj,obj.MOD.GTInfo{i}.MED.mu,gt(i),BF);
               %data(i,1) = obj.MOD.GTInfo{i}.MED.mu;
               %data(i,2) = obj.MOD.GTInfo{i}.MAD.mu;
               %data(i,3) = obj.MOD.GTInfo{i}.MED.mu+obj.MOD.GTInfo{i}.Sign*obj.MOD.GTInfo{i}.MAD.mu;
               %data(i,4) = score;
               %scan = obj.MOD.GTInfo{i}.Morph;
               %color = 0.6*ones(1,3);color(i) = 0.8;
               %scan.SingleColor = color;scan.Material = 'Dull';
               %v = viewer(obj.MOD.GTInfo{i}.Morph);
               %v.SceneLightVisible = true;v.SceneLightLinked = true;
           end
           %obj.Ref.Scan.ColorMode = 'Indexed';v = viewer(obj.Ref.Scan);
           %obj.Ref.Scan.Material = 'Dull';
           %v.SceneLightVisible = true;v.SceneLightLinked = true;
           %disp(num2str([M; Mrip]));
           %disp('   ');
           %disp(num2str(data));
           %disp('   ');
           out.M = M;out.Mrip = Mrip;
           out.Atyp = obj.MOD.Atyps;
           out.G = obj.MOD.RIPG;
       end
       function [freq,occ] = GTTypicality(obj,genotype)
           total = obj.nrAA+obj.nrAB+obj.nrBB;
           switch genotype
               case -1
                   occ = (obj.nrAA/total);
                   %atyp = obj.MOD.Atyps(1);
                   freq = obj.MOD.Freq(1);
               case 0
                   occ = (obj.nrAB/total);
                   %atyp = obj.MOD.Atyps(2);
                   freq = obj.MOD.Freq(2);
               case 1
                   occ = (obj.nrBB/total);
                   %atyp = obj.MOD.Atyps(3);
                   freq = obj.MOD.Freq(3);
               otherwise
                   occ = nan;
                   %atyp = nan;
                   freq = nan;
           end
           if freq==0, freq = nan; end
           %matyp = atyp==obj.MOD.MAtyp;
       end
       function [RIP,Distr] = GT2RIP(obj,genotype)
                 RIP = nan;Distr = cell(1,1);
                 if isempty(obj.MOD), return; end
                 switch genotype
                     case -1
                         Info = obj.MOD.GTInfo{1};
                     case 0
                         Info = obj.MOD.GTInfo{2};
                     case 1
                         Info = obj.MOD.GTInfo{3};
                     otherwise
                         return;
                 end
                 if Info.Nr==0, return; end
                 RIP = Info.AVG;
                 Distr{1}.mu = Info.AVG;
                 Distr{1}.sigma = Info.STD;
       end
       function updateGTDistributions(obj,BaseCont,kappa)
                % Extracting group RIP Statistics  
                 for i=1:1:3
                     obj.MOD.GTInfo{i}.Nr = length(obj.MOD.GTInfo{i}.Ind);
                     if obj.MOD.GTInfo{i}.Nr>0
                        obj.MOD.GTInfo{i}.RIP = obj.MOD.RIP(obj.MOD.GTInfo{i}.Ind);
                        [obj.MOD.GTInfo{i}.AVG,obj.MOD.GTInfo{i}.STD,obj.MOD.GTInfo{i}.MED,obj.MOD.GTInfo{i}.MAD,GTInfo{i}.O] = SNPv3.extractRobustRIPStatistics(obj.MOD.GTInfo{i}.RIP,kappa);                     
                     end
                 end
                % Creating average morphs
                 obj.MOD.Atyps = nan*zeros(1,3);
                 for i=1:1:3
                     if obj.MOD.GTInfo{i}.Nr==0, continue; end
                     [obj.MOD.GTInfo{i}.C,obj.MOD.GTInfo{i}.Atyp,obj.MOD.GTInfo{i}.Morph] = createMorph(obj,BaseCont,obj.MOD.GTInfo{i}.GT,0);
                     obj.MOD.Atyps(i) = obj.MOD.GTInfo{i}.Atyp;
                 end
                % Determination of less typical group
                 obj.MOD.MAtyp = nanmax(obj.MOD.Atyps);
                 obj.MOD.mAtyp = nanmin(obj.MOD.Atyps);
                 obj.MOD.BalAtyp = obj.MOD.mAtyp/obj.MOD.MAtyp;
       end
   end
   methods % INTERFACING     
       function obj = reduceSamples(obj,index)
           if nargout==1, obj = clone(obj); end
           obj.GT = obj.GT(index);
           obj.MOD = [];
       end
       function saveToDisk(obj,suffix)
          save([obj.RS '_' suffix],'obj');           
       end
       function out = getGGExt(obj,in,TestInd)
           out = in;% Initialize
           AAind = find(in==-1);
           ABind = find(in==0);
           BBind = find(in==-1);
           switch TestInd
               case 0 % NO EFFECT
                   out = nan*out;
               case 1 % test 1: AAAB BB (RECESSIVE)
                   out(union(AAind,ABind)) = -1;
                   out(BBind) = 1;
               case 2 % test 2: AA ABBB (DOMINANT)
                   out(AAind) = -1;
                   out(union(BBind,ABind)) = 1;
               case 3 % test 3: AABB AB (OVER DOMINANT)
                   out(union(AAind,BBind)) = -1;
                   out(ABind) = 1;
               case 4 % test 7 AA AB BB (ADDITIVE)
                   return;
               case 5 % test 4: AA BB
                   out(ABind) = nan;
               case 6 % test 5: AA AB
                   out(ABind) = 1;
                   out(BBind) = nan;
               case 7 % test 6: AB BB
                   out(ABind) = -1;
                   out(AAind) = nan;
               case 8 % NON ADDITIVE
                   return;
               case 9 % ADDITIVE AA AB
                   out(AAind) = -1;
                   out(BBind) = 0;
                   out(ABind) = 1;
               case 10 % ADDITIVE AB BB
                   out(ABind) = -1;
                   out(AAind) = 0;
                   out(BBind) = 1;
           end       
       end
   end
   methods (Static = true)
       function [D,P] = DStatTest(X1,X2,t)
         % initializing  
           nX1 = size(X1,1);nX2 = size(X2,1);
         % Getting First Order moments & Residus
           AvgX1 = mean(X1);AvgX2 = mean(X2);
         % Getting Distance Based Test Statistic
           D =  sqrt((AvgX1-AvgX2)*(AvgX1-AvgX2)');
         % Permutation test  
           StatCount = false(1,t);
           nT = nX1+nX2;
           X = [X1; X2];
           parfor i=1:t
                  ind = randperm(nT);
                  X1perm = X(ind(1:nX1),:);X2perm = X(ind(nX1+1:end),:); %#ok<*PFBNS>
                  AvgX1perm = mean(X1perm);AvgX2perm = mean(X2perm);
                  Dperm = sqrt((AvgX1perm-AvgX2perm)*(AvgX1perm-AvgX2perm)');
                  StatCount(i) = Dperm>=D;
           end
           P = sum(StatCount)/t;           
       end
       function [F,P] = FStatTest(X1,X2,X3,t)
         % initializing  
           nX1 = size(X1,1);nX2 = size(X2,1);nX3 = size(X3,1);nX = nX1+nX2+nX3;
           X = [X1;X2;X3];
         % group averages
           AvgX1 = mean(X1);AvgX2 = mean(X2);AvgX3 = mean(X3);AvgX = mean(X);   
         % SSB
           SSB = sum(sum(([AvgX1;AvgX2;AvgX3] - repmat(AvgX,3,1)).^2,2).*[nX1;nX2;nX3])/2;
         % SSW
           SSW = sum([sum((X1-repmat(AvgX1,nX1,1)).^2,2);sum((X2-repmat(AvgX2,nX2,1)).^2,2);sum((X3-repmat(AvgX3,nX3,1)).^2,2)])/(nX-2);
         % F
           F = SSB/SSW;
         % Permutation test  
           StatCount = false(1,t);
           parfor i=1:t
                 % initialize permutation
                  ind = randperm(nX);
                  X1perm = X(ind(1:nX1),:);X2perm = X(ind(nX1+1:nX1+nX2),:);X3perm = X(ind(nX1+nX2+1:end),:); %#ok<*PFBNS>
                 % group averages 
                  AvgX1perm = mean(X1perm);AvgX2perm = mean(X2perm);AvgX3perm = mean(X3perm);AvgXperm = mean(X(ind,:));
                 % SSB
                  SSBperm = sum(sum(([AvgX1perm;AvgX2perm;AvgX3perm] - repmat(AvgXperm,3,1)).^2,2).*[nX1;nX2;nX3])/2;
                 % SSW 
                  SSWperm = sum([sum((X1perm-repmat(AvgX1perm,nX1,1)).^2,2);sum((X2perm-repmat(AvgX2perm,nX2,1)).^2,2);sum((X3perm-repmat(AvgX3perm,nX3,1)).^2,2)])/(nX-2);
                 % F
                  StatCount(i) = (SSBperm/SSWperm)>=F;
           end
           P = sum(StatCount)/t;
       end
       function out = getBalance(nr1,nr2)
                out = min([nr1 nr2])./max([nr1 nr2]);
       end
       function [GAdd,CAdd] = foldUpSample(GO,CO,nr)        
           nO = size(GO,1);
           GAdd = zeros(nr,size(GO,2));
           CAdd = zeros(nr,size(CO,2));
           s = randsample(nO,nr,true);
           alpha = rand(1,nr);
           for f=1:1:nr
               nb = randsample(setdiff(1:nO,s(f)),1);
               GAdd(f,:) = GO(s(f),:) + (GO(nb,:)-GO(s(f),:))*alpha(f);% create new Face
               CAdd(f,:) = CO(s(f),:) + (CO(nb,:)-CO(s(f),:))*alpha(f);% create new Covariates
           end
       end
       function [GRed,CRed] = regDownSample(GO,CO,nrKeep)       
            nr = size(GO,1);
            if nr>nrKeep % randomly reduce
                s = randsample(nr,nrKeep,false);
                GRed = GO(s,:);CRed = CO(s,:);
            else % do not reduce
                GRed = GO;CRed = CO;
            end
       end
       function [GAdd,CAdd] = regUpSample(GO,CO,info)
                s = randsample(info.SampleInd,info.nrSyn,true);% sampling starting faces
                rK = randsample(info.K,info.nrSyn,true);% sampling neighbor ID 1 - K
                nb = info.SampleIndB(sub2ind(size(info.SampleIndB),rK(:),s(:)));% sampling neighbors
                alpha = rand(1,info.nrSyn);% sampling interpolation factor
                GAdd = GO(s,:) + (GO(nb,:)-GO(s,:)).*repmat(alpha(:),1,size(GO,2));% creating new depvar
                CAdd = CO(s,:) + (CO(nb,:)-CO(s,:)).*repmat(alpha(:),1,size(CO,2));% creating new indvar
       end
       function M = getRegression(A,B)
           [A,B] = eliminateNAN(A,B);% typically present in covariates
           [~,~,~,~,M] = plsregress(A,B,size(A,2));
           M = M(end,:);
       end
       function H = wilcoxonM(M)
            nrD = size(M,2);
            H = zeros(1,nrD);
            for j=1:1:nrD
               [~,H(j)] = signrank(M(:,j));% wilcoxon test for median  
            end
       end
       function [out] = normalizeRIP(rip,M,var)
             Mrip = dot(var.MDepVar',M'/norm(M'));
             Prip = dot(var.PDepVar',M'/norm(M'));
             out = ((rip-Mrip)/(Prip-Mrip))*var.Range+var.Mel;
       end
       function [out] = updateRIP(in,M)
            out = dot(in',repmat(M'/norm(M'),1,size(in,1)));
       end
       function [F,FP,FPar,Gmean,GmeanP,GT] = performRIPStat(g,rip,var,t)
                FP = nan;Gmean = nan;GmeanP = nan;GT = nan;
                if var.nrEl<3, doroc = true; else doroc = false;end
                index = find(~isnan(g));g = g(index);
                XG = cell(size(g));
                for l=1:var.nrEl % building grouping variable
                    XG((g==var.El(l))) = {num2str(l)};
                end
                rip = rip(index);n = length(index);
                [F,FPar] = SNPv3.ripAnova(XG,rip);
                if isnan(F), return; end % BAD TEST GROUP
                if doroc, [Gmean,GT] = SNPv3.ripROC(g,rip,var.PosClass); end
                if t == 0,return;end
                FCount = zeros(1,t);
                if doroc, GCount = zeros(1,t); end
                parfor i=1:t
                    ind = randperm(n);
                    Ffor = SNPv3.ripAnova(XG,rip(ind));
                    FCount(i) = Ffor>=F;
                    if doroc, Gmeanfor = SNPv3.ripROC(g,rip(ind),var.PosClass); GCount(i) = Gmeanfor>=Gmean; end
                end
                FP = sum(FCount)/t;
                if doroc, GmeanP = sum(GCount)/t; end
       end
       function [F,P] = ripAnova(XG,rip)
                [P,T] = anova1(rip,XG,'off');
                F = T{2,5};  
       end
       function [G,T] = ripROC(g,rip,posclass)
                g = g*posclass;rip = rip*posclass;% Minority group must be positive class
                [rip,order] = sort(rip);g = g(order);
                true_neg = g == -1;nn = sum(true_neg);fpf = scale(cumsum(true_neg),nn);dx = diff(fpf);
                true_pos = g == 1;na = sum(true_pos);tpf = scale(cumsum(true_pos),na);dy = diff(tpf);
                y = tpf(1:end-1)+dy./2;x = fpf(1:end-1)+dx./2;
                [~,ind] = min(abs(x-(1-y)));
                FN = tpf(ind+1)*na;TN = fpf(ind+1)*nn;
                TP = na-FN;FP = nn-TN;
                G = sqrt((TP/(TP+FN))*(TN/(TN+FP))); % G-mean measure for imbalanced datasets
                if nargout>1, T=rip(ind+1)*posclass;end % classification is done -1 if rip<=T and 1 if rip > T     
       end
       function [G,T] = ripROCFull(g,rip,posclass,testg,testrip)
                g = g*posclass;rip = rip*posclass;% Minority group must be positive class
                testg = testg*posclass;testrip = testrip*posclass;
                [rip,order] = sort(rip);g = g(order);
                true_neg = g == -1;nn = sum(true_neg);fpf = scale(cumsum(true_neg),nn);dx = diff(fpf);
                true_pos = g == 1;na = sum(true_pos);tpf = scale(cumsum(true_pos),na);dy = diff(tpf);
                y = tpf(1:end-1)+dy./2;x = fpf(1:end-1)+dx./2;
                [~,ind] = min(abs(x-(1-y)));
                FN = tpf(ind+1)*na;TN = fpf(ind+1)*nn;
                TP = na-FN;FP = nn-TN;
                G = sqrt((TP/(TP+FN))*(TN/(TN+FP))); % G-mean measure for imbalanced datasets
                nr = length(x)-1;
                GR = zeros(1,nr);
                AC = zeros(1,nr);
                PR = zeros(1,nr);
                RE = zeros(1,nr);
                for i=1:1:nr
                    FNR = tpf(i+1)*na;TNR = fpf(i+1)*nn;
                    TPR = na-FN;FPR = nn-TNR;
                    GR(i) = sqrt((TPR/(TPR+FNR))*(TNR/(TNR+FPR)));
                    AC(i) = (TPR+TNR)/(TPR+FNR+FPR+TNR);
                    PR(i) = TPR/(TPR+FPR);
                    RE(i) = TPR/(TPR+FNR);
                end
                figure;hold on;
                plot(1:nr,GR,'b-');plot(1:nr,PR,'g-');plot(1:nr,RE,'r-');plot(1:nr,AC,'k-');
                [MGR,Mind] = max(GR);
                if nargout>1, T=rip(ind+1)*posclass;end % classification is done -1 if rip<=T and 1 if rip > T     
       end
       function [EER,G,R,pEER,pG,pR] = evalQD(trgg,trrip,gg,rip,posclass,t)
                if nargin < 6, t = 0; end
                n = length(rip);pEER = nan;pG = nan;pR = nan;
                C = unique(trgg);nrC = length(C);allC = 1:nrC;
                AVG = nan*zeros(1,nrC);STD = nan*zeros(1,nrC);
                for c=1:1:nrC
                    trindex = find(trgg==C(c));
                    AVG(c) = mean(trrip(trindex));
                    STD(c) = std(trrip(trindex));
                end
                PDF = normpdf(repmat(rip,1,nrC),repmat(AVG,n,1),repmat(STD,n,1));
                % true matches only defined by minority class
                cp = find(C==posclass);
                indexp = find(gg==posclass);
                remindex = setdiff(1:n,indexp);
                remCp = setdiff(allC,cp);
                ratio = (length(remCp)*PDF(:,cp))./sum(PDF(:,remCp),2);
                tmatches = -log(ratio(indexp));fmatches = -log(ratio(remindex));
                [EER,G] = SNPv3.getEER(tmatches,fmatches);
                R = SNPv3.getRANK(tmatches,fmatches);
                %[EER,G,AUC] = SNPv3.getEER(rip(indexp),rip(remindex));
                if t==0, return; end
                EERcount = zeros(1,t);
                Gcount = zeros(1,t);
                Rcount = zeros(1,t);
                parfor i=1:t
                   ind = randperm(n);
                   forPDF = normpdf(repmat(rip(ind),1,nrC),repmat(AVG,n,1),repmat(STD,n,1));
                   forratio = (length(remCp)*forPDF(:,cp))./sum(forPDF(:,remCp),2);
                   fortmatches = -log(forratio(indexp));forfmatches = -log(forratio(remindex)); 
                   [forEER,forG] = SNPv3.getEER(fortmatches,forfmatches);
                   forR = SNPv3.getRANK(fortmatches,forfmatches);
                   EERcount(i) = forEER<=EER;
                   Gcount(i) = forG>=G;
                   Rcount(i) = forR<=R;
                end
                pEER = sum(EERcount)/t;
                pG = sum(Gcount)/t;
                pR = sum(Rcount)/t;
       end
       function p = pfast(p)
                product=prod(p);
                n=length(p);
                if n<=0
                   error('pfast was passed an empty array of p-values')
                elseif n==1
                   p = product;
                   return;
                elseif product == 0
                   p = 0;
                   return
                else
                   x = -log(product);
                   t=product;
                   p=product;
                   for i = 1:n-1
                       t = t * x / i;
                       p = p + t;
                   end
                end  
       end
       function [out,freq] = getGTInfo(testind,gg,rip)
           % Obtaining group memberships and additional needed info
                 out = cell(1,3);% first is AA, second is AB and third is BB
                 out{1}.GT = -1;out{2}.GT = 0;out{3}.GT = 1;
                 switch testind
                     case 1 % RECESSIVE
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = 3;
                         out{2}.Ind = find(gg==-1);
                         out{2}.Sign = -1;
                         out{2}.Opp = 3;
                         out{3}.Ind = find(gg==1);
                         out{3}.Sign = 1;
                         out{3}.Opp = 1;
                     case 2 % DOMINANT
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = 3;
                         out{2}.Ind = find(gg==1);
                         out{2}.Sign = 1;
                         out{2}.Opp = 1;
                         out{3}.Ind = find(gg==1);
                         out{3}.Sign = 1;
                         out{3}.Opp = 1;
                     case 3 % OVER DOMINANT
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = 2;
                         out{2}.Ind = find(gg==1);
                         out{2}.Sign = 1;
                         out{2}.Opp = 1;
                         out{3}.Ind = find(gg==-1);
                         out{3}.Sign = -1;
                         out{3}.Opp = 2;
                     case 4 % ADDITIVE
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = [2 3];
                         out{2}.Ind = find(gg==0);
                         out{2}.Sign = 0;
                         out{2}.Opp = [1 3];
                         out{3}.Ind = find(gg==1);
                         out{3}.Sign = 1;
                         out{3}.Opp = [1 2];
                     case 5 % AA BB
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = 3;
                         out{2}.Ind = [];
                         out{2}.Sign = 0;
                         out{2}.Opp = [];
                         out{3}.Ind = find(gg==1);
                         out{3}.Sign = 1;
                         out{3}.Opp = 1;
                     case 6 % AA AB
                         out{1}.Ind = find(gg==-1);
                         out{1}.Sign = -1;
                         out{1}.Opp = 2;
                         out{2}.Ind = find(gg==1);
                         out{2}.Sign = 1;
                         out{2}.Opp = 1;
                         out{3}.Ind = [];
                         out{3}.Sign = 0;
                         out{3}.Opp = [];
                     case 7 % AB BB
                         out{1}.Ind = [];
                         out{1}.Sign = 0;
                         out{1}.Opp = [];
                         out{2}.Ind = find(gg==-1);
                         out{2}.Sign = -1;
                         out{2}.Opp = 3;
                         out{3}.Ind = find(gg==1);
                         out{3}.Sign = 1;
                         out{3}.Opp = 2;
                     otherwise
                         out{1}.Ind = [];
                         out{1}.Sign = 0;
                         out{1}.Opp = [];
                         out{2}.Ind = [];
                         out{2}.Sign = 0;
                         out{2}.Opp = [];
                         out{3}.Ind = [];
                         out{3}.Sign = 0;
                         out{3}.Opp = [];
                 end
               % Extracting group RIP Statistics  
                 for i=1:1:3
                     out{i}.Freq = length(out{i}.Ind)/length(find(~isnan(gg)));
                     out{i}.Nr = length(out{i}.Ind);
                     if out{i}.Freq==0, out{i}.Freq = nan; continue;end
                     [out{i}.AVG,out{i}.STD,out{i}.MED,out{i}.MAD] = SNPv3.extractRIPStatistics(rip(out{i}.Ind));                     
                 end
                 freq = [out{1}.Freq out{2}.Freq out{3}.Freq];
       end
       function [AVG,STD,MED,MAD,O] = extractRobustRIPStatistics(rip,kappa)
                % Initialize
                  O.avg = mean(rip);O.std = std(rip);
                  MED = median(rip);MAD = mad(rip);
                  nrO = length(rip);W = ones(1,nrO);
                  for i=1:1:10
                     AVG = sum(W.*rip)/sum(W); 
                     STD = sqrt(sum(W.*((rip-AVG).^2))/sum(W));
                     IP = normpdf(rip,AVG,STD);
                     %L = (1/sqrt(((2*pi)^2)*STD))*exp(-0.5*kappa^2);
                     L = (1/(sqrt(2*pi)*STD))*exp(-0.5*kappa^2);
                     W = IP./(IP+L);
                  end
       end
       function [AVG,STD,MED,MAD] = extractRIPStatistics(rip)
                % Initialize
                  AVG = mean(rip);STD = std(rip);
                  MED = median(rip);MAD = mad(rip);
       end
       function [EER,G,AUC,x,y] = getEER(tmatches,fmatches)
                g = [ones(1,length(tmatches)), -1*ones(1,length(fmatches))];
                [~,order] = sort([tmatches;fmatches],'ascend');
                g = g(order);
                true_neg = g == -1;nn = sum(true_neg);fpf = scale(cumsum(true_neg),nn);dx = diff(fpf);
                true_pos = g == 1;na = sum(true_pos);tpf = scale(cumsum(true_pos),na);dy = diff(tpf);
                y = tpf(1:end-1)+dy./2;
                x = fpf(1:end-1)+dx./2;
                yn = 1-y;d = abs(x-yn);
                [~,ind] = min(d);
                EER = ((x(ind)+yn(ind))/2);
                AUC = sum(dx.*y);
                FN = tpf(ind+1)*na;TN = fpf(ind+1)*nn;
                TP = na-FN;FP = nn-TN;
                G = 1-sqrt((TP/(TP+FN))*(TN/(TN+FP))); 
       end
       function [R] = getRANK(tmatches,fmatches)
                R = sum(repmat(tmatches,1,length(fmatches))>repmat(fmatches',length(tmatches),1),2);
                R = mean(R./(length(fmatches)+1));
       end
   end
end


%  function [EER,P] = matchEvalEERv2(trgg,trrip,gg,rip,posclass,t)
%                 if nargin < 6, t = 0; end
%                 n = length(rip);P = nan;
%                 C = unique(trgg);nrC = length(C);allC = 1:nrC;
%                 AVG = nan*zeros(1,nrC);STD = nan*zeros(1,nrC);
%                 PDF = nan*zeros(length(rip),nrC);
%                 for c=1:1:nrC
%                     trindex = find(trgg==C(c));
%                     AVG(c) = mean(trrip(trindex));
%                     STD(c) = std(trrip(trindex));
%                     PDF(:,c) = normpdf(rip,AVG(c),STD(c));
%                 end
%                 ratio = nan*zeros(n,1);
%                 for c=1:1:nrC
%                     index = find(gg==C(c));
%                     remC = setdiff(allC,c);
%                     ratio(index) = (length(remC)*PDF(index,c))./sum(PDF(index,remC),2);
%                     %ratio(index) = PDF(index,c)./sum(PDF(index,:),2);
%                 end
%                 [EER] = SNPv3.getEER(-log(ratio),-log(ratio.^-1));
%                 
%                 indexp = find(gg==posclass);
%                 [EERP] = SNPv3.getEER(-log(ratio(indexp)),-log(ratio(indexp).^-1));
%                 indexn = setdiff(1:n,indexp);
%                 [EERN] = SNPv3.getEER(-log(ratio(indexn)),-log(ratio(indexn).^-1));
%                 
%                 
%                 if t==0, return; end
%                 count = zeros(1,t);
%                 parfor i=1:t
%                    ind = randperm(n);
%                    forPDF = PDF;
%                    for c=1:1:nrC
%                        forPDF(:,c) = normpdf(rip(ind),AVG(c),STD(c));
%                    end
%                    forratio = nan*zeros(n,1);
%                    for c=1:1:nrC
%                        index = find(gg==C(c));
%                        remC = setdiff(allC,c);
%                        forratio(index) = (length(remC)*forPDF(index,c))./sum(forPDF(index,remC),2);
%                        %forratio(index) = forPDF(index,c)./sum(forPDF(index,:),2);
%                    end
%                    [forEER] = SNPv3.getEER(-log(forratio),-log(forratio.^-1)); 
%                    count(i) = forEER<=EER;
%                 end
%                 P = sum(count)/t;
%        end

% function [acc,str,mstr,Mstr,G,Pstr,PG] = matchEval(trgg,trrip,gg,rip,posclass,t)
%                 if nargin < 6, t = 0; end
%                 Pstr = nan;PG = nan;n = length(rip);
%                 C = unique(trgg);nrC = length(C);allC = 1:nrC;
%                 AVG = nan*zeros(1,nrC);STD = nan*zeros(1,nrC);
%                 PDF = nan*zeros(length(rip),nrC);
%                 for c=1:1:nrC
%                     trindex = find(trgg==C(c));
%                     AVG(c) = mean(trrip(trindex));
%                     STD(c) = std(trrip(trindex));
%                     PDF(:,c) = normpdf(rip,AVG(c),STD(c));
%                 end
%                 ratio = nan*zeros(n,1);
%                 for c=1:1:nrC
%                     index = find(gg==C(c));
%                     remC = setdiff(allC,c);
%                     ratio(index) = (length(remC)*PDF(index,c))./sum(PDF(index,remC),2);
%                     %ratio(index) = PDF(index,c)./sum(PDF(index,:),2);
%                 end
%                 correct = ratio>=1;
%                 %correct = ratio>0.5;
%                 %[H,P] = ttest(ratio-1);
%                 acc = length(find(correct))/n;
%                 str = mean(ratio);
%                 indexp = find(gg==posclass);
%                 nrm = length(indexp);
%                 mstr = mean(ratio(indexp));
%                 TP = sum(correct(indexp));
%                 FN = length(indexp)-TP;
%                 indexn = setdiff(1:n,indexp);
%                 nrM = length(indexn);
%                 Mstr = mean(ratio(indexn));
%                 TN = sum(correct(indexn));
%                 FP = length(indexn)-TN;
%                 G = sqrt((TP/(TP+FN))*(TN/(TN+FP)));         
%                 if t==0, return; end
%                 count = zeros(1,t);
%                 Gcount = zeros(1,t);
%                 parfor i=1:t
%                     ind = randperm(n);
%                     forPDF = PDF;
%                     for c=1:1:nrC
%                         forPDF(:,c) = normpdf(rip(ind),AVG(c),STD(c));
%                     end
%                     forratio = nan*zeros(n,1);
%                     for c=1:1:nrC
%                         index = find(gg==C(c));
%                         remC = setdiff(allC,c);
%                         forratio(index) = (length(remC)*forPDF(index,c))./sum(forPDF(index,remC),2);
%                         %forratio(index) = forPDF(index,c)./sum(forPDF(index,:),2);
%                     end
%                     count(i) = mean(forratio)>=str;
%                     correct = forratio>=1;
%                     %correct = forratio>0.5;
%                     TP = sum(correct(indexp));
%                     FN = length(indexp)-TP;
%                     TN = sum(correct(indexn));
%                     FP = length(indexn)-TN;
%                     Gfor = sqrt((TP/(TP+FN))*(TN/(TN+FP)));
%                     Gcount(i) = Gfor>=G;
%                 end
%                 Pstr = sum(count)/t;
%                 PG = sum(Gcount)/t;
%        end 


% function [EER,P] = matchEvalRANK(trgg,trrip,gg,rip,t)
%                 if nargin < 5, t = 0; end
%                 n = length(rip);P = nan;
%                 C = unique(trgg);nrC = length(C);allC = 1:nrC;
%                 AVG = nan*zeros(1,nrC);STD = nan*zeros(1,nrC);
%                 PDF = nan*zeros(length(rip),nrC);
%                 for c=1:1:nrC
%                     trindex = find(trgg==C(c));
%                     AVG(c) = mean(trrip(trindex));
%                     STD(c) = std(trrip(trindex));
%                     PDF(:,c) = normpdf(rip,AVG(c),STD(c));
%                 end
%                 ratio = nan*zeros(n,1);
%                 for c=1:1:nrC
%                     index = find(gg==C(c));
%                     remC = setdiff(allC,c);
%                     ratio(index) = (length(remC)*PDF(index,c))./sum(PDF(index,remC),2);
%                     %ratio(index) = PDF(index,c)./sum(PDF(index,:),2);
%                 end
%                 [EER] = SNPv3.getEER(-log(ratio),-log(ratio.^-1));
%                 if t==0, return; end
%                 count = zeros(1,t);
%                 parfor i=1:t
%                    ind = randperm(n);
%                    forPDF = PDF;
%                    for c=1:1:nrC
%                        forPDF(:,c) = normpdf(rip(ind),AVG(c),STD(c));
%                    end
%                    forratio = nan*zeros(n,1);
%                    for c=1:1:nrC
%                        index = find(gg==C(c));
%                        remC = setdiff(allC,c);
%                        forratio(index) = (length(remC)*forPDF(index,c))./sum(forPDF(index,remC),2);
%                        %forratio(index) = forPDF(index,c)./sum(forPDF(index,:),2);
%                    end
%                    [forEER] = SNPv3.getEER(-log(forratio),-log(forratio.^-1)); 
%                    count(i) = forEER<=EER;
%                 end
%                 P = sum(count)/t;
%        end
