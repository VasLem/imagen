classdef G2FPrediction < superClass
   properties
      Sex;
      Age;
      BMI;
      H;
      nAnc;
      nSNP
      Anc;
      SNPNames;
      SNPG;
      RIPG;
      RIPS;
      RIPSE;
      RIPA;
      RIPAE;
      BaseFace;
      PredFace;
      AmplFace;
      AF = 2;
      IdAss;
   end
   properties (Dependent = true)
      nrG;
   end
   methods % Constructor
        function obj = G2FPrediction(varargin)
            obj = obj@superClass(varargin{:});         
        end
   end
   methods % special setting and getting   
       function out = get.nrG(obj)
           out = length(obj.GNAMES);
       end
   end
   methods % Interface functions
       function parsePredictionInput(obj,input)
           [~,~,raw] = xlsread(input);
           obj.Sex = raw{1,2};
           obj.Anc = cell2mat(raw(2,2));
           obj.GNAMES = raw(3:end,1);
           obj.G = cell2mat(raw(3:end,2));
       end
       function amplifyIdentity(obj)
                if isempty(obj.PredFace), error('Make a prediction first'); end
                dir = obj.PredFace.Vertices-obj.BaseFace.Vertices;
                obj.AmplFace = clone(obj.PredFace);
                obj.AmplFace.Vertices = obj.BaseFace.Vertices + obj.AF*dir;        
       end
       function assessIdentity(obj)
                obj.IdAss = compareMorphs(obj.AmplFace,obj.BaseFace);
       end
       function exportFaces(obj)
           exportWavefront(obj.BaseFace,'BaseFace.obj');
           exportWavefront(obj.PredFace,'PredictedFace.obj');
           exportWavefront(obj.AmplFace,'AmplifiedFace.obj');
       end
   end
end