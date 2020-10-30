function constructActionsPanel(obj)
% Panel
 obj.Handles.ActionsPanel = uipanel(...
 'Parent',obj.Handles.Panel,...
 'FontSize',10,...
 'FontWeight','bold',...
 'ForegroundColor',[0 0 0.502],...
 'Title','Actions',...
 'TitlePosition','centertop',...
 'Tag','Actions',...
 'Clipping','on',...
 'Position',[0.325358851674641 0.625607779578606 0.312599681020734 0.372771474878444],...
 'CreateFcn', {} );
 setappdata(obj.Handles.ActionsPanel,'Application',obj);
% SubPanel : for the active selection
obj.Handles.SelectedPanel = uipanel(...
'Parent',obj.Handles.ActionsPanel,...
'Title','Selected Assessment',...
'FontWeight','bold',...
'Tag','SelectedPanel',...
'Clipping','on',...
'Position',[0.0467532467532468 0.568047337278107 0.90 0.421301775147929],...
'CreateFcn', {} );
% buttons
obj.Handles.ImportScanButton = uicontrol(...
'Parent',obj.Handles.SelectedPanel,...
'Units','normalized',...
'Callback',@ImportScanCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.46 0.527472527472527 0.505583756345178 0.311073541842773],...
'String','Import Scan',...
'Tag','ImportScanButton',...
'Enable','off',...
'CreateFcn', {} );
setappdata(obj.Handles.ImportScanButton,'Application',obj);
obj.Handles.ImportNormButton = uicontrol(...
'Parent',obj.Handles.SelectedPanel,...
'Units','normalized',...
'Callback',@ImportNormCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.46 0.162299239222316 0.505583756345178 0.311073541842773],...
'String','Import Norm',...
'Enable','off',...
'Tag','ImportNormButton',...
'CreateFcn', {} );
setappdata(obj.Handles.ImportNormButton,'Application',obj);
obj.Handles.UpdateButton = uicontrol(...
'Parent',obj.Handles.SelectedPanel,...
'Units','normalized',...
'Callback',@UpdateCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.03 0.148774302620457 0.395939086294416 0.689771766694844],...
'String','Update',...
'Enable','off',...
'Tag','UpdateButton',...
'CreateFcn', {} );
setappdata(obj.Handles.UpdateButton,'Application',obj);
% Subpanel for all assesssments
obj.Handles.AllPanel = uipanel(...
'Parent',obj.Handles.ActionsPanel,...
'Title','All Assessments',...
'FontWeight','bold',...
'Tag','AllPanel',...
'Clipping','on',...
'Position',[0.0467532467532468 0.0473372781065089 0.90 0.5],...
'CreateFcn', {} );
% Buttons
obj.Handles.ImportAllButton = uicontrol(...
'Parent',obj.Handles.AllPanel,...
'Units','normalized',...
'Callback',@ImportAllCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.0494845360824742 0.68 0.896907216494845 0.250510551395507],...
'String','Import All',...
'Enable','on',...
'Tag','ImportAllButton',...
'CreateFcn', {} );
setappdata(obj.Handles.ImportAllButton,'Application',obj);
obj.Handles.UpdateAllButton = uicontrol(...
'Parent',obj.Handles.AllPanel,...
'Units','normalized',...
'Callback',@UpdateAllCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.0494845360824742 0.38 0.896907216494845 0.250510551395507],...
'String','Update All',...
'Enable','on',...
'Tag','UpdateAllButton',...
'CreateFcn', {} );
setappdata(obj.Handles.UpdateAllButton,'Application',obj);
obj.Handles.AverageButton = uicontrol(...
'Parent',obj.Handles.AllPanel,...
'Units','normalized',...
'Callback',@AverageCallback,...
'FontWeight','bold',...
'ForegroundColor',[0 0 0.502],...
'Position',[0.0494845360824742 0.08 0.896907216494845 0.250510551395507],...
'String','Average All',...
'Enable','on',...
'Tag','AverageButton',...
'CreateFcn', {} );
setappdata(obj.Handles.AverageButton,'Application',obj);
end
%% SINGLE CALLBACKS
function ImportScanCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         if obj.Active == 0, return; end
         obj.ActiveAssessment.Scan = meshObj.import;
         updateActiveAssessment(obj);
end
function ImportNormCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         if obj.Active == 0, return; end
         obj.ActiveAssessment.Norm = meshObj.import;
         updateActiveAssessment(obj);
end
function UpdateCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         obj.Status = 'busy';
         update(obj.ActiveAssessment);
         updateActiveAssessment(obj);
         obj.Status = 'ready';
end
%% All CALLBACKS
function UpdateAllCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         if isempty(obj.AssessmentList), return; end
         f = statusbar('Updating All');drawnow;
         for i=1:1:obj.NrAssessments
             ass = obj.AssessmentList{i};
             ass.CompensateScale = get(obj.Handles.CompensateScaleBox,'Value');
             ass.Significance = str2double(get(obj.Handles.RobustnessLevelEdit,'String'));
             ass.OutliersOnly = get(obj.Handles.OutliersOnlyBox,'Value');
             ass.OutliersBinary = get(obj.Handles.OutliersBinaryBox,'Value');
             ass.OutliersThreshold = str2double(get(obj.Handles.OutliersBinaryEdit,'String'));
             switch get(obj.Handles.LocalBox,'Value'); 
                 case 1
                     ass.Threshold = getappdata(obj.Handles.LocalEdit,'LocalThresholds');
                 case 0
                     ass.Threshold = str2double(get(obj.Handles.GlobalEdit,'String'));
             end
             if isempty(ass.Scan), continue; end
             if isempty(ass.Norm), continue; end
             update(ass);
             if i==obj.Active
                 updateActiveAssessment(obj);
             else
                updateTable(obj,i);
             end
             statusbar(i/obj.NrAssessments,f);drawnow;
         end
         delete(f);drawnow;
end
function AverageCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         if isempty(obj.AssessmentList), return; end
         counter = 0;
         avg = [];
         f = statusbar('Averaging');drawnow;
         for i=1:1:obj.NrAssessments
             statusbar(i/obj.NrAssessments,f);drawnow;
             if obj.AssessmentList{i}.Update, continue; end
             if counter == 0
                avg = clone(obj.AssessmentList{i});
                if~isempty(avg.Scan.TextureMap), delete(avg.Scan.TextureMap); end
                if~isempty(avg.Scan.PoseLM), delete(avg.Scan.PoseLM); end
                if~isempty(avg.Scan.Border), delete(avg.Scan.Border); end
                avg.Scan.TextureColor = [];avg.Scan.UV = [];
                avg.Scan.ColorMode = 'Single';
                if~isempty(avg.Norm.TextureMap), delete(avg.Norm.TextureMap); end
                if~isempty(avg.Norm.PoseLM), delete(avg.Norm.PoseLM); end
                if~isempty(avg.Norm.Border), delete(avg.Norm.Border); end
                avg.Norm.TextureColor = [];avg.Norm.UV = [];
                avg.Norm.ColorMode = 'Single';
             else
                out =  alignPose(obj.AssessmentList{i}.Scan,avg.Scan,nan); 
                avg.Scan.Vertices = avg.Scan.Vertices+out.Vertices;
                delete(out);
                out =  alignPose(obj.AssessmentList{i}.Norm,avg.Norm,nan); 
                avg.Norm.Vertices = avg.Norm.Vertices+out.Vertices;
                delete(out);
                avg.Dysmorphogram = avg.Dysmorphogram+obj.AssessmentList{i}.Dysmorphogram;
                avg.PercDysmorph = avg.PercDysmorph+obj.AssessmentList{i}.PercDysmorph;
                avg.ThresholdMap = avg.ThresholdMap+obj.AssessmentList{i}.ThresholdMap;
                avg.PercThresh = avg.PercThresh+obj.AssessmentList{i}.PercThresh;
                avg.DistanceMap = avg.DistanceMap+obj.AssessmentList{i}.DistanceMap;
                avg.RMSE = avg.RMSE+obj.AssessmentList{i}.RMSE;
             end
             counter = counter+1;   
         end
         delete(f);
         if isempty(avg), msgbox('Update Assessments before averaging'); return; end
         avg.Scan.Vertices = avg.Scan.Vertices/counter;
         avg.Norm.Vertices = avg.Norm.Vertices/counter;
         avg.Dysmorphogram = avg.Dysmorphogram/counter;
         avg.PercDysmorph = avg.PercDysmorph/counter;
         avg.ThresholdMap = avg.ThresholdMap/counter;
         avg.PercThresh = avg.PercThresh/counter;
         avg.DistanceMap = avg.DistanceMap/counter;
         avg.RMSE = avg.RMSE/counter;
         avg.Tag = 'Average';
         avg.Scan.Tag = 'Average Scan';
         avg.Norm.Tag = 'Average Norm';
         avg.Norm.Selected = true;
         centerVertices(avg.Norm);
         centerVertices(avg.Scan);
         obj.AssessmentList{end+1} = avg;
         updateTable(obj,obj.NrAssessments);
end
function ImportAllCallback(hObject,eventdata)
         obj = getappdata(hObject,'Application');
         ScanDirectory = uigetdir(pwd,'Scan Directory');
         if ScanDirectory==0, return; end
         NormDirectory = uigetdir(ScanDirectory,'Norm Directory');
         if NormDirectory==0, return; end
         cd(ScanDirectory);
         scanfiles = dir('*.mat');
         nrscanfiles = size(scanfiles,1);
         cd(NormDirectory);
         normfiles = dir('*.mat');
         nrnormfiles = size(normfiles,1);
         f = statusbar('Importing');drawnow;
         for i=1:1:nrscanfiles
             scanname = cleanUpString(scanfiles(i).name(1:end-4));
             hasNorm = false;
             for j=1:1:nrnormfiles
                 normname = cleanUpString(normfiles(j).name(1:end-4));
                 if ~isempty(strfind(scanname,normname))
                    hasNorm = true;
                    break;
                 end
             end
             if ~hasNorm, continue; end
             ass = assessment;
             ass.Tag = ['Ass_' scanname];
             cd(ScanDirectory);
             in = load(scanfiles(i).name);
             loaded = fields(in);
             ass.Scan = in.(loaded{1});
             ass.Scan.Tag = scanname;
             cd(NormDirectory)
             in = load(normfiles(j).name);
             loaded = fields(in);
             ass.Norm = in.(loaded{1});
             ass.Norm.Tag = normname;
             obj.AssessmentList{end+1} = ass;
             updateTable(obj,obj.NrAssessments);
             statusbar(i/nrscanfiles,f);drawnow; 
         end
         delete(f);drawnow;
end