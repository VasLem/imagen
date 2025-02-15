function out = getModel(obj,D)
% out = getModel(obj,in) or getModel(obj,in)
% Compute a PCA space based on give training data
% INPUT
% obj = PCA space object
% in = Data matrix or Data structure, missing data must be represented by
% Nan values and imputation is used to deal with them
% OUTPUT
% out = new PCA space object or out = updated obj;
%
% created by Peter Claes
    if nargout == 1,obj = clone(obj);out = obj;end
    D = getData(obj,D);
    if isempty(obj.AvgVec), getAverage(obj,D); end
    nanIndex = find(isnan(D));
    if isempty(nanIndex),performPCA(obj,D);return;end
    % INITIAL IMPUTATION
        disp('Initial Imputation');
        % Define aid information
        nrSamples = size(D,2);
        wD = ones(size(D),'uint8');
        wD(nanIndex) = 0;
        [nanRow,nanCol] = ind2sub(size(D),nanIndex);
        nanCol = unique(nanCol);
        % look for complete measurements
        Col = setdiff((1:nrSamples),nanCol);
        recD = D;
        if length(Col)>3% we have enough complete measurements to start
           disp('partial set of complete measurements');
           %size(D(:,Col))
           length(Col)
           %initModel = getModel@PCA(obj,D(:,Col)');
           initModel = getModel@PCA(obj,D(:,Col));
           stripPercVar(initModel,98);
           for i=1:1:length(nanCol)
               out = partialFit(initModel,D(:,nanCol(i)),find(wD(:,nanCol(i))));
               tmp = Coeff2Vec(initModel,out);
               index = find(isnan(D(:,nanCol(i))));
               recD(index,nanCol(i)) = tmp(index);
               clear tmp index;
           end
        else % otherwise we need the average to impute
            disp('using average');
            tmp = repmat(obj.AvgVec,1,nrSamples);
            recD(nanIndex) = tmp(nanIndex);
            clear tmp;
        end
     % ITERATIVE IMPUTATION
        disp('Iterative Imputation');
        %keyboard;
        for i=95:1:99% using increased percentage of variance
            disp(num2str(i));
            getModel@PCA(obj,recD);
            stripPercVar(obj,i);
            if obj.Centering
                tmp = repmat(obj.AvgVec,1,obj.n) + obj.EigVec*obj.Tcoeff';
            else
                tmp = obj.EigVec*obj.Tcoeff';
            end
            recD(nanIndex) = tmp(nanIndex);
        end
        getModel@PCA(obj,recD);
        % stripping of any eigenvalues that are 0
end

function performPCA(obj,D)
         %if obj.Centering,D = (double(D) - repmat(obj.AvgVec,1,size(D,2)))';end
         D = (double(D) - repmat(obj.AvgVec,1,size(D,2)))';
         if size(D,1) < size(D,2)
            [obj.EigVec,obj.Tcoeff,obj.EigVal] = my_princomp(D,'econ');
         else
            [obj.EigVec,obj.Tcoeff,obj.EigVal] = my_princomp(D);
         end
         index = find(obj.EigVal==0);
         if isempty(index), return; end
         reduceNrPc(obj,index(1)-1);
end

function [coeff, score, latent, tsquare] = my_princomp(x,econFlag)
%PRINCOMP Principal Components Analysis.
%   COEFF = PRINCOMP(X) performs principal components analysis on the N-by-P
%   data matrix X, and returns the principal component coefficients, also
%   known as loadings.  Rows of X correspond to observations, columns to
%   variables.  COEFF is a P-by-P matrix, each column containing coefficients
%   for one principal component.  The columns are in order of decreasing
%   component variance.
%
%   PRINCOMP centers X by subtracting off column means, but does not
%   rescale the columns of X.  To perform PCA with standardized variables,
%   i.e., based on correlations, use PRINCOMP(ZSCORE(X)).  To perform PCA
%   directly on a covariance or correlation matrix, use PCACOV.
%
%   [COEFF, SCORE] = PRINCOMP(X) returns the principal component scores,
%   i.e., the representation of X in the principal component space.  Rows
%   of SCORE correspond to observations, columns to components.
%
%   [COEFF, SCORE, LATENT] = PRINCOMP(X) returns the principal component
%   variances, i.e., the eigenvalues of the covariance matrix of X, in
%   LATENT.
%
%   [COEFF, SCORE, LATENT, TSQUARED] = PRINCOMP(X) returns Hotelling's
%   T-squared statistic for each observation in X.
%
%   When N <= P, SCORE(:,N:P) and LATENT(N:P) are necessarily zero, and the
%   columns of COEFF(:,N:P) define directions that are orthogonal to X.
%
%   [...] = PRINCOMP(X,'econ') returns only the elements of LATENT that are
%   not necessarily zero, i.e., when N <= P, only the first N-1, and the
%   corresponding columns of COEFF and SCORE.  This can be significantly
%   faster when P >> N.
%
%   See also FACTORAN, PCACOV, PCARES.

%   References:
%     [1] Jackson, J.E., A User's Guide to Principal Components,
%         Wiley, 1988.
%     [2] Jolliffe, I.T. Principal Component Analysis, 2nd ed.,
%         Springer, 2002.
%     [3] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, 1988.
%     [4] Seber, G.A.F., Multivariate Observations, Wiley, 1984.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.9.2.6 $  $Date: 2004/07/28 04:39:01 $

    % Center X by subtracting off column means
    [n,p] = size(x);
    %x0 = x;% - repmat(mean(x,1),n,1);
    r = min(n-1,p); % max possible rank of X0
    %disp('ok');
    % When X has more variables than observations, the default behavior is to
    % return all the pc's, even those that have zero variance.  When econFlag
    % is 'econ', those will not be returned.
    if nargin < 2, econFlag = 0; end

    % The principal component coefficients are the eigenvectors of
    % S = X0'*X0./(n-1), but computed using SVD.
    [U,sigma,coeff] = svd(x,econFlag); % put in 1/sqrt(n-1) later

    if nargout < 2
        % When econFlag is 'econ', only (n-1) components should be returned.
        % See comment below.
        if (n <= p) && isequal(econFlag, 'econ')
            coeff(:,n) = [];
        end

    else
        % Project X0 onto the principal component axes to get the scores.
        if n == 1 % sigma might have only 1 row
            sigma = sigma(1);
        else
            sigma = diag(sigma);
        end
        score = U .* repmat(sigma',n,1); % == x0*coeff
        sigma = sigma./ sqrt(n-1);
        % When X has at least as many variables as observations, eigenvalues
        % n:p of S are exactly zero.
        if n <= p
            % When econFlag is 'econ', nothing corresponding to the zero
            % eigenvalues should be returned.  svd(,'econ') won't have
            % returned anything corresponding to components (n+1):p, so we
            % just have to cut off the n-th component.
            if isequal(econFlag, 'econ')
                sigma(n) = [];
                coeff(:,n) = [];
                score(:,n) = [];

            % Otherwise, set those eigenvalues and the corresponding scores to
            % exactly zero.  svd(,0) won't have returned columns of U
            % corresponding to components (n+1):p, need to fill those out.
            else
                sigma(n:p,1) = 0; % make sure this extends as a column
                score(:,n:p) = 0;
            end
        end
        % The variances of the pc's are the eigenvalues of S = X0'*X0./(n-1).
        latent = sigma.^2;
        % Hotelling's T-squared statistic is the sum of squares of the
        % standardized scores, i.e., Mahalanobis distances.  When X appears to
        % have column rank < r, ignore components that are orthogonal to the
        % data.
        if nargout == 4
            q = sum(sigma > max(n,p).*eps(sigma(1)));
            if q < r
                warning('stats:princomp:colRankDefX', ...
                        ['Columns of X are linearly dependent to within machine precision.\n' ...
                         'Using only the first %d components to compute TSQUARED.'],q);
            end
            tsquare = (n-1) .* sum(U(:,1:q).^2,2); % == sum(score*diag(1./sigma),2)
        end
    end
end
