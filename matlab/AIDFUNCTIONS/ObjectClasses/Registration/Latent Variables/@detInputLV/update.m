function out = update(obj,Tmodel)
         if isempty(obj.CompleteP), error('Cannot update detOverLV:No CompleteP defined'); end
         if isempty(Tmodel.Evaluation), error('Cannot update detOverLV:Tmodel not evaluated'); end
         tmpout = obj.PriorValues;
         if nargout == 1, out = tmpout; return; end
         obj.Value = tmpout;
end