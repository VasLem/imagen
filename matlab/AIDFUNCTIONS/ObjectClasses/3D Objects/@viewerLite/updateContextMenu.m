function updateContextMenu(obj,modetype)
    switch modetype
        case 'All'
            updateContextMenu(obj,'Mode');
            updateContextMenu(obj,'SelectionMode');
            updateContextMenu(obj,'SmoothMode');
            updateContextMenu(obj,'Axes Visible');
            updateContextMenu(obj,'Scene Light');
            updateContextMenu(obj,'Scene Light Linked');
            updateContextMenu(obj,'Axes Grid');
            updateContextMenu(obj,'Axes Box');
            updateContextMenu(obj,'Renderer');
            updateContextMenu(obj,'Camera Projection');           
        case 'Mode'
            switch obj.Mode
                case 'none'
                    set(obj.ContextMenu.NoneMode,'Checked','on');
                    set(obj.ContextMenu.CameraMode,'Checked','off');
                    set(obj.ContextMenu.LightMode,'Checked','off');
                case 'light'
                    set(obj.ContextMenu.NoneMode,'Checked','off');
                    set(obj.ContextMenu.CameraMode,'Checked','off');
                    set(obj.ContextMenu.LightMode,'Checked','on');
                case 'camera'
                    set(obj.ContextMenu.NoneMode,'Checked','off');
                    set(obj.ContextMenu.CameraMode,'Checked','on');
                    set(obj.ContextMenu.LightMode,'Checked','off');
                otherwise
                    return;
            end
        case 'SelectionMode'
            switch obj.SelectionMode
                case 'none'
                    set(obj.ContextMenu.FullMode,'Checked','off');
                    set(obj.ContextMenu.LandmarkMode,'Checked','off');
                    set(obj.ContextMenu.AreaMode,'Checked','off');
                    set(obj.ContextMenu.BrushMode,'Checked','off');
                    set(obj.ContextMenu.FillMode,'Checked','off');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','off');
                    set(obj.ContextMenu.InvertSelection,'Enable','off');
                    set(obj.ContextMenu.DeleteSelection,'Enable','off');
                    set(obj.ContextMenu.CropSelection,'Enable','off');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','off');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','off');
                    set(obj.ContextMenu.SmoothColor,'Enable','off');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','off');
                    set(obj.ContextMenu.TriangleReduce,'Enable','off');
                case 'full'
                    set(obj.ContextMenu.FullMode,'Checked','on');
                    set(obj.ContextMenu.LandmarkMode,'Checked','off');
                    set(obj.ContextMenu.AreaMode,'Checked','off');
                    set(obj.ContextMenu.BrushMode,'Checked','off');
                    set(obj.ContextMenu.FillMode,'Checked','off');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','on');
                    set(obj.ContextMenu.InvertSelection,'Enable','on');
                    set(obj.ContextMenu.DeleteSelection,'Enable','on');
                    set(obj.ContextMenu.CropSelection,'Enable','on');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','off');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','on');
                    set(obj.ContextMenu.SmoothColor,'Enable','on');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','on');
                    set(obj.ContextMenu.TriangleReduce,'Enable','on');
                case 'landmark'
                    set(obj.ContextMenu.FullMode,'Checked','off');
                    set(obj.ContextMenu.LandmarkMode,'Checked','on');
                    set(obj.ContextMenu.AreaMode,'Checked','off');
                    set(obj.ContextMenu.BrushMode,'Checked','off');
                    set(obj.ContextMenu.FillMode,'Checked','off');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','on');
                    set(obj.ContextMenu.InvertSelection,'Enable','off');
                    set(obj.ContextMenu.DeleteSelection,'Enable','off');
                    set(obj.ContextMenu.CropSelection,'Enable','off');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','on');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','on');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','off');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','off');
                    set(obj.ContextMenu.SmoothColor,'Enable','off');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','off');
                    set(obj.ContextMenu.TriangleReduce,'Enable','off');
                case 'area'
                    set(obj.ContextMenu.FullMode,'Checked','off');
                    set(obj.ContextMenu.LandmarkMode,'Checked','off');
                    set(obj.ContextMenu.AreaMode,'Checked','on');
                    set(obj.ContextMenu.BrushMode,'Checked','off');
                    set(obj.ContextMenu.FillMode,'Checked','off');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','on');
                    set(obj.ContextMenu.InvertSelection,'Enable','on');
                    set(obj.ContextMenu.DeleteSelection,'Enable','on');
                    set(obj.ContextMenu.CropSelection,'Enable','on');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','on');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','on');
                    set(obj.ContextMenu.SmoothColor,'Enable','on');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','on');
                    set(obj.ContextMenu.TriangleReduce,'Enable','on');
                case 'brush'
                    set(obj.ContextMenu.FullMode,'Checked','off');
                    set(obj.ContextMenu.LandmarkMode,'Checked','off');
                    set(obj.ContextMenu.AreaMode,'Checked','off');
                    set(obj.ContextMenu.BrushMode,'Checked','on');
                    set(obj.ContextMenu.FillMode,'Checked','off');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','on');
                    set(obj.ContextMenu.InvertSelection,'Enable','on');
                    set(obj.ContextMenu.DeleteSelection,'Enable','on');
                    set(obj.ContextMenu.CropSelection,'Enable','on');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','on');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','on');
                    set(obj.ContextMenu.SmoothColor,'Enable','on');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','on');
                    set(obj.ContextMenu.TriangleReduce,'Enable','on');
                case 'fill'
                    set(obj.ContextMenu.FullMode,'Checked','off');
                    set(obj.ContextMenu.LandmarkMode,'Checked','off');
                    set(obj.ContextMenu.AreaMode,'Checked','off');
                    set(obj.ContextMenu.BrushMode,'Checked','off');
                    set(obj.ContextMenu.FillMode,'Checked','on');
                    
                    set(obj.ContextMenu.ClearSelection,'Enable','on');
                    set(obj.ContextMenu.InvertSelection,'Enable','on');
                    set(obj.ContextMenu.DeleteSelection,'Enable','on');
                    set(obj.ContextMenu.CropSelection,'Enable','on');
                    
                    set(obj.ContextMenu.LinkPoseLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomLandmarks,'Enable','off');
                    set(obj.ContextMenu.LinkCustomArea,'Enable','on');
                    
                    set(obj.ContextMenu.SmoothSurface,'Enable','on');
                    set(obj.ContextMenu.SmoothColor,'Enable','on');
                    set(obj.ContextMenu.TriangleSubdivide,'Enable','on');
                    set(obj.ContextMenu.TriangleReduce,'Enable','on');
                otherwise
                    return;
            end
        case 'SmoothMode'
%             switch obj.SmoothMode
%                 case 'combinatorial'
%                     set(obj.ContextMenu.SmoothCombinatorial,'Checked','on');
%                     set(obj.ContextMenu.SmoothDistance,'Checked','off');
%                     set(obj.ContextMenu.SmoothConformal,'Checked','off');
%                 case 'distance'
%                     set(obj.ContextMenu.SmoothCombinatorial,'Checked','off');
%                     set(obj.ContextMenu.SmoothDistance,'Checked','on');
%                     set(obj.ContextMenu.SmoothConformal,'Checked','off');
%                 case 'conformal'
%                     set(obj.ContextMenu.SmoothCombinatorial,'Checked','off');
%                     set(obj.ContextMenu.SmoothDistance,'Checked','off');
%                     set(obj.ContextMenu.SmoothConformal,'Checked','on');
%                 otherwise
%             end
        case 'Axes Visible'
            switch obj.AxesVisible
                case true
                    set(obj.ContextMenu.AxesVisible,'Checked','on');
                case false
                    set(obj.ContextMenu.AxesVisible,'Checked','off');
                otherwise
                    return;
            end
        case 'Scene Light'
            switch obj.SceneLightVisible
                case true
                    set(obj.ContextMenu.LightVisible,'Checked','on');
                case false
                    set(obj.ContextMenu.LightVisible,'Checked','off');
                otherwise
                    return;
            end
        case 'Scene Light Linked'
            switch obj.SceneLightLinked
                case true
                    set(obj.ContextMenu.LinkLight,'Checked','on');
                case false
                    set(obj.ContextMenu.LinkLight,'Checked','off');
                otherwise
                    return
            end
        case 'Axes Grid'
            switch obj.AxesGrid
                case true
                    set(obj.ContextMenu.AxesGrid,'Checked','on');
                case false
                    set(obj.ContextMenu.AxesGrid,'Checked','off');
                otherwise
                    return
            end
        case 'Axes Box'
            switch obj.AxesBox
                case true
                    set(obj.ContextMenu.AxesBox,'Checked','on');
                case false
                    set(obj.ContextMenu.AxesBox,'Checked','off');
                otherwise
                    return
            end
        case 'Renderer'
            switch obj.Renderer
                case 'zbuffer'
                    set(obj.ContextMenu.Zbuffer,'Checked','on');
                    set(obj.ContextMenu.OpenGl,'Checked','off');
                case 'OpenGL'
                    set(obj.ContextMenu.Zbuffer,'Checked','off');
                    set(obj.ContextMenu.OpenGl,'Checked','on');
                otherwise
                    return;
            end
            
        case 'Camera Projection'
            switch obj.CamProjection
                case 'orthographic'
                    set(obj.ContextMenu.Ortho,'Checked','on');
                    set(obj.ContextMenu.Persp,'Checked','off');
                case 'perspective'
                    set(obj.ContextMenu.Ortho,'Checked','off');
                    set(obj.ContextMenu.Persp,'Checked','on');
                otherwise
                    return;
            end
        otherwise
            return;
    end
end