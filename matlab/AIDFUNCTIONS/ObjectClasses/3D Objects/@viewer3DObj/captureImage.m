function im = captureImage(obj)
      f = getframe(obj.Figure);
      [im,map] = frame2im(f); %#ok<NASGU>
%       [im,map] = getscreen(obj.Figure);
      if isempty(map), return; end
      im = ind2rgb(im,map);
end