function ProgressCreate( Text, Value )
%PROGRESSCREATE create fastrbf progress bar
%   H = PROGRESSCREATE('title') creates and displays a progress bar.
%   The figure handle of the progress bar dialog is returned in H.
%
%   H = PROGRESSCREATE('title',V) creates the progress bar with
%   initial value V, which should be between 0 and 1.
%
%   See also PROGRESSUPDATE, PROGRESSCLOSE

% Copyright 2001 Applied Research Associates NZ Ltd

if nargin == 1
  Value = 0;
end
Value = max(0,min(100*Value,100));

color = get(0, 'DefaultUIControlBackgroundColor');

oldRootUnits = get(0, 'Units');
set(0, 'Units', 'pixels');
screen = get(0, 'ScreenSize');
set(0, 'Units', oldRootUnits);

f = figure(...
    'Name', 'FastRBF Progress', ...
    'Resize', 'off', ...
    'CreateFcn', '', ...
    'NumberTitle', 'off', ...
    'IntegerHandle', 'off', ...
    'Color', color, ...
    'MenuBar', 'none', ...
    'Tag', 'FastRBFProgress',...
    'UserData', logical(0), ...  % cancel flag stored in userdata
    'Visible', 'off');

aw = 300;
ah = 15;
a = axes(...
    'Parent', f, ...
    'XLim', [0 100], ...
    'YLim', [0 1], ...
    'Box', 'off', ...
    'Units', 'pixels', ...
    'Position', [0 0 aw ah], ...
    'Color', 0.8*color, ...
    'XColor', 0.8*color, ...
    'YColor', 0.8*color, ...
    'XTickMode', 'manual', ...
    'YTickMode', 'manual', ...
    'XTick', [], ...
    'YTick', [], ...
    'XTickLabelMode', 'manual', ...
    'XTickLabel', [], ...
    'YTickLabelMode', 'manual',...
    'YTickLabel', []);

c = uicontrol(...
    'Parent', f, ...
    'Units', 'pixels', ...
    'Style', 'pushbutton', ...
    'String', 'Abort', ...
    'tag', 'abort', ...
    'callback', 'ProgressCancel(gcbf)');
[cw,ch] = HandleSize(c);

t = uicontrol(...
    'Parent', f, ...
    'Units', 'pixels', ...
    'Style', 'text', ...
    'Tag', 'text', ...
    'String', Text);
[tw,th] = HandleSize(t);

% positions
fw = aw + 30;

cx = (fw - cw)/2;
cy = 10;
ax = 15;
ay = cy + ch + 10;
tw = aw;
tx = ax;
ty = ay + ah + 10;

fh = ty + th + 10;
fx = (screen(3) - fw)/2;
fy = (screen(4) - fh)/2;

set(c, 'Position', [cx cy cw ch]);
set(a, 'Position', [ax ay aw ah]);
set(t, 'Position', [tx ty tw th]);
set(f, 'Position', [fx fy fw fh]);

% Contents

% colormap
t = (1:20)'/20;
z = zeros(20,1);
cmap = [z, z, z+0.7 + t*0.3];
set(f, 'ColorMap', cmap);

% background patch
%xpatch = [0 100 100 0];
%patch(xpatch,ypatch,0.8*color,'EdgeColor', 'none');

% bar patch
ypatch = [-1 -1 2 2];
xpatch = [0 Value Value 0];
cpatch = [0 1 1 0];
p = patch(xpatch,ypatch,cpatch,'EdgeColor','none','tag','bar',...
	  'EraseMode','none');

set(f,'HandleVisibility','callback','visible','on');

set(0, 'Units', oldRootUnits);

% text in middle of bar
txt = text(50, 0.5, '', ...
	   'Parent', a, ...
	   'Tag', 'bartext', ...
	   'Visible', 'off', ...
	   'Color', [0 0 0.5], ...
	   'FontUnits', 'pixels', 'FontSize', ah-4, ...
	   'HorizontalAlignment', 'center', ...
	   'VerticalAlignment', 'middle');

% shaded frame around the axes
cdark = 0.4*color;
clight = min(1.4*color, [1 1 1]);
set(a, 'units', 'pixels');
axpos = get(a, 'position');
x = axpos(1) - 1;
y = axpos(2) - 1;
w = axpos(3) + 1;
h = axpos(4) + 1;
args = {f, 'style', 'frame', 'units', 'pixels'};
uicontrol(args{:}, 'foregroundcolor', clight, 'position', [x+1 y w-1 1]);
uicontrol(args{:}, 'foregroundcolor', cdark,  'position', [x y+h w 1]);
uicontrol(args{:}, 'foregroundcolor', clight, 'position', [x+w y 1 h]);
uicontrol(args{:}, 'foregroundcolor', cdark,  'position', [x y+1 1 h-1]);

%-------------------------------------------------------------------

function [w,h] = HandleSize(H)

pos = get(H, 'position');
w = pos(3);
h = pos(4);