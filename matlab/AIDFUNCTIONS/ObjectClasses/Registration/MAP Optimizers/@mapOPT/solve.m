function out = solve(obj,varargin)
         % reading input arguments into obj properties
           readVarargin(obj,varargin{:});
           if isempty(obj.ObjFun), error('Cannot Optimize: ObjFun not set'); end
         % if FS == Visible, set Show == 1
           obj.Show = obj.ObjFun.Floating.Visible;
%            obj.ObjFun.Floating.Visible = false; 
%            obj.ObjFun.Target.Visible = false;
         % Keep a handle copy of the original Floating surface
           obj.FloatingCopy = obj.ObjFun.Floating;
%            obj.FloatingCopy.ViewMode = 'Solid';
%            obj.FloatingCopy.Material = 'Dull';
%            obj.ObjFun.Floating.ViewMode = 'Solid';
%            obj.ObjFun.Floating.Material = 'Dull';
         % Start the Clock
           tic;
         % Initialization
           initialize(obj);
         % first Estep if asked
           if obj.Efirst
              Estep(obj);
           end
           if obj.Show
              v = get(obj.ObjFun.Floating.Axes,'UserData');
           end
         % Optimization
           while obj.Step <= obj.nrSteps% DETERMINISTIC ANNEALING (OUTER) LOOP
               initializeIL(obj);% iteration = 1;
               while obj.Iteration <= obj.MaxIter% INNER LOOP
                   % M-Step
                     Mstep(obj)% update Tmodel Parameters
                     obj.MstepEval = obj.MstepEval + 1;% Mstep is evaluated once more
                   % Check for Level update
                     if obj.LevelUpdate
                        % Remove previous Level Floating Surface 
                          delete(obj.ObjFun.Floating);
                        % Update Level
                          obj.Level = obj.Level+1;
                        % Create Floating Surface at new Level
                          obj.ObjFun.Floating = reduceFloating(obj);
                          %updateLevel(obj.ObjFun.Tmodel,obj.ObjFun.Solution,obj.ObjFun.Floating,obj.Type);
                        % Eval Current Situation at new Level
                          eval(obj.ObjFun);% Perform evaluation and update Solution for current Tmodel setting
                        % B values at new Level
                          update(obj.ObjFun.LatentV,obj.ObjFun.Tmodel);
                          updateSolution(obj.ObjFun);
                          border(obj.ObjFun.Solution);
                        % Update Tmodel parameters at new Level (Some
                        % Tmodels, require more parameters if the number of
                        % Floating surface points increase (ex, TPS
                        % nonrigid))                 
                          updateLevel(obj.ObjFun.Tmodel,obj.ObjFun.Solution,obj.ObjFun.Floating,obj.Type);
                          disp('Jumped to next Level');
                     else
                        % update Solution for current Tmodel setting 
                          updateSolution(obj.ObjFun);
                     end
                     if obj.Show
                         pause(0.0001);% give time to render
                         if v.Record
                            captureFrame(v);
                         end
                     end
                   % E-step at current or new Level
                     Estep(obj);% Update the CompleteP in obj.ObjFun (InlierP parameters, OutlierP Paramters, LatentV values)
                   % Compare Old and new situation
                     obj.Old.Change = obj.Change;
                     updateChange(obj);% Determine the amount of Change and store current situation
                   % Display feedback
                     if obj.Verbose, displayInfo(obj); end% Display output lines
                   % update iteration
                     obj.Iteration = obj.Iteration+1;
                   % Stopping Criterium     
                     %if (abs(obj.Change) < obj.ChangeTol)||(obj.Old.Change+obj.Change==0)% Later is oscilating change 
                     if (abs(obj.Change) < obj.ChangeTol)|| (FallbackTest(obj)) % Later is re-occuring function evaluation 
                         if obj.Level == obj.nrLevels||~isempty(obj.DA)% reached highest level or in DA sheme
                            obj.ExitFlag = ['Change is less than tolerance: ML(' num2str(obj.Level) ',' num2str(obj.nrLevels) ') DA(' num2str(obj.Step) ',' num2str(obj.nrSteps) ') \r'];
                            break; 
                         else
                             while ~obj.LevelUpdate% Fast Forward to next level
                                 obj.Iteration = obj.Iteration+1;
                             end
                         end% If change is small enough, break inner loop                
                     end
               end% Inner Loop
               % update step
                 obj.Step = obj.Step+1;
               % Update Temperature
                 updateTemp(obj);%(only if DetAnnealling exists), and Temp = 0 in last DA loop run;   
           end% Deterministic Annealling loop
         % Clean up used (reduced) Floating Surface  
           delete(obj.ObjFun.Floating);
           obj.ObjFun.Floating = obj.FloatingCopy;
         % Reduced at Highest Level?
           if (obj.nrPoints<obj.FloatingCopy.nrV)% Even at the highest level we had to reduce
               updateLevel(obj.ObjFun.Tmodel,obj.ObjFun.Solution,obj.ObjFun.Floating,obj.Type);
               eval(obj.ObjFun);% Eval Tmodel parameters and all on the Full Floating Surface;
               update(obj.ObjFun.LatentV,obj.ObjFun.Tmodel);
               updateSolution(obj.ObjFun);
               border(obj.ObjFun.Solution);
           end
           if obj.Show
              pause(0.0001);% give time to render
              if v.Record
                captureFrame(v);
              end
           end
         % Stop the clock
           obj.Time = toc;
           if obj.Verbose
              if isempty(obj.ExitFlag), obj.ExitFlag = 'Maximum number of iterations reached'; end
              disp(['Elapsed Time: ' num2str(obj.Time) ' seconds']);
              sprintf(obj.ExitFlag)
           end
         % Finalize
           finalize(obj);
           if obj.Show
              pause(0.0001);% give time to render
              if v.Record
                captureFrame(v);
              end
           end
         % take care of output;   
           if nargout == 1, out = clone(obj.ObjFun.Solution); end        
end