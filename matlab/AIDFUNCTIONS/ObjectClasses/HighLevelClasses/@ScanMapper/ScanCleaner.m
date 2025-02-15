classdef ScanCleaner < superClass
    % this class is a class of 3D viewers
    properties
        % figure object, to display sliders and such
        Handles = [];
        B = [];
        Tag = 'Batch Scan Cleaner Tool v1.0 @ copyright Peter Claes'; 
        UserData = [];
        PropScale = 2; 
    end
    properties (Dependent = true)
        
    end
    methods %Constructor
        function obj = ScanCleaner(varargin)
          obj = obj@superClass(varargin{:});
          obj.B = batchPreMapper;
          constructScanCleaner(obj);
        end % 3D viewer Constructor
    end  
    methods % Special Setting and Getting
        function out = get.Handles(obj)
            out = obj.Handles;
            %if ~superClass.isH(out), out = []; end
        end
    end
    methods % Interface functions
             
    end
    methods % Delete
        function delete(obj)
           if ishandle(obj.Handles.Panel), delete(obj.Handles.Panel);end
           delete@superClass(obj);
        end
    end
end % classdef
