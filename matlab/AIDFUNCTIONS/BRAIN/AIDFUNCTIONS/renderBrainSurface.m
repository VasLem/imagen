function scan = renderBrainSurface(rend,values,peer)
    try
        scan = clone(rend.RefScan);
    catch
        scan = clone(rend);
    end
    if ~isempty(values)
        scan.VertexValue = values;
        scan.ColorMode = "Indexed";
    end
    scan.Material = 'Dull';
    scan.ViewMode = 'solid';
    
    scan.Visible = true;
    scan.PatchHandle.FaceColor = 'flat';
    if nargin > 2
        scan.RenderAxes = peer;
    axis(peer,'image');
    axis(peer,'off');
    colorbar(peer,'off');   
    end
end