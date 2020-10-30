function T = rbfMatch(startP,endP,varargin)
   % checking vector sizes
    if size(startP,2)==3 || size(startP,2)==2
        startP = startP';
    end
    if size(endP,2)==3 || size(endP,2)==2
        endP = endP';
    end
    dim = size(startP,1);
   % checking input for rho
    Input = find(strcmp(varargin,'Rho'));
    if ~isempty(Input)
        rho = varargin{Input+1};
    else
        rho = 0;
    end
   % checking input for accuracy
    Input = find(strcmp(varargin,'Accuracy'));
    if ~isempty(Input)
        acc = varargin{Input+1};
    else
        if dim == 2
           acc = 0.001;
        else
           acc = 0.1;
        end
    end
    
    if dim == 2
       T.Dim = 2;
       plx = fastrbf_makepointlist(startP,endP(1,:));
       ply = fastrbf_makepointlist(startP,endP(2,:));
       clear startP endP;
       T.X = fastrbf_fit(plx,acc,'rho',rho,'reduce','messages',0);
       T.Y = fastrbf_fit(ply,acc,'rho',rho,'reduce','messages',0);
       clear plx ply;
    else
       T.Dim = 3;
       plx = fastrbf_makepointlist(startP,endP(1,:));
       ply = fastrbf_makepointlist(startP,endP(2,:));
       plz = fastrbf_makepointlist(startP,endP(3,:));
       clear startP endP;
       plx = fastrbf_unique(plx,'messages',0);
       ply = fastrbf_unique(ply,'messages',0);
       plz = fastrbf_unique(plz,'messages',0);

       T.X = fastrbf_fit(plx,acc,'rho',rho,'reduce','messages',0);
       T.Y = fastrbf_fit(ply,acc,'rho',rho,'reduce','messages',0);
       T.Z = fastrbf_fit(plz,acc,'rho',rho,'reduce','messages',0); 
       clear plx ply plz;
    end
end