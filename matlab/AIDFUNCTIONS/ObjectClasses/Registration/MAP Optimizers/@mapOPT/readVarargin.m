function readVarargin(obj,varargin)
        % DETERMINISTIC ANNEALING
        Input = find(strcmp(varargin,'DA'));
        if ~isempty(Input)
            in = varargin{Input+1};
            if islogical(in)
                switch varargin{Input+1}
                    case true
                        obj.DA = DeterministicAnnealing; 
                    case false
                        if ~isempty(obj.DA), delete(obj.DA); end
                    otherwise
                end
            elseif strcmp(in.Type,'DeterministicAnnealing')
                if isempty(obj.DA)||~(obj.DA == in)
                    obj.DA = in;
                end
            else
                error('Wrong Input for Deterministic Annealing Scheme');
            end
        end
        % MULTI LEVEL
        Input = find(strcmp(varargin,'ML'));
        if ~isempty(Input)
            in = varargin{Input+1};
            if islogical(in)
                switch varargin{Input+1}
                    case true
                        obj.ML = MultiLevel; 
                    case false
                        if ~isempty(obj.ML), delete(obj.ML); end
                    otherwise
                end
            elseif strcmp(in.Type,'MultiLevel')
                if isempty(obj.ML)||~(obj.ML == in)
                    obj.ML = in;
                end
            else
                error('Wrong Input for Multi Level Scheme');
            end
        end
        % GENERAL OPTIMIZATION PARAMETERS
        fields = fieldnames(obj);
        for i=1:1:length(fields)
            if strcmp(fields(i),'DA')||strcmp(fields(i),'ML'), continue; end% Already taken care of
            Input = find(strcmp(varargin,fields(i)));
            if ~isempty(Input)
               obj.(fields{i}) = varargin{Input+1}; 
            end
        end
        % SETTING DEFAULT OPTIONS FOR GRADIENT BASED OPTIMIZERS
        if ~strcmp(obj.Type,'ICP')
           if ~isempty(find(strcmp(varargin,'DefaultOptions'), 1))
               defaultOptions(obj);
           end
        end
        % Setting Options for object function
        if ~isempty(obj.ObjFun)
            fields = fieldnames(obj.ObjFun);
            for i=1:1:length(fields)
                Input = find(strcmp(varargin,fields(i)));
                if ~isempty(Input)
                   obj.ObjFun.(fields{i}) = varargin{Input+1}; 
                end
            end
        end
end