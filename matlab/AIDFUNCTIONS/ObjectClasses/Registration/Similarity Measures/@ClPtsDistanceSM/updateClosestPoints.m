function updateClosestPoints(obj,Tmodel)
    if obj.Update % Need to update Closest points and all other information       
        [obj.Index,obj.Distance] = knn(kde(obj.TargetInfo,5),Tmodel.Evaluation.Vertices,1);%kde toolbox routine
        obj.Difference = Tmodel.Evaluation.Vertices-obj.TargetInfo(:,obj.Index);
    else % Need to update information only
        if isempty(obj.Index), error('No index set for closest points'); end
        obj.Difference = Tmodel.Evaluation.Vertices-obj.TargetInfo(:,obj.Index);
        obj.Distance = sqrt(sum(obj.Difference.^2));    
    end
end