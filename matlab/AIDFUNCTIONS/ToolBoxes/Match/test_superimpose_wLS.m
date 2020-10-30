close all;clear all;
% initialize A
A = [0,1,0,1,0,1,0,1,0.5;0,0,1,1,0,0,1,1,1.5;0,0,0,0,1,1,1,1,0.5];
nbpts = size(A,2);
dim = size(A,1);
Apinoc = A;
Apinoc(2,nbpts) = 10.5;
LMA = LMObj('Vertices',A);v = viewer(LMA);v.AxesVisible = true;v.AxesGrid = true;

% take B as a scaled, translated and rotated version of Apinoc
scaleFactor = 3;
translationB = [2;-1;0.5];
translate = repmat(translationB,1,nbpts);
rotvect = [pi/3*2;pi/4;pi/8];
rotMatrix = rodrigues(rotvect);
% 
% B = Apinoc.*scaleFactor;
% B = rotMatrix*B;
% B = B + translate;

B = scaleFactor*(rotMatrix*Apinoc)+translate;
LMB = LMObj('Vertices',B);LMB.Axes = LMA.Axes;LMB.Visible = true;LMB.SingleColor = [1 0 0];

% weights
w = ones(1,nbpts);
w(nbpts) = 0;
T = rigidTM;
match(T,A,B,w);
out = transform(T,B);

LMout = LMObj('Vertices',out);
LMout.Axes = LMA.Axes;
LMout.Visible = true;LMout.SingleColor = [0 1 0];


% superimpose and check the result
T_SVD = superimpose_wLS_SVD(A,B,w)
T_moment = superimpose_wLS_moment(A,B,w)

A = A(1:3,:)
B_SVD = T_SVD*B;
B_moment = T_moment*B;
B_SVD = B_SVD(1:3,:)
B_moment = B_moment(1:3,:)


LMB_moment = LMObj('Vertices', B_moment); LMB_moment.Axes = LMA.Axes;LMB_moment.Visible = true;LMB_SVD.SingleColor = [0 1 0];