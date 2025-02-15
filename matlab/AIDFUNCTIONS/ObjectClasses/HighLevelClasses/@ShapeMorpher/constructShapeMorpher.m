function constructShapeMorpher(obj)
% GENERATING THE MAIN FIGURE PANEL
  obj.Handles.Panel = figure('Tag', 'Panel', ...
                             'Units', 'characters', ...
                             'Position', [103 20 130 50], ...
                             'Name', 'Morpheus PLSR: @ 2013 copyright Peter Claes', ...
                             'MenuBar', 'none', ...
                             'NumberTitle', 'off', ...
                             'Color', get(0,'DefaultUicontrolBackgroundColor'), ...
                             'Resize', 'off',...
                             'CloseRequestFcn',@PanelCloseCallback);
   setappdata(obj.Handles.Panel,'Application',obj);                      
% GENERATING THE TAB PANELS                            
 obj.Handles.TabPanels = uitabpanel('Parent',obj.Handles.Panel,...
                                    'TabPosition','lefttop',...
                                    'Units','normalized',...
                                    'Position',[0,0.10,1,0.90],...
                                    'Margins',{[0,-1,1,0],'pixels'},...
                                    'Title',{'Shape Space','Predictors'},...
                                    'TitleBackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
                                    'TitleForegroundColor',[0 0 0.502],...
                                    'PanelBackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
                                    'FrameBackgroundColor',get(0,'DefaultUicontrolBackgroundColor'),...
                                    'PanelBorderType','none',...
                                    'ResizeFcn',{});
tmp = getappdata(obj.Handles.TabPanels,'panels');
obj.Handles.PC.Panel = tmp(1);
constructPanelPC(obj);
obj.Handles.Pred.Panel = tmp(2);
constructPanelPred(obj)
% % GENERATING THE BUTTONS                                
obj.Handles.ResetButton = uicontrol('Parent', obj.Handles.Panel, ...
                                   'Tag', 'Reset Button', ...
                                   'UserData', [], ...
                                   'Style', 'pushbutton', ...
                                   'Units', 'normalized', ...
                                   'Position', [0.65 0.02 0.15 0.05], ...
                                   'FontWeight', 'bold', ...
                                   'ForegroundColor', [0 0 0.502], ...
                                   'String', 'Reset',...
                                   'Callback', @ResetButtonCallback);
setappdata(obj.Handles.ResetButton,'Application',obj);
obj.Handles.LoadModelButton = uicontrol('Parent', obj.Handles.Panel, ...
                                    'Tag', 'Load Model Button', ...
                                	'UserData', [], ...
                                	'Style', 'pushbutton', ...
                                    'Units', 'normalized', ...
                                	'Position', [0.81 0.02 0.15 0.05], ...
                                	'FontWeight', 'bold', ...
                                	'ForegroundColor', [0 0 0.502], ...
                                	'String', 'Load Model',...
                                    'Callback', @LoadModelButtonCallback);
setappdata(obj.Handles.LoadModelButton,'Application',obj);
end

%% MAIN PANEL CALLBACKS
function PanelCloseCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         delete(obj);
         close all;
end
function ResetButtonCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         updateCurrentShape(obj,'RESET');
end
function LoadModelButtonCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         out = getMatFile('select shape model');
         if isempty(out), return; end
         switch out{1}.Type
             case 'propertyPCA'
                 obj.ShapeModel = propertyPCA(out{1});
             case 'shapePCA'
                 obj.ShapeModel = shapePCA(out{1});
             case 'valuePCA'
                 obj.ShapeModel = valuePCA(out{1});
             case 'appearancePCA'
                 obj.ShapeModel = appearancePCA(out{1});
             case 'ShapeValuePCA'
                 obj.ShapeModel = ShapeValuePCA(out{1});
             case 'texturePCA'
                 obj.ShapeModel = texturePCA(out{1});
             case 'textureMapPCA'
                 obj.ShapeModel = textureMapPCA(out{1});
             case 'modelPLSR'
                 obj.PredModel = modelPLSR(out{1});
             otherwise
                 error('Wrong model input');
         end
end
%% PC Panel creation functions
function constructPanelPC(obj)
          obj.Handles.PC.Table = uitable(...
                                            'Parent',obj.Handles.PC.Panel,...
                                            'Units','normalized',...
                                            'BackgroundColor',[1 1 1;0.96078431372549 0.96078431372549 0.96078431372549],...
                                            'ColumnName',{'Sel.', 'PC', 'Value', 'mean', 'std'},...
                                            'ColumnFormat',{'logical','char','numeric','numeric','numeric'},...
                                            'ColumnEditable',[true false true false false],...
                                            'ColumnWidth',{40 40 60 60 60},...
                                            'Data',{},...
                                            'Position',[0.01 0.11 0.45 0.85],...
                                            'UserData',[],...
                                            'Tag','PCTable',...
                                            'CellEditCallback', @PCTableCallback,...
                                            'RowName', []);
          setappdata(obj.Handles.PC.Table,'Application',obj);                                        
          obj.Handles.PC.Slider = uicontrol(...
                                            'Parent',obj.Handles.PC.Panel,...
                                            'Units','normalized',...
                                            'BackgroundColor',[0.9 0.9 0.9],...
                                            'Callback',@PCSliderCallback,...
                                            'Position',[0.01 0.01 0.98 0.08],...
                                            'String',{  'Slider' },...
                                            'Style','slider',...
                                            'CreateFcn',{},...
                                            'Max',obj.PCScale,...
                                            'Min',-obj.PCScale,...
                                            'Tag','PC Slider');
         setappdata(obj.Handles.PC.Slider,'Application',obj);
         obj.Handles.PC.Scale = uicontrol(...
                                'Parent',obj.Handles.PC.Panel,...
                                'Units','normalized',...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@PCScaleMenuCallback,...
                                'Position',[0.7 0.05 0.15 0.1],...
                                'String',{'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'},...
                                'Style','popupmenu',...
                                'Value',obj.PCScale,...
                                'TooltipString','Select Slider Scale',...
                                'CreateFcn',{},...
                                'Tag','PC Scale Menu');
        setappdata(obj.Handles.PC.Scale,'Application',obj);
end
%% PC PANEL CALLBACKS
function PCSliderCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         value = get(obj.Handles.PC.Slider,'Value');
         maximum = get(obj.Handles.PC.Slider,'max');
         minimum = get(obj.Handles.PC.Slider,'min');
         if value > maximum
            value = maximum;
            set(obj.Handles.PC.Slider,'Value',value);
         end
         if value < minimum;
            value = minimum;
            set(obj.Handles.PC.Slider,'Value',value);
         end
         updateShapeTable(obj,obj.ActivePC,value);
         updateCurrentShape(obj,'PC');
end
function PCScaleMenuCallback(hObject,eventdata)
          obj = getappdata(hObject,'Application');
          list = get(obj.Handles.PC.Scale,'String');
          obj.PCScale = str2double(list{get(obj.Handles.PC.Scale,'Value')});
end
function PCTableCallback(hObject,eventdata)
 obj = getappdata(hObject,'Application');
 if isempty(obj.ShapeModel), return; end
 row = eventdata.Indices(1);
 Column = eventdata.Indices(2);
 new = eventdata.NewData;
 switch Column
     case 1% change of active scan
         if obj.ActivePC == row  
             obj.ActivePC = 0;
         else
             if ~(obj.ActivePC==0)
                 Data = get(obj.Handles.PC.Table,'Data');
                 Data{obj.ActivePC,1} = false;
                 set(obj.Handles.PC.Table,'Data',Data);
             end
             obj.ActivePC = row;
         end
     case 3
         Data = get(obj.Handles.PC.Table,'Data');
         maximum = Data{row,4}+obj.PCScale*Data{row,5};
         minimum = Data{row,4}-obj.PCScale*Data{row,5};
         if new > maximum
            new = maximum;   
         end
         if new < minimum;
            new = minimum;
         end
         Data{row,Column} = new;
         if ~(obj.ActivePC==row)          
             if ~(obj.ActivePC == 0)
                Data{obj.ActivePC,1} = false;
             end
             Data{row,1} = true;
         end
         set(obj.Handles.PC.Table,'Data',Data);
         updateCurrentShape(obj,'PC');
         obj.ActivePC = row;
     otherwise
         % do nothing
 end
end
%% Predictor Panel creation functions
function constructPanelPred(obj)
          obj.Handles.Pred.Table = uitable(...
                                            'Parent',obj.Handles.Pred.Panel,...
                                            'Units','normalized',...
                                            'BackgroundColor',[1 1 1;0.96078431372549 0.96078431372549 0.96078431372549],...
                                            'ColumnName',{'Sel.', 'Pred.', 'Value', 'mean', 'std'},...
                                            'ColumnFormat',{'logical','char','numeric','numeric','numeric'},...
                                            'ColumnEditable',[true false true false false],...
                                            'ColumnWidth',{40 40 60 60 60},...
                                            'Data',{},...
                                            'Position',[0.01 0.11 0.45 0.85],...
                                            'UserData',[],...
                                            'Tag','PCTable',...
                                            'CellEditCallback', @PredTableCallback,...
                                            'RowName', []);
          setappdata(obj.Handles.Pred.Table,'Application',obj);                                        
          obj.Handles.Pred.Slider = uicontrol(...
                                            'Parent',obj.Handles.Pred.Panel,...
                                            'Units','normalized',...
                                            'BackgroundColor',[0.9 0.9 0.9],...
                                            'Callback',@PredSliderCallback,...
                                            'Position',[0.01 0.01 0.98 0.08],...
                                            'String',{  'Slider' },...
                                            'Style','slider',...
                                            'CreateFcn',{},...
                                            'Max',obj.PredScale,...
                                            'Min',-obj.PredScale,...
                                            'Tag','Predictor Slider');
         setappdata(obj.Handles.Pred.Slider,'Application',obj);
         obj.Handles.Pred.Scale = uicontrol(...
                                'Parent',obj.Handles.Pred.Panel,...
                                'Units','normalized',...
                                'BackgroundColor',[1 1 1],...
                                'Callback',@PredScaleMenuCallback,...
                                'Position',[0.7 0.05 0.15 0.1],...
                                'String',{'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'},...
                                'Style','popupmenu',...
                                'Value',obj.PredScale,...
                                'TooltipString','Select Slider Scale',...
                                'CreateFcn',{},...
                                'Tag','PC Scale Menu');
        setappdata(obj.Handles.Pred.Scale,'Application',obj);
end
%% PC PANEL CALLBACKS
function PredSliderCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         value = get(obj.Handles.Pred.Slider,'Value');
         maximum = get(obj.Handles.Pred.Slider,'max');
         minimum = get(obj.Handles.Pred.Slider,'min');
         if value > maximum
            value = maximum;
            set(obj.Handles.Pred.Slider,'Value',value);
         end
         if value < minimum;
            value = minimum;
            set(obj.Handles.Pred.Slider,'Value',value);
         end
         updatePredTable(obj,obj.ActivePred,value);
         updateCurrentShape(obj,'PRED');
end
function PredScaleMenuCallback(hObject,eventdata)
          obj = getappdata(hObject,'Application');
          list = get(obj.Handles.Pred.Scale,'String');
          obj.PredScale = str2double(list{get(obj.Handles.Pred.Scale,'Value')});
end
function PredTableCallback(hObject,eventdata)
 obj = getappdata(hObject,'Application');
 if isempty(obj.PredModel), return; end
 row = eventdata.Indices(1);
 Column = eventdata.Indices(2);
 new = eventdata.NewData;
 switch Column
     case 1% change of active scan
         if obj.ActivePred == row  
             obj.ActivePred = 0;
         else
             if ~(obj.ActivePred==0)
                 Data = get(obj.Handles.Pred.Table,'Data');
                 Data{obj.ActivePred,1} = false;
                 set(obj.Handles.Pred.Table,'Data',Data);
             end
             obj.ActivePred = row;
         end
     case 3
         Data = get(obj.Handles.Pred.Table,'Data');
         maximum = Data{row,4}+obj.PredScale*Data{row,5};
         minimum = Data{row,4}-obj.PredScale*Data{row,5};
         if new > maximum
            new = maximum;   
         end
         if new < minimum;
            new = minimum;
         end
         Data{row,Column} = new;
         if ~(obj.ActivePred==row)          
             if ~(obj.ActivePred == 0)
                Data{obj.ActivePred,1} = false;
             end
             Data{row,1} = true;
         end
         set(obj.Handles.Pred.Table,'Data',Data);
         updateCurrentShape(obj,'PRED');
         obj.ActivePred = row;
     otherwise
         % do nothing
 end
end


% obj.Handles.BaseButton = uicontrol('Parent', obj.Handles.Panel, ...
%                                     'Tag', 'Export Button', ...
%                                 	'UserData', [], ...
%                                 	'Style', 'pushbutton', ...
%                                     'Units', 'normalized', ...
%                                 	'Position', [0.17 0.02 0.15 0.10], ...
%                                 	'FontWeight', 'bold', ...
%                                 	'ForegroundColor', [0 0 0.502], ...
%                                 	'String', 'Set',...
%                                     'Callback', @BaseButtonCallback);
% setappdata(obj.Handles.BaseButton,'Application',obj);
% obj.Handles.AverageButton = uicontrol('Parent', obj.Handles.Panel, ...
%                                     'Tag', 'Export Button', ...
%                                 	'UserData', [], ...
%                                 	'Style', 'pushbutton', ...
%                                     'Units', 'normalized', ...
%                                 	'Position', [0.33 0.02 0.15 0.10], ...
%                                 	'FontWeight', 'bold', ...
%                                 	'ForegroundColor', [0 0 0.502], ...
%                                 	'String', 'Average',...
%                                     'Callback', @AverageButtonCallback);
% setappdata(obj.Handles.AverageButton,'Application',obj);
% obj.Handles.RandomButton = uicontrol('Parent', obj.Handles.Panel, ...
%                                     'Tag', 'Export Button', ...
%                                 	'UserData', [], ...
%                                 	'Style', 'pushbutton', ...
%                                     'Units', 'normalized', ...
%                                 	'Position', [0.49 0.02 0.15 0.10], ...
%                                 	'FontWeight', 'bold', ...
%                                 	'ForegroundColor', [0 0 0.502], ...
%                                 	'String', 'Random',...
%                                     'Callback', @RandomButtonCallback);
% setappdata(obj.Handles.RandomButton,'Application',obj);
% obj.Handles.ExportButton = uicontrol('Parent', obj.Handles.Panel, ...
%                                     'Tag', 'Export Button', ...
%                                 	'UserData', [], ...
%                                 	'Style', 'pushbutton', ...
%                                     'Units', 'normalized', ...
%                                 	'Position', [0.65 0.02 0.15 0.10], ...
%                                 	'FontWeight', 'bold', ...
%                                 	'ForegroundColor', [0 0 0.502], ...
%                                 	'String', 'Export',...
%                                     'Callback', @ExportButtonCallback);
% setappdata(obj.Handles.ExportButton,'Application',obj);
% obj.Handles.ImportButton = uicontrol('Parent', obj.Handles.Panel, ...
%                                     'Tag', 'Import Button', ...
%                                 	'UserData', [], ...
%                                 	'Style', 'pushbutton', ...
%                                     'Units', 'normalized', ...
%                                 	'Position', [0.65 0.125 0.15 0.10], ...
%                                 	'FontWeight', 'bold', ...
%                                 	'ForegroundColor', [0 0 0.502], ...
%                                 	'String', 'Import',...
%                                     'Callback', @ImportButtonCallback);                                
% setappdata(obj.Handles.ImportButton,'Application',obj);


% function ExportButtonCallback(hObject,eventdata)
%          obj = getappdata(hObject,'Application');
%          if isempty(obj.CurrentFace), return; end
%          export(obj.CurrentFace);                 
% end
% function RandomButtonCallback(hObject,eventdata)
%          obj = getappdata(hObject,'Application');
%          if isempty(obj.Model), return; end
%          %obj.BaseCoeff = (-2.5 + 5*rand(obj.Model.nrEV,1)).*obj.Model.EigStd;
%          obj.BaseCoeff = randn(obj.Model.nrEV,1).*obj.Model.EigStd;
%          updateCurrentFace(obj,'RESET');
% end
% function ImportButtonCallback(hObject,eventdata)
%          obj = getappdata(hObject,'Application');
%          out = getMatFile('Select ImportCoeff');
%          if isempty(out), return; end
%          obj.BaseCoeff = out{1};
%          updateCurrentFace(obj,'RESET');
% end
% function AverageButtonCallback(hObject,eventdata)
%          obj = getappdata(hObject,'Application');
%          if isempty(obj.Model), return; end
%          obj.BaseCoeff = zeros(obj.Model.nrEV,1);
%          updateCurrentFace(obj,'RESET');
% end
% function BaseButtonCallback(hObject,eventdata)
%          obj = getappdata(hObject,'Application');
%          if isempty(obj.Model), return; end
%          obj.BaseCoeff = obj.CurrentCoeff;
%          updateCurrentFace(obj,'RESET');
% end
