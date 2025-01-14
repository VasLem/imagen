classdef mapOPT < mySuperClass
    % This is the abstract interface class for MAP function optimizers
    properties
        ObjFun = [];% handle of the MAP object function to optimize
        FloatingCopy;% Copy of Floating handle, primarily used when working multilevel, or limited amount of points
        %Situation = [];
        Change = +inf;% The Current Change evaluation
        ChangeTol = 0.01;% Threshold to determine when a change is sufficiently small to break optimization execution
        ChangeType = 'Evaluation';% Type of Change (diff) Calculation, {Tmodel, Solution, Evaluation}
        Old = [];% Data Structure to remember older iteration information, if required
        MaxIter = 100;% Maximum allowed nr of Iterations
        Iteration = 1;% Current Iteration
        DA = [];% Deterministic annealing scheme
        Step = 1;% Current DA step over iteration loop if DA exists
        ML = [];% MultiLevel scheme
        Level = 1;% Level of MultiLevel Optimization
        Verbose = true;% Displays change and iteration information if Verbose == true
        Show = false;% Vizualize optimization, is set to true by default if Floating surface is visible
        nrPoints = [];% number of floating surface points used during optimization
        MstepEval = 0;% Times the Mstep is evaluated
        Time = 0;% Elapsed Time to optimize
        ExitFlag = [];% How is the algorithm stopped
        Efirst = true;% if true one Estep is done before Mstep, otherwise first Mstep before Estep
    end
    properties (Dependent = true)
        TotalIter;% Estimate of total iterations, dependent on having a DA sheme or not
        StartTemp;% initial Temperature
        FinalTemp; % Final Temperature
        TempFraction;% TempFraction of the initial Temperature
        Rate;% Annealing rate
        nrSteps;% Number of annealing steps
        nrLevels;% Number of Hierarchival optimization Levels
        MinPoints;% ML minimum points
        MaxPoints;%ML maximum points
        PointFraction;% Fraction of Points to get from Minpoints to maxPoints in nrLevel steps
        LevelStepIter;%  Step or Iter in certain level;
        LevelUpdate;% When to change level;
    end
   methods %Constructor
        function obj = mapOPT(varargin)
          obj = obj@mySuperClass(varargin{:});
          if nargin > 0
             Input = find(strcmp(varargin, 'Change'));if ~isempty(Input), obj.Change = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'FloatingCopy'));if ~isempty(Input), obj.FloatingCopy = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'ChangeTol'));if ~isempty(Input), obj.ChangeTol = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'ChangeType'));if ~isempty(Input), obj.ChangeType = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Situation'));if ~isempty(Input), obj.Situation = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'MaxIter'));if ~isempty(Input), obj.MaxIter = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Iteration'));if ~isempty(Input), obj.Iteration = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'DA'));if ~isempty(Input), obj.DA = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Verbose'));if ~isempty(Input), obj.Verbose = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'Show'));if ~isempty(Input), obj.Show = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'ML'));if ~isempty(Input), obj.ML = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'nrPoints'));if ~isempty(Input), obj.nrPoints = varargin{Input+1}; end
             Input = find(strcmp(varargin, 'ObjFun'));if ~isempty(Input), obj.objFun = varargin{Input+1}; end
          end
        end
   end
   methods % Special Getting & Setting
       function obj = set.ChangeType(obj,in)
           if (strcmp(in,'Tmodel'))||(strcmp(in,'Solution'))||(strcmp(in,'Evaluation'))
               obj.ChangeType = in;
           else
               error('Invalid ChangeType for optimizer');
           end
       end
       function out = get.ObjFun(obj)
           out = obj.ObjFun;
           if ~mySuperClass.isH(out), out = []; end
       end
       function obj = set.ObjFun(obj,in)
           obj.ObjFun = in;
       end
       % Deterministic Annealing stuff
       function out = get.DA(obj)
           out = obj.DA;
           if~mySuperClass.isH(out), out = []; end
       end
       function obj = set.DA(obj,in)
           if ~isempty(obj.DA), delete(obj.DA); end
           obj.DA = in;
       end
       function out = get.StartTemp(obj)
           if isempty(obj.DA), out = 0; return; end
           out = obj.DA.StartTemp;
       end
       function obj = set.StartTemp(obj,in)
           if isempty(obj.DA), return; end
           obj.DA.StartTemp = in;
       end
       function out = get.FinalTemp(obj)
           if isempty(obj.DA), out = 0; return; end
           out = obj.DA.FinalTemp;
       end
       function obj = set.FinalTemp(obj,in)
           if isempty(obj.DA), return; end
           obj.DA.FinalTemp = in;
       end
       function out = get.TempFraction(obj)
           if isempty(obj.DA), out = 0; return; end
           out = obj.DA.TempFraction;
       end
       function obj = set.TempFraction(obj,in)
           if isempty(obj.DA), return; end
           obj.DA.TempFraction = in;
       end
       function out = get.Rate(obj)
           if isempty(obj.DA), out = 0; return; end
           out = obj.DA.Rate;
       end
       function obj = set.Rate(obj,in)
           if isempty(obj.DA), return; end
           obj.DA.Rate = in;
       end
       function out = get.Step(obj)
           if isempty(obj.DA), out = obj.Step; return; end
           out = obj.DA.Step;
       end
       function obj = set.Step(obj,in)
           if isempty(obj.DA), obj.Step = in; return; end
           obj.DA.Step = in;
       end
       function out = get.nrSteps(obj)
           if isempty(obj.DA), out = 1; return; end
           out = obj.DA.nrSteps;
       end
       function obj = set.nrSteps(obj,in)
           if isempty(obj.DA), return; end
           obj.DA.nrSteps = in;
       end
       function out = get.MaxIter(obj)
           if isempty(obj.DA), out = obj.MaxIter; return; end
           out = obj.DA.MaxIter;
       end
       function obj = set.MaxIter(obj,in)
           if isempty(obj.DA), obj.MaxIter = in; return; end
           obj.DA.MaxIter = in;
       end
       % Multi Level stuff
       function out = get.ML(obj)
           out = obj.ML;
           if~mySuperClass.isH(out), out = []; end
       end
       function obj = set.ML(obj,in)
           if ~isempty(obj.ML), delete(obj.ML); end
           obj.ML = in;
       end
       function out = get.Level(obj)
           if isempty(obj.ML), out = obj.Level; return; end
           out = obj.ML.Level;
       end
       function obj = set.Level(obj,in)
           if isempty(obj.ML), obj.Level = in; return; end
           obj.ML.Level = in;
       end
       function out = get.nrLevels(obj)
           if isempty(obj.ML), out = 1; return; end
           out = obj.ML.nrLevels;
       end
       function obj = set.nrLevels(obj,in)
           if isempty(obj.ML), return; end
           obj.ML.nrLevels = in;
       end
       function out = get.MinPoints(obj)
           if isempty(obj.ML), out = +inf; return; end
           out = obj.ML.MinPoints;
       end
       function obj = set.MinPoints(obj,in)
           if isempty(obj.ML), return; end
           obj.ML.MinPoints = in;
       end
       function out = get.MaxPoints(obj)
           if isempty(obj.ML), out = +inf; return; end
           out = obj.ML.MaxPoints;
       end
       function obj = set.MaxPoints(obj,in)
           if isempty(obj.ML), return; end
           obj.ML.MaxPoints = in;
       end
       function out = get.PointFraction(obj)
           if isempty(obj.ML), out = 0; return; end
           out = obj.ML.PointFraction;
       end
       function out = get.nrPoints(obj)
           if isempty(obj.ML), out = obj.nrPoints; return; end
           out = obj.ML.nrPoints;
       end
       function obj = set.nrPoints(obj,in)
           if isempty(obj.ML), obj.nrPoints = in; return; end
           obj.ML.MaxPoints = in;% Setting the maximum allowed points to use
       end
       % Relating DA, INNERLOOP and ML       
       function out = get.LevelStepIter(obj)
           if ~isempty(obj.DA), out = obj.Step; return; end
           out = obj.Iteration;
       end
       function out = get.LevelUpdate(obj)
           if isempty(obj.ML), out = false; return; end
           if obj.Level==obj.nrLevels, out = false; return; end
           if ~isempty(obj.DA)
              total = obj.nrSteps;
           else
              total = obj.MaxIter;
           end
           factor = ceil(total/obj.nrLevels);
           out = mod(obj.LevelStepIter,obj.Level*factor)==0;
       end
       function out = get.TotalIter(obj)
           out = obj.nrSteps*obj.MaxIter;
       end
   end
   methods % InterFace functions
        function delete(obj)
           if ~isempty(obj.DA), delete(obj.DA); end
           if ~isempty(obj.ML), delete(obj.ML); end
        end
        function copy(obj,cobj)
                 copy@mySuperClass(obj,cobj);
                 cobj.Change = obj.Change;
                 cobj.FloatingCopy = obj.FloatingCopy;
                 cobj.ChangeTol = obj.ChangeTol;
                 cobj.ChangeType = obj.ChangeType;
                 cobj.MaxIter = obj.MaxIter;
                 cobj.Iteration = obj.Iteration;
                 cobj.Verbose = obj.Verbose;
                 cobj.Show = obj.Show;
                 cobj.DA = [];
                 if ~isempty(obj.DA), cobj.DA = clone(obj.DA);end
                 cobj.ML = [];
                 if ~isempty(obj.ML), cobj.ML = clone(obj.ML);end
                 cobj.Step = obj.Step;
                 cobj.Level = obj.Level;
                 cobj.nrPoints = obj.nrPoints;
                 cobj.Time = obj.Time;
                 cobj.ObjFun = obj.ObjFun;
                 cobj.MstepEval = obj.MstepEval;
        end
        function out = initialize(obj)
                 if nargout == 1
                    obj = clone(obj);
                    out = obj;
                 end
              obj.Old.Evals = zeros(1,obj.TotalIter);
            % initialize Times Mstep is evaluated
              obj.MstepEval = 0;
              obj.ExitFlag = [];
            % intialize IL
              initializeIL(obj);% iteration = 1;
            % Initialize Deterministic scheme 
              initializeDA(obj); % Step = 1, Setting Temperature to initTemp with DA or 0 without DA
            % Initialize Multi Level Scheme
              initializeML(obj); % Level = 1, if nrPoints == [], nrPoints = Floating.nrV;, Change = inf;
              obj.ObjFun.Floating = reduceFloating(obj);% Reduce Floating if required
            % initialize obj.ObjFun
              initialize(obj.ObjFun);% Tmodel: P = zeros + evaluation = FS , CompleteP parameters, LatentV = ones; Solution = Floating
              obj.Old.Evals(1) = floor(obj.ObjFun.Evaluation*(1/obj.ChangeTol));
            % initialize Visualization 
              initializeShow(obj);% Display solution if obj.Show == true
            % initialize Change 
              initializeChange(obj);% Situation = current obj.ObjFun
        end
        function initializeIL(obj) %#ok<INUSD>
            obj.Iteration = 1;
        end
        function initializeDA(obj)
            obj.Step = 1;
            obj.ObjFun.Temp = obj.StartTemp;
        end
        function initializeML(obj)
            obj.Change = +inf;
            obj.Level = 1;
            if isempty(obj.nrPoints), obj.nrPoints = obj.ObjFun.Floating.nrV; return; end% Set the maximum or used nrPoints equal to 
            if (obj.nrPoints > obj.ObjFun.Floating.nrV), obj.nrPoints = obj.ObjFun.Floating.nrV; end% no more points than possible
        end
        function initializeShow(obj)
            if ~obj.Show, return; end
            obj.ObjFun.Solution.ColorMode = 'Indexed';
            obj.ObjFun.Solution.ViewMode = 'Wireframe';
            if obj.ObjFun.Target.Visible
               obj.ObjFun.Target.Selected = false;
               obj.ObjFun.Solution.Axes = obj.ObjFun.Target.Axes;
               obj.ObjFun.Solution.Visible = true;
               obj.ObjFun.Solution.Selected = true;
            else
               viewer(obj.ObjFun.Solution);
            end
        end
        function finalize(obj) %#ok<INUSD>
            obj.Iteration = 0;% Innerloop
            obj.Step = 0;% Deterministic Annealing scheme
            obj.Level = 0;% Multi Levels scheme
            obj.MstepEval = 0;
            switch obj.ChangeType
                case {'Tmodel' 'Solution'}
                    delete(obj.Old.ChangeInfo);
                otherwise
            end
        end
        function struc = obj2struc(obj)
            % no point in saving optimizer data;
            % hence not implemented
            struc.Type = obj.Type;
            % converting relevant information
        end
        function obj = struc2obj(obj,struc) %#ok<INUSD>
            % do nothing
        end
        function str = strInfo(obj)
            str = [];
            if ~isempty(obj.ML), str = [str strInfo(obj.ML)]; end
            if ~isempty(obj.DA), str = [str strInfo(obj.DA)]; end
            str = [str 'Iter: ' num2str(obj.Iteration) '/' obj.ChangeType ' Change: ' num2str(obj.Change)];
            str = [str '/Eval: ' num2str(obj.ObjFun.Evaluation) '/Temp: ' num2str(obj.ObjFun.Temp)];
        end
        function displayInfo(obj)
            display(strInfo(obj));
        end
        function updateChange(obj)
            switch obj.ChangeType
                case 'Tmodel'
                    % difference between transformation parameters
                    if ~(obj.Old.ChangeInfo.nrP==obj.ObjFun.Tmodel.nrP), 
                       obj.Change = +inf;
                    else
                       obj.Change = difference(obj.Old.ChangeInfo,obj.ObjFun.Tmodel);
                    end
                    delete(obj.Old.ChangeInfo);
                    obj.Old.ChangeInfo = clone(obj.ObjFun.Tmodel);
                case 'Solution'
                    % rmse difference between solutions
                    if ~(obj.Old.ChangeInfo.nrV==obj.ObjFun.Solution.nrV)
                        obj.Change = +inf;
                    else
                        obj.Change = vRmse(obj.Old.ChangeInfo,obj.ObjFun.Solution);
                    end
                    fastCopy(obj.ObjFun.Solution,obj.Old.ChangeInfo);
                case 'Evaluation'
                    % Difference between MAP evaluations
                    obj.Change = (obj.Old.ChangeInfo-obj.ObjFun.Evaluation);
                    obj.Old.ChangeInfo = obj.ObjFun.Evaluation;
                otherwise
                    return;
            end
        end
        function initializeChange(obj)
            switch obj.ChangeType
                case 'Tmodel'
                    obj.Old.ChangeInfo = clone(obj.ObjFun.Tmodel);
                case 'Solution'
                    obj.Old.ChangeInfo = fastClone(obj.ObjFun.Solution);
                case 'Evaluation'
                    % Difference between MAP evaluations
                    obj.Old.ChangeInfo = obj.ObjFun.Evaluation;
                otherwise
                    return;
            end
        end
        function updateTemp(obj)
            %if (obj.Step==obj.nrSteps), obj.ObjFun.Temp = 0; return; end% Last DA loop run is going to start
            if ~isempty(obj.DA), updateTemp(obj.DA,obj.ObjFun); return; end
            obj.ObjFun.Temp = 0;
        end
        function out = reduceFloating(obj)
            factor = floor(obj.FloatingCopy.nrV/obj.nrPoints);
            if factor == 0||factor == 1, out = clone(obj.FloatingCopy);return; end
            out = reduceTriangles(obj.FloatingCopy,floor(obj.FloatingCopy.nrF/factor));
        end
        function Estep(obj)
           update(obj.ObjFun);
        end
   end
   methods (Abstract = true)
       Mstep(obj);
   end
end % classdef
