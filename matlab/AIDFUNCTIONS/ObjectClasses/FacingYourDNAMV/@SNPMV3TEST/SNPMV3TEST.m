classdef SNPMV3TEST < CATMV3TEST
   % General Properties
   properties
      VarName = [];
      TestInd = 1;
   end
   properties (Dependent = true)
      GrpGT;
      FreqGT;
      mAlF;
      Label;
      GGGTBal;
      PosClass;
   end
   properties (Hidden = true, Dependent = true)
      VarType;
      RS;
      GT;
      GG;
      AL;
      mAl;
      MAl;
      MAlF;
      nm;
      nM;
      nmm;
      nMm;
      nMM;
      fmm;
      fMm;
      fMM; 
      XREG;
      mmGT;
      MmGT;
      MMGT;
      mmind;
      Mmind;
      MMind;
      nAA;
      nAB;
      nBB;
      AAind;
      ABind;
      BBind;
      fAA;
      fAB;
      fBB;
      nA;
      nB;
      fA;
      fB;
      nAl;
      nGT;
      ID;
   end
   methods % CONSTRUCTOR
        function obj = SNPMV3TEST(varargin)
            obj = obj@CATMV3TEST(varargin{:});         
        end
   end
   methods % GETTING/SETTING
       function out = get.XREG(obj)
           out = GT2GG(obj,obj.GT);
       end
       function out = get.RS(obj)
          out = obj.VarName; 
       end
       function set.RS(obj,in)
          obj.VarName = in; 
       end
       function out = get.GT(obj)
           out = obj.X;
       end
       function set.GT(obj,in)
           obj.X = in;
       end
       function out = get.GG(obj)
           if isempty(obj.GT), out = []; return; end
           out = GT2GG(obj,obj.GT);
       end
       function out = get.GGGTBal(obj)
          if isempty(obj.GT), out = []; return; end
          out = SNPMV3TEST.getGGGTBalance(obj.GG,obj.GT);
       end
       function out = get.AL(obj)
           if isempty(obj.GT), out = [];return;end
           out = nan*obj.GT;
           out(obj.ABind) = 1;
           switch obj.mAl
               case 'A'
                  out(obj.AAind) = 2;
                  out(obj.BBind) = 0;
               case 'B'
                  out(obj.AAind) = 0;
                  out(obj.BBind) = 2;
           end
           out = single(out);
       end
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
       function out = get.nAA(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.AAind);
       end
       function out = get.nAB(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.ABind);
       end
       function out = get.nBB(obj)
           if isempty(obj.GT), out = 0; return; end
           out = length(obj.BBind);
       end
       function out = get.nA(obj)
                out = 2*obj.nAA+obj.nAB; 
       end
       function out = get.nB(obj)
                out = 2*obj.nBB+obj.nAB;
       end
       function out = get.nm(obj)
           switch obj.mAl
               case 'A'
                   out = obj.nA;
               case 'B'
                   out = obj.nB;
           end
       end
       function out = get.nM(obj)
           switch obj.mAl
               case 'A'
                   out = obj.nB;
               case 'B'
                   out = obj.nA;
           end
       end
       function out = get.fAA(obj)
                out = sqrt(obj.nAA/(obj.nAA+obj.nAB+obj.nBB));
       end
       function out = get.fAB(obj)
                out = sqrt(obj.nAB/(obj.nAA+obj.nAB+obj.nBB));
       end
       function out = get.fBB(obj)
                out = sqrt(obj.nBB/(obj.nAA+obj.nAB+obj.nBB));
       end
       function out = get.nGT(obj)
           out = length(obj.GT);
       end
       function out = get.nAl(obj)
           out = obj.nGT*2;
       end
       function out = get.fA(obj)
           if isempty(obj.GT), out = 0; return; end
           out = obj.nA/obj.nAl;
       end
       function out = get.fB(obj)
           if isempty(obj.GT), out = 0; return; end
           out = obj.nB/obj.nAl;
       end
       function out = get.mAl(obj)
           if obj.nA<=obj.nB
               out = 'A';
           else
               out = 'B';
           end
       end
       function out = get.MAl(obj)
           if obj.nA>=obj.nB
               out = 'A';
           else
               out = 'B';
           end
       end
       function out = get.Label(obj)
           switch obj.TestInd
               case 0
                   out = 'NO EFFECT';
               case 1
                   %out = 'RECESSIVE';
                   out = 'aa-aAAA';
               case 2
                   out = 'aaaA-AA';
               case 3
                   out = 'aaAA-aA';
               case 4
                   out = 'aa-aA-AA';
               case 5
                   out = 'aa-AA';
               case 6
                   out = 'aa-aA';
               case 7
                   out = 'aA-AA';
               case 8
                   out = 'NON ADDITIVE';
               case 9
                   out = 'ADDITIVE AA AB';
               case 10
                   out = 'ADDITIEVE AB BB';    
           end
       end
       function out = get.mAlF(obj)
           out = min([obj.fA obj.fB]); 
       end
       function out = get.MAlF(obj)
           out = max([obj.fA obj.fB]);
       end
       function out = get.mmind(obj)
          if isempty(obj.AL), out = [];return;end 
          out = find(obj.AL==2); 
       end
       function out = get.Mmind(obj)
          if isempty(obj.AL), out = [];return;end
          out = find(obj.AL==1); 
       end
       function out = get.MMind(obj)
          if isempty(obj.AL), out = [];return;end 
          out = find(obj.AL==0); 
       end
       function out = get.nmm(obj)
           out = length(obj.mmind);
       end
       function out = get.nMm(obj)
           out = length(obj.Mmind);
       end
       function out = get.nMM(obj)
           out = length(obj.MMind);
       end
       function out = get.fmm(obj)
                out = sqrt(obj.nmm/(obj.nmm+obj.nMm+obj.nMM));
       end
       function out = get.fMm(obj)
                out = sqrt(obj.nMm/(obj.nmm+obj.nMm+obj.nMM));
       end
       function out = get.fMM(obj)
                out = sqrt(obj.nMM/(obj.nmm+obj.nMm+obj.nMM));
       end
       function out = get.FreqGT(obj)
           out = [obj.fmm obj.fMm obj.fMM];
       end
       function out = get.GrpGT(obj)
           out = [obj.nmm obj.nMm obj.nMM];
       end
       function out = get.mmGT(obj)
                switch obj.mAl
                    case 'A'
                        out = -1;
                    case 'B'
                        out = 1;
                end 
       end
       function out = get.MmGT(obj) %#ok<*MANU>
                out = 0; 
       end
       function out = get.MMGT(obj)
                switch obj.mAl
                    case 'A'
                        out = 1;
                    case 'B'
                        out = -1;
                end 
       end
       function out = get.ID(obj)
           out = 1000;
       end
       function out = get.VarType(obj)
          out = 'SNP'; 
       end
       function out = get.PosClass(obj)
           if isempty(obj.GT), out = []; return; end
           tmp = obj.GG;
           np = sum(tmp==1);
           nn = sum(tmp==-1);
           switch np<=nn
               case true
                   out = 1;
               case false
                   out = -1;
           end
       end
   end
   methods % DATA CHECKING
       function out = dataCheckGT(obj,MinSampleSize)
           if nargin<2, MinSampleSize = 10;end
           mmOk = obj.nmm>=MinSampleSize;
           MmOk = obj.nMm>=MinSampleSize;
           MMOk = obj.nMM>=MinSampleSize;
           switch obj.TestInd
               case 0
                   out = false;
               case {1 2 3 4} % All three groups required
                   out = mmOk&MmOk&MMOk;
               case 5 % test 4: AA BB
                   out = mmOk&MMOk;
               case 6 % test 5: AA AB
                   out = mmOk&MmOk;
               case 7 % test 6: AB BB
                   out = MmOk&MMOk;
               otherwise
                   error('Wrong Test Index');
           end
       end
       function out = dataCheckGTFreq(obj,MinSampleFreq)
           if nargin<2, MinSampleFreq = 0.1;end
           mmOk = obj.fmm>=MinSampleFreq;
           MmOk = obj.fMm>=MinSampleFreq;
           MMOk = obj.fMM>=MinSampleFreq;
           switch obj.TestInd
               case 0
                   out = false;
               case {1 2 3 4} % All three groups required
                   out = mmOk&MmOk&MMOk;
               case 5 % test 4: AA BB
                   out = mmOk&MMOk;
               case 6 % test 5: AA AB
                   out = mmOk&MmOk;
               case 7 % test 6: AB BB
                   out = MmOk&MMOk;
               otherwise
                   error('Wrong Test Index');
           end
       end
       function out = dataCheckmAlF(obj,MinAlFreq)
           if nargin<2, MinAlFreq = 0.1;end
           out = obj.mAlF>=MinAlFreq;
       end
       function out = dataCheckTestGT(obj,TestGT,MinBal)
                TestGG = GT2GG(obj,TestGT);
                if obj.TestInd==4,TestGG(TestGG==0) = nan;end
                TestGG = TestGG(~isnan(TestGG));
                indM = find(TestGG==-1);
                indm = find(TestGG==1);
                bal = min(length(indM),length(indm))/max(length(indM),length(indm));
                out = bal>=MinBal;
       end
   end
   methods % INTERFACING
       function out = GT2GG(obj,in)
           out = in;% Initialize
           mmind = find(in==obj.mmGT); %#ok<*PROPLC>
           Mmind = find(in==obj.MmGT);
           MMind = find(in==obj.MMGT);
           switch obj.TestInd
               case 0 % NO EFFECT
                   out = nan*out;
               case 1 % test 1: AAAB BB (RECESSIVE)
                   out(union(Mmind,MMind)) = -1;
                   out(mmind) = 1;
               case 2 % test 2: AA ABBB (DOMINANT)
                   out(MMind) = -1;
                   out(union(mmind,Mmind)) = 1;
               case 3 % test 3: AABB AB (OVER DOMINANT)
                   out(union(mmind,MMind)) = -1;
                   out(Mmind) = 1;
               case 4 % test 4 AA AB BB (ADDITIVE)
                   out(mmind) = 1;
                   out(Mmind) = 0;
                   out(MMind) = -1;
               case 5 % test 5: AA BB
                   out(mmind) = 1;
                   out(Mmind) = nan;
                   out(MMind) = -1;
               case 6 % test 6: AA AB
                   out(mmind) = 1;
                   out(Mmind) = -1;
                   out(MMind) = nan;
               case 7 % test 7: AB BB
                   out(mmind) = nan;
                   out(Mmind) = 1;
                   out(MMind) = -1;
           end       
       end
   end
   methods % CLASSIFIER
      function [X,COST,W,ind,Tind,Find] = prepTrainClassifier(obj,X) %#ok<*INUSL>
            X = GT2GG(obj,X);
            Find = find(X==-1*obj.PosClass);
            Tind = find(X==obj.PosClass);
            ind = union(Find,Tind);
            COST.ClassNames = [obj.PosClass -1*obj.PosClass];
            COST.ClassificationCosts = zeros(2,2);
            %COST.ClassificationCosts(1,2) = 1;
            %COST.ClassificationCosts(2,1) = 0.5;
            COST.ClassificationCosts(1,2) = 1-(length(Tind)/length(ind));
            COST.ClassificationCosts(2,1) = 1-(length(Find)/length(ind));
            W = nan*zeros(size(X));
            W(Tind) = 1*(1-(length(Tind)/length(ind)));
            W(Find) = 1-(length(Find)/length(ind));
      end
      function [X,ind,Tind,Find,Tval] = prepTestClassifier(obj,X)
            X = GT2GG(obj,X);
            ind = find(abs(X));
            Find = find(X==-1*obj.PosClass);
            Tind = find(X==obj.PosClass);
            Tval = obj.PosClass;
      end
   end
   methods (Static = true)
       function out = getBalance(nr1,nr2)
                out = min([nr1 nr2])./max([nr1 nr2]);
       end
       function [bal,minbal] = getGGBalance(gg)
          elgg = unique(gg);
          nrgg = length(elgg);
          nS = length(gg);
          bal = nan*zeros(1,nrgg);
          for i=1:1:nrgg
              bal(i) = length(find(gg==elgg(i)))/nS;
          end
          minbal = min(bal);
       end
       function out = getGGGTBalance(gg,gt)
           indexgg = find(~isnan(gg));
           indexgt = find(~isnan(gt));
           index = intersect(indexgg,indexgt);
           gg = gg(index);
           gt = gt(index);
           elgg = unique(gg);
           nrelgg = length(elgg);
           out = zeros(1,nrelgg);
           for i=1:1:nrelgg
              ind = find(gg==elgg(i));
              forgt = gt(ind);
              elforgt = unique(forgt);
              nrelforgt = length(elforgt);
              if nrelforgt==1, out(i) = 1; continue; end
              forout = zeros(1,nrelforgt);
              for j=1:1:nrelforgt
                 forout(j) = length(find(forgt==elforgt(j))); 
              end
              out(i) = min(forout)/max(forout);
           end
       end
   end
end