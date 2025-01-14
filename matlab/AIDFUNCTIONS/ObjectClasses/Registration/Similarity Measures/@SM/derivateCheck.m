function derivateCheck(obj,Tmodel,FS,Pindex)
            % initialize both
                initialize(Tmodel,FS);
                initialize(obj,Tmodel);           
            % Derivate 
                Tmodel.ActiveP = Pindex;
                derivateField(Tmodel,FS,'All');
                derivate(obj,Tmodel);
                D = sumDerivative(obj);           
                delta = Tmodel.d(Pindex);
            % initialize loop
                range = (-delta/2:delta/5:delta/2);
                %eval(obj,Tmodel);
                %out = sumEvaluation(obj);
                values = zeros(1,length(range));
                grads = sumEvaluation(obj)*ones(1,length(range));
                origP = Tmodel.P;
            % Do loop
                for i=1:1:length(range)
                    Tmodel.P = origP;
                    Tmodel.P(Pindex) = origP(Pindex) + delta*range(i);
                    eval(Tmodel,FS);
                    eval(obj,Tmodel);
                    values(i) = sumEvaluation(obj);
                    grads(i) = grads(i) + delta*range(i)*D;%sumDerivative(obj);
                end
            % Reset Tmodel    
                Tmodel.P = origP;
            % Plot Result    
                figure; hold on;
                plot(values,'b-','LineWidth',1.5);
                plot(grads,'r-','LineWidth',1);            
end