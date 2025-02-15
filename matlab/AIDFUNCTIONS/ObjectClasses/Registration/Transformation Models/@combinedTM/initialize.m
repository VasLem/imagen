function out = initialize(obj,p)
         if isempty(obj.List), return; end
         if nargout == 1
            obj = clone(obj);
            out = obj;
         end
         for i=1:1:obj.nrTM
            initialize(obj.List{i},p);
         end
         obj.Nu = 1;
         obj.Evaluation = p;
         obj.Derivative = [];
         obj.LnormEvaluation = logLnorm(obj);
         obj.LnormDerivative = [];        
end