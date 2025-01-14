classdef areaObj < patchObj
    properties
        VerticesIndex = [];
        ViewMode = 'Wireframe';
        RBF = [];
        Border = [];
        IndexedColor = [];% temporary fix, need to be changed
    end
    properties (Dependent = true)
        Vertices;% are dependent on parent
        Faces;% are dependent on parent
        TextureColor;% dependent on parent
        FacesIndex;
        Adjacency;
    end
    methods %Constructor
        function obj = areaObj(varargin)
          obj = obj@patchObj(varargin{:});
          if nargin > 0
           Input = find(strcmp(varargin, 'VerticesIndex'));if~isempty(Input), obj.VerticesIndex = varargin{Input+1}; end
           Input = find(strcmp(varargin, 'FacesIndex'));if~isempty(Input), obj.FacesIndex = varargin{Input+1}; end
           Input = find(strcmp(varargin, 'RBF'));if~isempty(Input), obj.RBF = varargin{Input+1}; end
           Input = find(strcmp(varargin, 'Border'));if~isempty(Input), obj.Border = varargin{Input+1}; end
          end
          obj.MarkerSize = 5;
          obj.SingleColor = [0 0 1];
        end 
    end  
    methods % Special Setting and Getting
        function faces = get.Faces(obj)
            if ~validParent(obj), faces = []; return; end
            [tmp, LOC] = ismember(obj.Parent.Faces,obj.VerticesIndex);
            [i,j] = find(tmp==0);
            tmpindex = (1:size(obj.Parent.Faces,2));
            tmpindex = setdiff(tmpindex,j);
            faces = LOC(:,tmpindex);
        end
        function obj = set.Faces(obj,faces) %#ok<INUSD>
%             if ~validParent(obj), return; end
%             setPatch(obj,'Faces');
        end
        function vertices = get.Vertices(obj)
            if ~validParent(obj), vertices = []; return; end
            vertices = obj.Parent.Vertices(:,obj.VerticesIndex);
        end
        function obj = set.Vertices(obj,Loc)
            if ~validParent(obj), return; end
            if ~(size(Loc,1)==3), Loc = Loc'; end
            if isempty(Loc), return; end% can't be done
            obj.Parent.Vertices(:,obj.VerticesIndex) = Loc;
            checkVerticesColorUpdate(obj,'update vertices');
        end
        function index = get.FacesIndex(obj)
            index = Vindex2Findex(obj.Parent,obj.VerticesIndex);
        end
        function obj = set.FacesIndex(obj,index)
            tmp = obj.Parent.Faces(:,index);
            obj.VerticesIndex = unique(tmp(:));
        end
        function obj = set.VerticesIndex(obj,index)
                 if isempty(index) % special care
                    deletePatch(obj); 
                    obj.VerticesIndex = [];
                    %obj.TextureColor = [];
                    obj.IndexedColor = [];
                    if validChild(obj,obj.Border), delete(obj.Border); end
                    return;
                 end
                 obj.VerticesIndex = index;
                 checkVerticesColorUpdate(obj,'update vertices');
                 if ~validParent(obj), return; end
                 %if ~isempty(obj.Parent.TextureColor),obj.TextureColor = obj.Parent.TextureColor(:,index);end
                 %if ~isempty(obj.Parent.TextureColor),obj.TextureColor = rgb2gray(obj.Parent.TextureColor(:,index)')';end
                 %if ~isempty(obj.Parent.IndexedColor),obj.IndexedColor = obj.Parent.IndexedColor(:,index);end
                 updateChildren(obj,'Index Change');
        end      
        function obj = set.ViewMode(obj,mode)
                 if ~(strcmpi(mode,'Solid') ||... 
                      strcmpi(mode,'Wireframe') ||... 
                      strcmpi(mode,'Points') ||... 
                      strcmpi(mode,'Solid/Wireframe'))
                      error('ViewMode must be Solid, Wireframe, Solid/Wireframe or Points');
                 end
                 obj.ViewMode = mode;
                 setPatch(obj,'ViewMode');
        end
        function obj = set.Border(obj,border)
                 if validChild(obj,obj.Border), delete(obj.Border); end
                 if isempty(border), obj.Border = []; return; end
                 if ~strcmp(class(border),'borderObj'), error('no valid border object'); end                
                 obj.Border = border;
                 obj.Border.Parent = obj;
        end
        function border = get.Border(obj)
                 border = obj.Border;
        end
        function A = get.Adjacency(obj)
            if isempty(obj.Tri), A = []; return; end
            f = double(obj.Tri');
            A = sparse([f(:,1); f(:,1); f(:,2); f(:,2); f(:,3); f(:,3)], ...
                       [f(:,2); f(:,3); f(:,1); f(:,3); f(:,1); f(:,2)], ...
                                                                   1.0);
            % avoid double links
            A = double(A>0);
        end
        function out = get.TextureColor(obj)
            if ~validParent(obj), out = []; return; end
            if isempty(obj.Parent.TextureColor), out = []; return; end
            out = obj.Parent.TextureColor(:,obj.VerticesIndex);
        end
        function obj = set.TextureColor(obj,in)
            % Do nothing;
        end
    end
    methods % Delete
        function delete(obj)          
           deletePatch(obj);
           updateChildren(obj,'Delete');
        end
        function copy(obj,cobj)
            cobj.VerticesIndex = obj.VerticesIndex;
            cobj.Parent = obj.Parent;
            copy@patchObj(obj,cobj);
            cobj.RBF = obj.RBF;            
        end
        function struc = obj2struc(obj)
            struc = obj2struc@patchObj(obj);
            struc.VerticesIndex = obj.VerticesIndex;
            struc.RBF = obj.RBF;
        end
        function obj = struc2obj(obj,struc)
            obj = struc2obj@patchObj(obj,struc);
            obj.VerticesIndex = struc.VerticesIndex;
            obj.RBF = struc.RBF;          
        end
    end
end % classdef

