classdef singleMAP < MAP
    % This is the abstract interface class for Maximum Aposteriory 
    properties
        CompleteP = []; % The complete Process
        Tmodel = []; % Transformation Model
        Floating = [];% floating surface
        Temp = 0;% Temperature Parameter to relax CompleteP.InlierP and to regularize Tmodel
        Solution = [];% a object containing the Solution of the MAP.
    end
    properties (Dependent = true)
        % All the info from the Complete Process
            Target;% Target (Surface) handle is stored in CompleteProcess.InlierP.Smeasure.Target;
            InlierP; % link to Inlier Process
            Kappa;% Statistical significance of INlierp;
            OutlierP; % link to Outlier Process
            LatentV; % link to Latent variable
            Smeasure;% Smeasure handle is stored in CompleteProcess.InlierP
            FieldsCP;% Fields on which completeP operates
            B;% B values = LatentV.Value
            Correspondence;% Dependent on Correspondence stored in CompleteProcess.InlierProces.Smeasure.Correspondence
            FastEval;
        % Tmodel information
            FieldsT;% Fields on which the Tmodel operates
            P;% Transformation model parameters
            d;% Transformation model Diff (numeric gradients)
            Nu;% User Defined transformation model regularization
            ActiveP; % Transformation model active parameter
            ActiveField; % Active Field of the Tmodel 
    end
    methods %Constructor
        function obj = singleMAP(varargin)
          obj = obj@MAP(varargin{:});
        end
    end
    methods % Special Getting & Setting
        function out = get.CompleteP(obj)
            out = obj.CompleteP;
            if~mySuperClass.isH(out), out = []; end
        end
        function obj = set.CompleteP(obj,in)
            if ~isempty(obj.CompleteP), delete(obj.CompleteP); end
            obj.CompleteP = in;
        end
        function out = get.Tmodel(obj)
            out = obj.Tmodel;
            if~mySuperClass.isH(out), out = []; end
        end
        function obj = set.Tmodel(obj,in)
            if ~isempty(obj.Tmodel), delete(obj.Tmodel); end
            obj.Tmodel = in;
        end
        function out = get.Target(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.Target;
        end
        function obj = set.Target(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.Target = in;
        end
        function out = get.InlierP(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.InlierP;
        end
        function obj = set.InlierP(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.InlierP = in;
        end
        function out = get.OutlierP(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.OutlierP;
        end
        function obj = set.OutlierP(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.OutlierP = in;
        end
        function out = get.LatentV(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.LatentV;
        end
        function obj = set.LatentV(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.LatentV = in;
        end
        function out = get.Smeasure(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.Smeasure;
        end
        function obj = set.Smeasure(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.Smeasure = in;
        end
        function out = get.FieldsCP(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.Fields;
        end
        function obj = set.FieldsCP(obj,in) %#ok<INUSD>
            %dummy
        end
        function out = get.B(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.B;
        end
        function out = get.Correspondence(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.Correspondence;
        end
        function obj = set.Correspondence(obj,in)
            if isempty(obj.CompleteP), return;end
            obj.CompleteP.Correspondence = in;
        end
        function out = get.FieldsT(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.Fields;
        end
        function obj = set.FieldsT(obj,in) %#ok<INUSD>
            %dummy
        end
        function out = get.P(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.P;
        end
        function obj = set.P(obj,in)
            if isempty(obj.Tmodel), return;end
            obj.Tmodel.P = in;
        end
        function out = get.d(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.d;
        end
        function obj = set.d(obj,in)
            if isempty(obj.Tmodel), return;end
            obj.Tmodel.d = in;
        end
        function out = get.Nu(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.Nu;
        end
        function obj = set.Nu(obj,in)
            if isempty(obj.Tmodel), return;end
            obj.Tmodel.Nu = in;
        end
        function out = get.ActiveP(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.ActiveP;
        end
        function obj = set.ActiveP(obj,in)
            if isempty(obj.Tmodel), return;end
            obj.Tmodel.ActiveP = in;
        end
        function out = get.ActiveField(obj)
            if isempty(obj.Tmodel), out = []; return; end
            out = obj.Tmodel.ActiveField;
        end
        function obj = set.ActiveField(obj,in)
            if isempty(obj.Tmodel), return;end
            obj.Tmodel.ActiveField = in;
        end
        function obj = set.Temp(obj,val)
            obj.Temp = val;
            if ~isempty(obj.CompleteP), obj.CompleteP.Temp = val; end
            if ~isempty(obj.Tmodel), obj.Tmodel.Temp = val; end
        end
        function obj = set.Solution(obj,sol)
            if isempty(sol) 
               if ~isempty(obj.Solution), delete(obj.Solution); end 
               obj.Solution = [];
               return;
            end
            switch class(sol)
                case 'meshObj'
                    if isempty(obj.Solution), obj.Solution = fastClone(sol); return; end
                    if ~strcmp(class(obj.Solution),'meshObj'), delete(obj.Solution);obj.Solution = fastClone(sol); return; end
                    fastCopy(sol,obj.Solution);
                    if ~isempty(obj.Solution.Border), checkVerticesColorUpdate(obj.Solution.Border,'update vertices'); end;
                case 'LMObj'
                    if isempty(obj.Solution), obj.Solution = fastClone(sol); return; end
                    if ~strcmp(class(obj.Solution),'LMObj'), delete(obj.Solution);obj.Solution = fastClone(sol); return; end
                    fastCopy(sol,obj.Solution);
                otherwise
                   error('Solution Input is nor a meshObj, nor a LMobj'); 
            end
            obj.Solution.Value = obj.B;
            
        end       
        function sol = get.Solution(obj)
                 sol = obj.Solution;
                 % Cannot call TM.validEval in this function, infinite Loop of recursions!!!
                 % isempty(obj.Solution) == ~validH(obj,'Solution');
                 if ~mySuperClass.isH(sol), sol = []; return; end
        end
        function obj = set.Kappa(obj,in)
                 if isempty(obj.CompleteP), return; end
                 obj.CompleteP.Kappa = in;
        end
        function out = get.Kappa(obj)
                 if isempty(obj.CompleteP), out = []; return; end
                 out = obj.CompleteP.Kappa;
        end
        function out = get.Floating(obj)
            %if (obj.UseRedFloating)&&(~isempty(obj.RedFloating)), out = obj.RedFloating; return; end
            out = obj.Floating;
            if~mySuperClass.isH(out), out = []; end
        end
        function obj = set.FastEval(obj,in)
                 if isempty(obj.CompleteP), return; end
                 obj.CompleteP.FastEval = in;
        end
        function out = get.FastEval(obj)
            if isempty(obj.CompleteP), out = []; return; end
            out = obj.CompleteP.FastEval;
        end
    end
   methods % InterFace functions
        function delete(obj)
            delete@MAP(obj);
            if ~isempty(obj.CompleteP), delete(obj.CompleteP); end
            if ~isempty(obj.Tmodel), delete(obj.Tmodel); end
            if ~isempty(obj.Solution), delete(obj.Solution); end
            %if ~isempty(obj.RedFloating), delete(obj.RedFloating); end
            % Floating and Target are not deleted;
        end
        function copy(obj,cobj)
                 copy@MAP(obj,cobj);
                 cobj.Temp = obj.Temp;
                 cobj.Floating = obj.Floating;
                 cobj.CompleteP = []; cobj.Tmodel = [];
                 if ~isempty(obj.CompleteP), cobj.CompleteP = clone(obj.CompleteP); end
                 if ~isempty(obj.Tmodel), cobj.Tmodel = clone(obj.Tmodel); end
                 %if ~isempty(obj.RedFloating), cobj.RedFloating = clone(obj.RedFloating); end
        end
        function out = clear(obj)
                 if nargout == 1
                    obj = clone(obj);
                    out = obj;
                 end
                 clear@MAP(obj);
                 obj.Solution = [];
                 if ~isemtpy(obj.Tmodel), clear(obj.Tmodel); end
                 if ~isempty(obj.CompleteP), clear(obj.CompleteP); end
        end
        function struc = obj2struc(obj)
            % converting relevant information
            struc = obj2struc@MAP(obj);
            struc.Temp = obj.Temp;
            %struc.Floating = [];
            %if ~isempty(obj.Floating), struc.Floating = obj2struc(obj.Floating); end
            struc.CompleteP = [];
            if ~isempty(obj.CompleteP), struc.CompleteP = obj2struc(obj.CompleteP); end
            struc.Tmodel = [];
            if ~isempty(obj.Tmodel), struc.Tmodel = obj2struc(obj.Tmodel); end
        end
        function obj = struc2obj(obj,struc)
                 obj.Tmep = struc.Temp;
                 %obj.Floating = [];
                 %if ~isempty(struc.Floating), obj.Floating = struc2obj(eval(struc.Floating.Type),struc.Floating); end
                 obj.CompleteP = [];
                 if ~isempty(struc.CompleteP), obj.CompleteP = struc2obj(eval(struc.CompleteP.Type),struc.CompleteP); end
                 obj.Tmodel = [];
                 if ~isempty(struc.Tmodel), obj.Tmodel = struc2obj(eval(struc.Tmodel.Type),struc.Tmodel); end
        end
        function out = eval(obj)
            %if isempty(obj.Floating), error('Cannot eval MAP: Floating not Set'); end
            % Evaluate TModel & logLnorm
            if ~obj.FastEval
              eval(obj.Tmodel,obj.Floating);
              logLnorm(obj.Tmodel);
              tmpout = obj.Tmodel.LnormEvaluation;
            end
            % Evaluate CompleteP
              % Evaluate InlierP + Evaluate OutlierP
              eval(obj.CompleteP,obj.Tmodel);
              tmpout = tmpout + obj.CompleteP.Evaluation;
            % Storing output
            if nargout == 1, out = tmpout; return; end
            obj.Evaluation = tmpout;
        end
        function out = derivate(obj,Pindex)
            if nargin < 2
                D = zeros(obj.nrP,1);
                for i=1:1:obj.nrP
                    %disp(num2str(i));
                    obj.ActiveP = i;
                    % Derivate TModel
                      % Derivate towards all fields (of Floating) on which
                      % TModel operates
                      derivateField(obj.Tmodel,obj.Floating,'All');
                      % derivate Tmodel log Lnorm 
                      logLnormDerivate(obj.Tmodel);
                    % Derivate CompleteP
                      derivate(obj.CompleteP,obj.Tmodel);
                    % Combine derivates  
                      D(i) = obj.CompleteP.Derivative + obj.Tmodel.LnormDerivative;       
                end
                if nargout == 1, out = D; return; end
                obj.Derivative = D;
            else
                obj.ActiveP = Pindex;
                % Derivate Tmodel
                derivateField(obj.Tmodel,obj.Floating,'All');
                % derivate Tmodel log Lnorm 
                logLnormDerivate(obj.Tmodel);
                % Derivate CompleteP
                derivate(obj.CompleteP,obj.Tmodel);
                % Combine derivates  
                D = obj.CompleteP.Derivative + obj.Tmodel.LnormDerivative;
                if nargout == 1, out = D; return; end
                obj.Derivative(Pindex) = D;
            end
        end
        function out = initialize(obj)
            if nargout == 1
               obj = clone(obj);
               out = obj;
            end
            % initalize Tmodel
              % T parameters = zeros
              % T additional Parameters are set according to floating
              % T.Evaluation == Floating
              % temporarily use Floating
              %obj.UseRedFloating = false;
              initialize(obj.Tmodel,obj.Floating);
              %obj.UseRedFloating = true;
              %obj.Tmodel.Evaluation = obj.Floating;              
            % Initialize CompleteP
              initialize(obj.CompleteP,obj.Tmodel);
              % Initialize LatentV 
                % value == ones
              % Intialize InlierP
                % initialize Smeasure
                    % evaluate Smeasure
                % Update of InlierP Parameters
              % Intitialize OutlierP
                % Update OutlierP Parameters
             % initial evaluation
               obj.Evaluation = obj.CompleteP.Evaluation + obj.Tmodel.LnormEvaluation;
             % initilialize Solution with Floating
               if ~isempty(obj.Solution), delete(obj.Solution);end
               obj.Solution = obj.Floating;% performs only a fastCopy
               copy(obj.Floating,obj.Solution);% hence followed by a full copy, rendering becomes the same;
               obj.Solution.Value = obj.B;
               % show the solution according to visibilty of target and
               % floating
        end
        function out = update(obj)
             % An evaluation must have taken place before update
             if nargout == 1
                obj = clone(obj);
                out = obj;
             end
             %update CompleteP
              update(obj.CompleteP,obj.Tmodel);
              % Update InlierP
                % update of pdf Parameters
              % Update OutlierP
                % update of pdf parameters
              % Update LatentV
                % re-estimate of Values
              % Update evaluation of MapFunction because Complete process
              % was (fast) re-evaluated during update
                obj.Evaluation = obj.Tmodel.LnormEvaluation + obj.CompleteP.Evaluation;
              % Update B values of solution              
        end
        function out = updateCorrespondence(obj)
                 updateCorrespondence(obj.CompleteP,obj.Tmodel);
                 if nargout == 1, out = obj.Correspondence; end
        end
        function updateSolution(obj)
                 obj.Solution = obj.Tmodel.Evaluation;% update to current solution
                 obj.Solution.ViewMode = 'Solid';
                 obj.Solution.Material = 'Dull';
                 try
                    obj.Solution.PoseLM.Visible = false;
                 catch
                 end
                 %obj.Solution.Value = obj.B;
        end
   end
end % classdef

