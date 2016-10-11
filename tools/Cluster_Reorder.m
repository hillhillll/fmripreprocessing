% Cluster reorder
% ------------------------------------------------------------------------------
% Can put a distance matrix in DistanceMetric if you want
% ------------------------------------------------------------------------------
% Ben Fulcher, 2014-04-21
% ------------------------------------------------------------------------------

function [ord,R,keepers] = Cluster_Reorder(DataMatrix,DistanceMetric,LinkageMethod)

if nargin < 2
    DistanceMetric = 'corr'; % correlation distances by default
end
if nargin < 3
    LinkageMethod = 'average'; % average linkage by default
end

% ------------------------------------------------------------------------------
%% Do linkage:
% ------------------------------------------------------------------------------
if ischar(DistanceMetric)
    % Specify a distance metric as an input to pdist/BF_pdist
    R = BF_pdist(DataMatrix,DistanceMetric);
else
    % Put the pre-computed distance matrix in the second input: DistanceMetric
    R = DistanceMetric;
end

% squareform if still a vector:
if size(R,1)==1 || size(R,2)==1
    R = squareform(R);
end

if any(isnan(R(:)))
    % Remove NaNs:
    [R,keepers] = RemoveNaN_DistMat(R);
    fprintf(1,'***CAUTION: Removed %u bad features from the distance matrix\n', ...
                        sum(keepers==0));
else
    keepers = ones(length(R),1);
end

if size(R,1)==size(R,2)
    R = squareform(R); % Convert back to vector for linkage to work properly
end
links = linkage(R,LinkageMethod);

% ------------------------------------------------------------------------------
%% Get the optimal dendrogram reordering:
% ------------------------------------------------------------------------------
figure('color','w');
set(gcf,'Visible','off'); % suppress figure output
if sqrt(length(R)) < 1000 % small enough to try optimalleaforder
    try
        fprintf(1,'Trying optimalleaforder\n');
        ord = optimalleaforder(links,R); % NEW!
        [~,~,ord] = dendrogram(links,0,'r',ord);
        fprintf(1,'Used optimalleaforder!\n')
    catch
        beep
        fprintf(1,'optimalleaforder was not used :(\n')
        [~,~,ord] = dendrogram(links,0);
    end
else
    fprintf(1,'Too big for optimalleaforder, using dendrogram\n')
    [~,~,ord] = dendrogram(links,0);
end
close; % close the invisible figure used for the dendrogram

if ~all(keepers==1)
    keepers = find(keepers);
    ord = keepers(ord); % convert to indicies of the input matrix
end

end