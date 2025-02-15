classdef multiTM < TM
    % a transformation class having multiple transformation models executed
    % sequentaly
    properties
        CameraT = [];% Camera Projection transformation model
        RigidT = [];% Rigid transformation
        RbfT = [];% non rigid RBF based transformation
        PcaT = [];% non rigid PCA based transformation
        ColorT = []% Transformation on the Texture color values
    end
    properties (Dependent = true)
        P;% Transformation Model parameters;
        d;% Parameter deviations to compute numerical gradients
        Fields;% The fields of LMobj or meshObj on which the transformation applies, mostly: Vertices
        nrTM;% number of Transformation models
        nrTMP;% array of nr of Parameters per Tmodel
        ActiveModel;% Active Mode
    end
    methods %Constructor
        function obj = multiTM(varargin)
          obj = obj@TM(varargin{:});
          Input = find(strcmp(varargin, 'Tmodel'));if ~isempty(Input), obj.Tmodel = varargin{Input+1}; end
        end
    end
    methods % Setting and Getting
        function out = get.CameraT(obj)
                 out = obj.CameraT;
                 if ~mySuperClass.isH(out), out = []; end
        end
        function obj = set.CameraT(obj,in)
                 if ~isempty(obj.CameraT), delete(obj.CameraT); end
                 obj.CameraT = in;
        end
        function nr = get.nrTM(obj)
                 nr = length(obj.Tmodel);
        end
        function P = get.P(obj)
                 P = [];
                 if obj.nrTM==0, return; end
                 for i=1:1:obj.nrTM
                     P = [P; obj.Tmodel{i}.P]; %#ok<AGROW>
                 end
        end
        function obj = set.P(obj,par)
                 if isempty(obj.Tmodel), return; end
                 index = 1;
                 for i=1:1:obj.nrTM      
                     obj.Tmodel{i}.P = par(index:index+obj.Tmodel{i}.nrP-1);
                     index = index + obj.Tmodel{i}.nrP;
                 end
        end
        function out = get.Tmodel(obj)
                 out = obj.Tmodel;
                 if isempty(out), return; end
                 index = (1:length(out));
                 badindex = [];
                 for i=1:1:length(out)
                     if ~mySuperClass.isH(out{i}), badindex = [badindex i]; end %#ok<AGROW>
                 end
                 restindex = setdiff(index,badindex);
                 out = out(restindex);
        end
        function obj = set.Tmodel(obj,in)
            if isempty(obj.Tmodel), obj.Tmodel = in; return; end
            for i=1:1:max(obj.nrTM,length(in))
                obj.Tmodel{i} = in{i};
            end
        end
        function d = get.d(obj)
                 d = [];
                 if obj.nrTM==0, return; end
                 for i=1:1:obj.nrTM
                     d = [d; obj.Tmodel{i}.d]; %#ok<AGROW>
                 end
        end
        function obj = set.d(obj,val)
                 if isempty(obj.Tmodel), return; end
                 index = 1;
                 for i=1:1:obj.nrTM      
                     obj.Tmodel{i}.d = val(index:index+obj.Tmodel{i}.nrP-1);
                     index = index + obj.Tmodel{i}.nrP;
                 end
        end
        function nr = get.nrTMP(obj)
                 if obj.nrTM==0, nr = []; return; end
                 nr = zeros(1,obj.nrTM);
                 for i=1:1:obj.nrTM
                     nr(i) = obj.Tmodel{i}.nrP;
                 end
        end
        function mindex = get.ActiveModel(obj)
                 if isempty(obj.Tmodel), mindex = []; return; end
                 nr = 0;
                 nrP = obj.nrTMP;
                 for mindex=1:1:obj.nrTM
                     nr = nr + nrP(mindex);
                     if obj.ActiveP<nr
                        break;
                     end
                 end
                 obj.Tmodel{mindex}.ActiveP = nrP(mindex)-(nr-obj.ActiveP);
        end
        function fields = get.Fields(obj)
                 if obj.nrTM==0, fields = {}; return; end
                 fields = {};
                 for i=1:1:obj.nrTM
                     fields = union(fields,obj.Tmodel{i}.Fields); %#ok<AGROW>
                 end            
        end
        function obj = set.Fields(obj,field) %#ok<INUSD>
                 % dummy
        end
    end
    methods % InterFace functions
        function delete(obj) 
           delete@TM(obj);
           if isempty(obj.Tmodel), return; end
           tmp = obj.Tmodel;
           for i=1:1:obj.nrTM
               delete(tmp{i});
           end
        end
        function copy(obj,cobj)
                 copy@TM(obj);
                 cobj.Tmodel = {};
                 if obj.nrTM==0, return; end
                 for i=1:1:obj.nrTM
                     cobj.Tmodel{i} = clone(obj.Tmodel{i});
                 end
        end
        function out = clear(obj)
                 if nargout == 1
                    obj = clone(obj);
                    out = obj;
                 end
                 clear@TM(obj);
                 if isemtpy(obj.Tmodel), return; end
                 for i=1:1:obj.nrTM
                     clear(obj.Tmodel{i});
                 end
        end
        function struc = obj2struc(obj)
            % converting relevant information
            struc = obj2struc@TM(obj);
            if isempty(obj.Tmodel), struc.Tmodel = {}; return; end
            for s=1:1:obj.nrTM
                struc.Tmodel{s} = obj2struc(obj.Tmodel{s});
            end
        end
        function obj = struc2obj(obj,struc)
                 obj = struc2obj@TM(obj,struc);
                 if isempty(struc.Tmodel),obj.Tmodel = {}; return; end
                 for t=1:1:length(struc.Tmodel)
                     obj.Tmodel{t} = struc2obj(eval(struc.Tmodel{t}.Type),struc.Tmodel{t});
                 end
        end
        function postActiveField(obj,field) %#ok<INUSD>
                 if isempty(obj.Tmodel), return; end
                 for i=1:1:obj.nrTM
                     obj.Tmodel{i}.ActiveField = field;
                 end
        end
    end
end % classdef

