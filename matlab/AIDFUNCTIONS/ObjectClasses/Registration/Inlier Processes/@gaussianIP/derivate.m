function out = derivate(obj,Tmodel)
% negative log derivation of gaussian pdf
    if isempty(obj.Smeasure), error('Cannot derive IP, no Smeasure set'); end
    derivate(obj.Smeasure,Tmodel);
    [B,sumB] =  getB(obj,Tmodel); %#ok<NASGU>
    D = sum(sum(repmat(B,obj.nrSM,1).*repmat((1./(obj.PdfP.^2)),1,obj.Smeasure.nrV).*(obj.Smeasure.Evaluation.*obj.Smeasure.Derivative)));
    if nargout == 1, out = D; return; end
    obj.Derivative = D;
end

%     for i=1:1:obj.nrSM
%         %eval(obj.Smeasure{i},fs,varargin{:}); Eval beforehand for
%         %computation reasons!
%         derivate(obj.Smeasure{i},fs,varargin{:});
%         if i==1
%            nrP = size(size(obj.Smeasure{i}.Derivative,1));
%            out = zeros(nrP,1);
%         end
%         out = out + sum(repmat(w,nrP,1).*(repmat((1/obj.pdfP(i)^2)*(obj.Smeasure{i}.Evaluation),nrP,1).*obj.Smeasure{i}.Derivative),2);
%     end
%     if nargout == 1, varargout{1} = out; return; end
%     obj.Derivative = out;
