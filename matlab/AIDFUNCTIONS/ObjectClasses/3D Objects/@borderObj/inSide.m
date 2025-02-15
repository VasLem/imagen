function in = inSide(obj,points,varargin)
         th = readVarargin(varargin{:});
         %eval = rbfEval(obj,points,varargin{:});
         eval = rbfEval(obj,points);
         in = find(eval>=th);
end

function th = readVarargin(varargin)
         Input = find(strcmp(varargin,'TH'));
         if ~isempty(Input)
            th = varargin{Input+1};
            %varargin = varargin{setdiff((1:length{varargin)),(Input:Input+1)));
         else
            th = 0;
         end
end