function GWAS = LoadFACIALGWASScript
    %% LOADING FACE GWAS
    %close all;clear all;
    %facialpath = '/uz/data/avalok/mic/tmp/pclaes4/==MATLAB==/ActiveProjects/2018/METAEUROGWAS/DATA/';
    disp('Loading Local FACIAL GWAS');
    facialpath = '/home/pclaes4/Documents/MATLAB/FACEGWAS/';% locally stored on micdp02
    INPUTPATH = [facialpath '/SNPJOBSINTERSECTpoint8/'];
    OUTPUTPATH = [facialpath '/OUTPUTINTERSECT_FULLSTATS/'];
    facialpath = '/uz/data/avalok/mic/tmp/pclaes4/==MATLAB==/ActiveProjects/2018/METAEUROGWAS/DATA/';
    PHENOPATH = [facialpath 'PHENOTYPES/'];
    in = load([PHENOPATH 'DATAB_0727']);
    DB = cell(1,2);
    nDB = 2;
    DB{1}.nSegments = 63;
    DB{2}.nSegments = 63;
    DB{1}.IID = in.DATABASE{1}.IID;DB{1}.nSubj = length(DB{1}.IID);
    DB{2}.IID = in.DATABASE{2}.IID;DB{2}.nSubj = length(DB{2}.IID);
    clear in;
    cd(facialpath);
    %% OPEN WORKERS IF YOU DON'T HAVE ANY YET
    try
        parpool('LocalSingle',30);
    catch
    end
    %% LOAD FACIAL GWAS US ONLY
    db = 1;
    %% PREPARE DATA CONTAINERS
    cd(INPUTPATH);files = dir('**/*.mat');% retrieve all job folders recursively
    nJOBS = length(files);
    nSNPperJOB = 2000;
    RS = cell(nSNPperJOB,nJOBS);
    POS = zeros(nSNPperJOB,nJOBS,'uint32');
    A1 = cell(nSNPperJOB,nJOBS);
    A2 = cell(nSNPperJOB,nJOBS);
    MAF = zeros(nSNPperJOB,nJOBS,'uint8');
    CHR = zeros(nSNPperJOB,nJOBS,'uint8');
    P = zeros(nSNPperJOB,DB{db}.nSegments,nDB,nJOBS,'uint32');
    N = zeros(nSNPperJOB,2,nJOBS,'uint16');
    factor = 10000;
    %% HOUSEHOLDING, making sure that the JOBS will be loaded in order
    CHRID = zeros(1,nJOBS);
    JOBID = zeros(1,nJOBS);
    for i=1:nJOBS
        % i=1;
        ind = strfind(files(i).folder,'CHR');
        CHRID(i) = str2double(files(i).folder(ind+3:end));
        ind = strfind(files(i).name,'.');
        JOBID(i) = str2double(files(i).name(4:ind-1));
    end
    [~,index] = sort(CHRID,'ascend');% order in chromosome
    files = files(index);
    CHRID = zeros(1,nJOBS);
    JOBID = zeros(1,nJOBS);
    for i=1:nJOBS
        % i=1;
        ind = strfind(files(i).folder,'CHR');
        CHRID(i) = str2double(files(i).folder(ind+3:end));
        ind = strfind(files(i).name,'.');
        JOBID(i) = str2double(files(i).name(4:ind-1));
    end
    for i=1:1:max(CHRID)% order within each chromosome in ascending JOB order
       ind = find(CHRID==i);
       [~,index] = sort(JOBID(ind),'ascend');
       files(ind) = files(ind(index));
    end
    CHRID = zeros(1,nJOBS);
    JOBID = zeros(1,nJOBS);
    for i=1:nJOBS
        % i=1;
        ind = strfind(files(i).folder,'CHR');
        CHRID(i) = str2double(files(i).folder(ind+3:end));
        ind = strfind(files(i).name,'.');
        JOBID(i) = str2double(files(i).name(4:ind-1));
    end
    %% LOAD RESULTS
    [path,ID] = setupParForProgress(nJOBS);tic;
    parfor i=1:nJOBS
        % i=1;
    %     disp(num2str(i));
        inputpath = [INPUTPATH 'CHR' num2str(CHRID(i)) '/'];
        outputpath = [OUTPUTPATH 'CHR' num2str(CHRID(i)) '/'];
        inputfile = [inputpath 'JOB' num2str(JOBID(i)) '.mat'];
        outputfile = dir([outputpath num2str(JOBID(i)) '_*']);
        if isempty(outputfile), continue; end
        outputfile = [outputpath outputfile(1).name];
        in = load(inputfile);
        % COUNTING INDIVIDUALS DATASET 1
        JOB = in.JOB{1};
        [ind12,ind21] = vlookupFast(DB{1}.IID,JOB.IID);% match subjects having both genotypes and phenotypes
        JOB.SNP = JOB.SNP(ind12,:);% extract SNP data from overlapping subjects
        N1 = sum(JOB.SNP>=0,1);
        % COUNTING INDIVIDUALS DATASET 2
        JOB = in.JOB{2};
        [ind12,ind21] = vlookupFast(DB{2}.IID,JOB.IID);% match subjects having both genotypes and phenotypes
        JOB.SNP = JOB.SNP(ind12,:);% extract SNP data from overlapping subjects
        N2 = sum(JOB.SNP>=0,1);
        JOB = in.JOB{db};
        JOB.RSID = in.JOB{2}.RSID;% TAKE UK AS REFERENCE, since it contains proper RS numbers
        [ind12,ind21] = vlookupFast(DB{db}.IID,JOB.IID);% match subjects having both genotypes and phenotypes
        JOB.SNP = JOB.SNP(ind12,:);% extract SNP data from overlapping subjects
        nSNP = length(JOB.POS);
        maf = zeros(nSNP,1);
        a1 = cell(nSNP,1);
        a2 = cell(nSNP,1);
        for s=1:1:nSNP
           % s=1;
           geno = JOB.SNP(:,s);  
           [geno,flip] = codetoM(geno);
%            if flip
%                a1{s} = JOB.A2{s};
%                a2{s} = JOB.A1{s};
%            else
%                a1{s} = JOB.A1{s};
%                a2{s} = JOB.A2{s};
%            end
           a1{s} = JOB.A1{s};
           a2{s} = JOB.A2{s};
           maf(s) = getMAF(geno);
           JOB.SNP(:,s) = geno;
        end   
        if nSNP==nSNPperJOB
           RS(:,i) = JOB.RSID(:);
           A1(:,i) = a1(:);
           A2(:,i) = a2(:);
           POS(:,i) = uint32(JOB.POS(:));
           CHR(:,i) = JOB.CHRID(:);
           N(:,:,i) = uint16([N1(:), N2(:)]);
           MAF(:,i) = uint8(100*maf(:));
        else
           tmpRS = cell(nSNPperJOB,1);tmpRS(1:nSNP) = JOB.RSID;RS(:,i) = tmpRS(:);
           tmpA1 = cell(nSNPperJOB,1);tmpA1(1:nSNP) = a1;A1(:,i) = tmpA1(:);
           tmpA2 = cell(nSNPperJOB,1);tmpA2(1:nSNP) = a2;A2(:,i) = tmpA2(:);
           tmpPOS = zeros(nSNPperJOB,1);tmpPOS(1:nSNP) = JOB.POS;POS(:,i) = uint32(tmpPOS(:));
           tmpCHR = zeros(nSNPperJOB,1);tmpCHR(1:nSNP) = JOB.CHRID;CHR(:,i) = uint8(tmpCHR(:));
           tmpMAF = zeros(nSNPperJOB,1);tmpMAF(1:nSNP) = uint8(100*maf(:));MAF(:,i) = tmpMAF;
           tmpN = zeros(nSNPperJOB,2);tmpN(1:nSNP,:) = uint16([N1(:), N2(:)]);N(:,:,i) = tmpN;
        end
        in = load(outputfile);
        in = in.in;
        p = in.pfastvalues;
        if nSNP==nSNPperJOB
           P(:,:,:,i) = uint32(factor*-log10(p));
        else
           tmpP = zeros(nSNPperJOB,DB{db}.nSegments,nDB,'uint32');tmpP(1:nSNP,:,:) = uint32(factor*-log10(p));P(:,:,:,i)=tmpP; 
        end
        parfor_progress;
    end
    closeParForProgress(path,ID);toc;
    %% REDUCING DATA
    TEST = sum(POS,1);
    FinishedJOBs = find(TEST);
    nFinishedJOBs = length(FinishedJOBs);% when GWAS is fully finished this is not an issue , and all jobs will be finished
    POS = POS(:,FinishedJOBs);POS = POS(:);index = find(POS);POS = POS(index);% take zero positions, since these are empty data containers
    nSNP = length(POS);
    disp([num2str(nFinishedJOBs) ' Jobs Finished / ' num2str(nSNP) ' SNPs analyzed']);

    RS = RS(:,FinishedJOBs);RS = RS(:);RS = RS(index);
    A1 = A1(:,FinishedJOBs);A1 = A1(:);A1 = A1(index);
    A2 = A2(:,FinishedJOBs);A2 = A2(:);A2 = A2(index);
    CHR = CHR(:,FinishedJOBs);CHR = CHR(:);CHR = CHR(index);
    MAF = MAF(:,FinishedJOBs);MAF = MAF(:);MAF = MAF(index);

    N = N(:,:,FinishedJOBs);
    N = permute(N,[1 3 2]);
    N = reshape(N,size(N,1)*size(N,2),size(N,3));
    N = N(index,:);

    P = P(:,:,:,FinishedJOBs);
    P = permute(P,[1 4 2 3]);
    P = reshape(P,size(P,1)*size(P,2),size(P,3),size(P,4));
    P = P(index,:,:);

    GWAS.CHR = CHR;
    GWAS.POS = POS;
    GWAS.RS = RS;
    GWAS.A1 = A1;
    GWAS.A2 = A2;
    GWAS.MAF = MAF;
    GWAS.P = P;
    GWAS.N = N;
    clear CHR POS RS A1 A2 MAF P N;
    %% THE END
end