function parents = selectionstochunif(obj)
%SELECTIONSTOCHUNIF Choose parents using stochastic universal sampling (SUS).
%   PARENTS = SELECTIONSTOCHUNIF(EXPECTATION,NPARENTS,OPTIONS) chooses the 
%   PARENTS using roulette wheel and uniform sampling, based on EXPECTATION 
%   and number of parents NPARENTS. 
%
%   Example:
%   Create an options structure using SELECTIONSTOCHUNIF as the selection
%   function
%     options = gaoptimset('SelectionFcn', @selectionstochunif);

%   Given a roulette wheel with a slot for each expectation whose size is 
%   equal to the expectation. We then step through the wheel in equal size 
%   steps, so as to cover the entire wheel in nParents steps. At each step, 
%   we create a parent from the slot we have landed in. This mechanism is 
%   fast and accurate.

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/29 08:25:36 $
expectation = obj.scaledScores;
nParents = obj.nrParents;
expectation = expectation(:,1);
wheel = cumsum(expectation) / nParents;

parents = zeros(1,nParents);

% we will step through the wheel in even steps.
stepSize = 1/nParents;

% we will start at a random position less that one full step
position = rand * stepSize;

% a speed optimization. Position is monotonically rising.
lowest = 1; 

for i = 1:nParents % for each parent needed,
    for j = lowest:length(wheel) % find the wheel position
        if(position < wheel(j)) % that this step falls in.
            parents(i) = j;
            lowest = j;
            break;
        end
    end
    position = position + stepSize; % take the next step.
end
parents = parents(randperm(length(parents)));
   