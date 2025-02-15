function out = warpImage(obj,startUV,endUV,res)
         if nargin < 4
            res = [0.002 0.002];
         end
         if nargout == 1
            obj = clone(obj);
            out = obj;
         end
% Cutting out relevant piece of image with bounding box BB;
         % startUV = obj.UV(:,Cindex);endUV = newCUV;
         BB = [min(startUV(1,:)), max(startUV(1,:)); min(startUV(2,:)), max(startUV(2,:))];
         BB(1,1) = floor(BB(1,1)*obj.ImageSize(1));BB(1,2) = ceil(BB(1,2)*obj.ImageSize(1));
         BB(2,1) = floor(BB(2,1)*obj.ImageSize(2));BB(2,2) = ceil(BB(2,2)*obj.ImageSize(2));
         BB(find(BB==0)) = 1;
         startUV(1,:) = ((startUV(1,:).*obj.ImageSize(1))-BB(1,1))/(BB(1,2)-BB(1,1));
         startUV(2,:) = ((startUV(2,:).*obj.ImageSize(2))-BB(2,1))/(BB(2,2)-BB(2,1));      
         m = BB(2,2)-BB(2,1)+1;
         n = BB(1,2)-BB(1,1)+1;
         [X Y] = meshgrid(1:n,1:m);X = X./n;Y = Y./m;
         im_u = griddata(startUV(1,:),startUV(2,:),endUV(1,:),X,Y,'cubic');
         im_v = griddata(startUV(1,:),startUV(2,:),endUV(2,:),X,Y,'cubic');
         warped.UV = [im_u(:)';im_v(:)'];
         clear im_u im_v;
         index = find(~isnan(warped.UV(1,:))&...% not keeping nan values
                      (warped.UV(1,:)>=0)&(warped.UV(1,:)<=1)&... % Stay within u [0 1] range
                      (warped.UV(2,:)>=0)&(warped.UV(2,:)<=1)); % stay within v [0 1] range    
         warped.UV = warped.UV(:,index);        
                 
         im = obj.Image(BB(2,1):BB(2,2),BB(1,1):BB(1,2),:);
         warped.Image = im2value(im);clear im;
         warped.Image = warped.Image(:,index);       
         [X Y] = meshgrid(0:res(1):1,0:res(2):1);
         im = zeros(size(X,1),size(X,2),obj.Dim);
         warning('off','All');
         for i=1:1:obj.Dim
             im(:,:,i) = griddata(warped.UV(1,:),warped.UV(2,:),warped.Image(i,:),X,Y,'cubic');
         end
         clear warped;
         warning('on','All');
         obj.Image = im;         
end
         
function value = im2value(im)
         if numel(size(im))==3;
            nrChannels = size(im,3);
         else
            nrChannels = 1;
         end
         value = [];
         for i=1:1:nrChannels
             tmp = im(:,:,i);
             value = [value; tmp(:)'];
         end
         
end
