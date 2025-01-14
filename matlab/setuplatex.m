function setuplatex()
% This script changes all interpreters from tex to latex. 
list_factory = fieldnames(get(groot,'factory'));
index_interpreter = find(contains(list_factory,'Interpreter'));
for i = 1:length(index_interpreter)
    default_name = strrep(list_factory{index_interpreter(i)},'factory','default');
    set(groot, default_name,'latex');
end
set(groot,'defaultTextFontname', 'LMU Serif');
set(groot,'defaultTextFontsize',20);
set(groot,'defaultAxesFontSize',20);
end