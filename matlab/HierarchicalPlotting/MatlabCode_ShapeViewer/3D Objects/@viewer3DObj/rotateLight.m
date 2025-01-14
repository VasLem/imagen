function rotateLight(obj,xy)
         [az el] = lightangle(obj.SceneLight);
         % Check if the light is on the other side of the object
         az = mod(abs(az),360);
         if az > 90 && az < 270
            xy(2) = -xy(2);
         end
         az = mod(az + xy(1), 360);
         el = mod(el + xy(2), 360);
         if abs(el) > 90
            el = 180 - el;
            az = 180 + az;
         end
         lightangle(obj.SceneLight, az, el);
         drawnow expose;
% xy = -xy;
% [newPos newUp] = lightorbit(obj.RenderAxes,xy(1),xy(2),'none')%unconstrained rotation
% obj.SceneLightPosition = newPos;
% 
% drawnow expose;

end