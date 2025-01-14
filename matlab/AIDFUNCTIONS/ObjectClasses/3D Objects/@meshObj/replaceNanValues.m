function values = replaceNanValues(obj,values,replacetype,varargin)
    [i,j] = find(isnan(values));
    if isempty(i), return; end
    switch lower(replacetype)
        case 'given'
            values(i,j) = varargin{1}(i,j);
        case 'cp'
            j = unique(j);
            [CP, CD] = closestPoints(obj,obj.Vertices(:,j),'Nr',varargin{1});
            for k=1:1:length(j)
                [mi,nj] = find(~isnan(values(:,CP(k,:))));
                nj = unique(nj);
                if isempty(nj), continue; end
                values(:,j(k)) = sum(values(:,CP(k,nj)).*repmat(1./CD(k,nj),size(values,1),1),2)/sum(1./CD(k,nj));
            end
        otherwise
            return;
    end
end