function out = initialize(obj,p)
         if nargout == 1,obj = clone(obj);out = obj;end
         initialize@TM(obj,p);
         obj.c = p;
end