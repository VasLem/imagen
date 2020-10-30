classdef detProjectionLV < detLV
    % This is the abstract interface class for Transformation models
    properties
        TH = 90;
    end
    properties (Dependent = true)
        Function;% the info of the deterministic function to update LV values
    end
    methods %Constructor
        function obj = detProjectionLV(varargin)
          obj = obj@detLV(varargin{:});
        end
    end        
    methods % Special Setting and Getting
        function F = get.Function(obj)
            if isempty(obj.CompleteP)||isempty(obj.CompleteP.Target)
                %error('not able to retrieve detLV Function, lack of Target
                %info');
                F = [];
                return;
            end
            F = obj.CompleteP.Target;
        end
        function obj = set.Function(obj,input) %#ok<INUSD>
            % Dummy      
        end       
    end
end % classdef
