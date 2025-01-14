clear, close all
setuplatex
DATASET = 'joinedDatasets';
MODALITY = 'asymmetry';
REDUCTION = 1;
switch REDUCTION
    case 1
        SUBSAMPLED_ID = 'not_subsampled';
    case 10
        SUBSAMPLED_ID = 'not_subsampled';
    otherwise
        error("REDUCTION=1 or 10")
end
DATASET_ID= [DATASET '/mean_imputed/' SUBSAMPLED_ID];
geneSets = {'Cahoy', 'Multi_tissue_chromatin', 'GTEx_brain' ,'Multi_tissue_gene_expr'};
sizes = [3, 489, 13, 205];
for ind=1:length(geneSets)
    geneSet = geneSets{ind};
    out_dir = ['../results/' MODALITY '/ldsc/' DATASET_ID '/h2-cts/'  geneSet '/'];
    inp_file = [out_dir 'h2_results.csv'];
    inp = readtable(inp_file);
    disp(geneSet)
    disp(strjoin(unique(inp.Name),'\n'))
        
    if iscellstr(inp.Coefficient_P_value)
        na_mask = cellfun(@(x)(strcmp(x,'NA')), inp.Coefficient_P_value);
        inp.Coefficient_P_value(na_mask) = {'nan'};
        inp.Coefficient_P_value = cellfun(@(x)(str2double(x)), inp.Coefficient_P_value);
    end
    if iscellstr(inp.Coefficient)
        na_mask = cellfun(@(x)(strcmp(x,'NA')), inp.Coefficient);
        inp.Coefficient(na_mask) = {'nan'};
        inp.Coefficient = cellfun(@(x)(str2double(x)), inp.Coefficient);
    end
    disp(max(inp.Coefficient))
    bmask = ~(isnan(inp.Coefficient_P_value) | (inp.Coefficient_P_value>0.05/sizes(ind))); %Bonferroni correction
    inp = inp(bmask,:);
    names = unique(inp.Name);
    ret_p = nan(length(names), 31);
    ret_c = nan(length(names), 31);
    for row=1:height(inp)
        m = strcmp(names, inp.Name(row));
        ret_p(m,inp.partition(row)) = inp.Coefficient_P_value(row);
        ret_c(m,inp.partition(row)) = inp.Coefficient(row);
    end
    
    ret_mask = any(isfinite(ret_p),2);
    if ~any(ret_mask)
        continue
    end
    ret_p = ret_p(ret_mask, :);
    ret_c = ret_c(ret_mask, :);
    names = names(ret_mask);
    names = cellfun(@(x)strip(replace(x, '_', ' ')),names, 'UniformOutput',false);
    sc_mask = any(isfinite(ret_p),1);
    sc_pars = 1:31;
    sc_pars = sc_pars(sc_mask);
    [fig, ax] = makeHeatmap(ret_p(:, sc_pars)', names, 1);
    set(ax, 'ytick', 1:length(sc_pars));
    yticklabels(ax, sc_pars);
    set(ax,'YMinorTick', 'off');
    saveas(fig, [out_dir 'ldsc_seg_pHeatmap.svg']);
    [fig, ax] = makeHeatmap(ret_c(:, sc_pars)', names, 0);
    set(ax, 'ytick', 1:length(sc_pars));
    yticklabels(ax, sc_pars);
    set(ax,'YMinorTick', 'off');
    saveas(fig, [out_dir 'ldsc_seg_heatmap.svg']);
    
%     saveas(fig, [out_dir 'c_heatmap.svg'])
    featMats{1} = ret_p';
    featMatsIds{1} = 'p_value';
%     featMats{2} = ret_c';
%     featMatsIds{2} = 'coeff';
    featsClassesNames = names;
%     if ind==2
%         drawFeaturesOnPolarPartitionsGraph(featMats, featMatsIds, featsClassesNames, MODALITY, out_dir, REDUCTION, 1)
%     end
end

