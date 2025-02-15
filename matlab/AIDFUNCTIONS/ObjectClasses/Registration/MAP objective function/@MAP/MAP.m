classdef MAP < mySuperClass
    % This is the abstract interface class for Maximum Aposteriory 
    properties
        Evaluation = [];% Complete Process negative log evaluations over all floating surface points
        Derivative = [];%% Derivate of all Transformation Parameters
        Optimizer = [];% Object able to solve (minimize) the MAP objective function
        Hessian = []% diagonal Hessian of second derivates
    end
    properties (Abstract = true)
        % All the info from the Complete Process
            CompleteP;% Link to Complete Process       
            InlierP; % link to Inlier Process
            OutlierP; % link to Outlier Process
            LatentV; % link to Latent variable
            Smeasure;% Smeasure handle is stored in CompleteProcess.InlierP
            Kappa;% Statistical Significance level
            FieldsCP;% Fields on which completeP operates
            B;% B values = LatentV.Value
            Correspondence;% Dependent on Correspondence stored in CompleteProcess.InlierProces.Smeasure.Correspondence
            FastEval;
        % Tmodel information
            FieldsT;% Fields on which the Tmodel operates
            Tmodel;% Transformation model
            P;% Transformation model parameters
            d;% Transformation model Diff (numeric gradients)
            Nu;% User Defined transformation model regularization
            ActiveP; % Transformation model active parameter
            ActiveField; % Active Field of the Tmodel 
        % Target and Floating Surfaces
            Target;% Target (Surface) handle is stored in CompleteProcess.InlierP.Smeasure.Target;
            Floating;% Floating surface, heavily interacts with TModel
        % Temperatur parameter
            Temp;% Temperature Parameter to relax CompleteP.InlierP and to regularize Tmodel
        % Solution
            Solution;% the solution of the MAP objective function
    end
    properties (Dependent = true)
        Fields;% combination of both CompleteP fields and Tmodel fields
        nrFields;% number of total fields
        nrFieldsCP;% number of CompleteP fields
        nrFieldsT;% number of Tmodel fields
        nrV;% number of vertices in Floating Surfaces
        nrP;% number of parameters       
    end
    methods %Constructor
        function obj = MAP(varargin)
          obj = obj@mySuperClass(varargin{:});
          if nargin > 0
             Input = find(strcmp(varargin, 'CompleteP'));if ~isempty(Input), obj.CompleteP = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'InlierP'));if ~isempty(Input), obj.InlierP = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'OutlierP'));if ~isempty(Input), obj.OutlierP = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'LatentV'));if ~isempty(Input), obj.LatentV = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Evaluation'));if ~isempty(Input), obj.Evaluation = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Derivative'));if ~isempty(Input), obj.Derivative = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Smeasure'));if ~isempty(Input), obj.Smeasure = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Kappa'));if ~isempty(Input), obj.Kappa = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Target'));if ~isempty(Input), obj.Target = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Correspondence'));if ~isempty(Input), obj.Correspondence = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Tmodel'));if ~isempty(Input), obj.Tmodel = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Floating'));if ~isempty(Input), obj.Floating = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Optimizer'));if ~isempty(Input), obj.Optimizer = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Temp'));if ~isempty(Input), obj.Temp = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Solution'));if ~isempty(Input), obj.Solution = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Hessian'));if ~isempty(Input), obj.Hessian = varargin{Input+1}; end
          end
        end
    end
    methods % Special Getting & Setting
        function out =  get.Fields(obj)
            if isempty(obj.FieldsCP)&&isempty(obj.FieldsT),out = []; return; end
            out = union(obj.FieldsCP,obj.FieldsT);
        end
        function nr = get.nrFields(obj)
            nr = length(obj.Fields);
        end
        function nr = get.nrFieldsCP(obj)
            if isempty(obj.CompleteP), nr = []; return; end
            nr = length(obj.FieldsCP);
        end
        function nr = get.nrFieldsT(obj)
            nr = length(obj.FieldsT);
        end
        function nr = get.nrV(obj)
            if isempty(obj.Floating), nr = 0; return; end
            nr = obj.Floating.nrV;
            %nr = length(obj.Indices);
        end
        function nr = get.nrP(obj)
            nr = length(obj.P);
        end
        function opt = get.Optimizer(obj)
            opt = obj.Optimizer;
            if~mySuperClass.isH(opt), opt = []; end
        end
        function obj = set.Optimizer(obj,in)
            if ~isempty(obj.Optimizer), delete(obj.Optimizer); end
            obj.Optimizer = in;
        end      
    end
    methods % InterFace functions
        function delete(obj)
            if ~isempty(obj.Optimizer), delete(obj.Optimizer); end
        end
        function copy(obj,cobj)
                 copy@mySuperClass(obj,cobj);
                 cobj.Evaluation = obj.Evaluation;
                 cobj.Derivative = obj.Derivative;
                 cobj.Hessian = obj.Hessian;
                 cobj.Optimizer = [];
                 %if ~isempty(obj.Optimizer), cobj.Optimizer = clone(obj.Optimizer); end
        end
        function out = clear(obj)
                 if nargout == 1
                    obj = clone(obj);
                    out = obj;
                 end
                 obj.Evaluation = [];
                 obj.Derivative = [];
        end
        function struc = obj2struc(obj)
            % converting relevant information
            struc = obj2struc@mySuperClass(obj);
            struc.Evaluation = obj.Evaluation;
            struc.Derivative = obj.Derivative;
            struc.H = obj.H;
            struc.Optimizer = [];
            if ~isempty(obj.Optimizer), struc.Optimizer = obj2struc(obj.Optimizer); end
        end
        function obj = struc2obj(obj,struc)
                 obj.Evaluation = struc.Evaluation;
                 obj.Derivative = struc.Derivative;
                 obj.H = struc.H;
                 obj.Optimizer = [];%obj.RedFloating
                 if ~isempty(struc.Optimizer), obj.Optimizer = struc2obj(eval(struc.Optimizer.Type),struc.Optimizer); end
        end
        function out = derivateNumeric(obj)
                 f = eval(obj);
                 mu = 2*sqrt(1e-12)*(1+norm(obj.P))/norm(obj.nrP);
                 diff = zeros(obj.nrP,1);
                 origP = obj.P;
                 for j = 1:1:obj.nrP
                    ej = zeros(obj.nrP,1);
                    ej(j) = 1;
                    obj.P = origP+mu*ej;
                    diff(j,1) = eval(obj);
                 end
                 obj.P = origP;
                 D = (diff-f)/mu;
                 if nargout == 1, out = D; return; end
                 obj.Derivative = D;           
        end
        function out = hessianNumeric(obj)
                 H = zeros(obj.nrP,1);
                 origP = obj.P;delta = obj.d;
                 E = eval(obj);
                 for i=1:1:obj.nrP
                     % +  1 deviation
                     obj.P = origP;obj.P(i) = origP(i)+delta(i);
                     Ep1 = eval(obj);
                     % +  2 deviation
                     obj.P = origP;obj.P(i) = origP(i)+2*delta(i);
                     Ep2 = eval(obj);
                     % - 1 deviation
                     obj.P = origP;obj.P(i) = origP(i)-delta(i);
                     Em1 = eval(obj);
                     % - 2 deviation
                     obj.P = origP;obj.P(i) = origP(i)-2*delta(i);
                     Em2 = eval(obj);
                     % derivative2
                     H(i) = (-Ep2+16*Ep1-30*E+16*Em1-Em2)./(12*(delta(i)^2));
                 end
                 obj.P = origP;
                 if nargout == 1, out = H; return; end
                 obj.Hessian = H;              
        end
        function out = hessianPartialNumeric(obj)
                 H = zeros(obj.nrP,1);
                 origP = obj.P;delta = obj.d;
                 for i=1:1:obj.nrP
                     % + deviation
                     obj.P = origP;obj.P(i) = origP(i)+delta(i);
                     eval(obj);
                     Dp = derivate(obj,i);
                     % - deviation
                     obj.P = origP;obj.P(i) = origP(i)-delta(i);
                     eval(obj);
                     Dm = derivate(obj,i);
                     % derivative
                     H(i) = (Dp-Dm)./(2*delta(i));
                 end
                 obj.P = origP;
                 if nargout == 1, out = H; return; end
                 obj.Hessian = H; 
        end
        function out = solve(obj,varargin)
                 if isempty(obj.Optimizer), error('Cannot solve MAP: no optimizer is set'); end
                 obj.Optimizer.ObjFun = obj;
                 solve(obj.Optimizer,varargin{:});
                 if nargout == 1
                    out = clone(obj.Floating);
                    fastCopy(obj.Solution,out);
                 end
        end
        function readVarargin(obj,varargin)
            fields = fieldnames(obj);
            for i=1:1:length(fields)
                Input = find(strcmp(varargin,fields(i)));
                if ~isempty(Input)
                   obj.(fields{i}) = varargin{Input+1}; 
                end
            end     
        end
        function derivateCheck(obj,Pindex)
                 delta = obj.d(Pindex);
                 range = 10*(-delta:delta/5:delta);
                 eval(obj);
                 values = zeros(1,length(range));
                 grads = obj.Evaluation*ones(1,length(range));
                 origP = obj.P;              
                 for i=1:1:length(range)
                     obj.P = origP;
                     obj.P(Pindex) = origP(Pindex) + delta*range(i);
                     values(i) = eval(obj);
                     grads(i) = grads(i) + delta*range(i)*obj.Derivative(Pindex);
                 end
                 obj.P = origP;
                 figure; hold on;
                 plot(values,'b-','LineWidth',1.5);
                 plot(grads,'r-','LineWidth',1);
        end
   end
   methods (Abstract = true)
       out = eval(obj);
       out = derivate(obj);
       out = update(obj);
       out = initialize(obj);
       out = updateCorrespondence(obj);       
   end
end % classdef

