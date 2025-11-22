function plot_belief_network_evolution(X_series, W, coords, timepoints, labels, opts, topic_index)
%PLOT_BELIEF_NETWORK_EVOLUTION  Publication-style 1×3 snapshots (a–c)
%
% Now supports multi-topic input X_series: n × m × T
% topic_index selects which topic to visualise.

% ---------- defaults ----------
if nargin < 7 || isempty(topic_index), topic_index = 1; end
if nargin < 6, opts = struct; end
if ~isfield(opts,'EdgeAlpha'), opts.EdgeAlpha = 0.7; end
if ~isfield(opts,'NodeAlpha'), opts.NodeAlpha = 1.0; end
if ~isfield(opts,'CLim'),      opts.CLim = [-1 1]; end

% ---------- detect data dimension ----------
dims = ndims(X_series);

if dims == 2
    % Backward compatibility: X_series is n×T (single topic)
    X_topic = X_series;
elseif dims == 3
    % Multi-topic format n×m×T
    X_topic = squeeze(X_series(:, topic_index, :));  % n×T
else
    error('X_series must be either n×T or n×m×T.');
end

[n, T] = size(X_topic);
assert(size(W,1)==n && size(W,2)==n);

assert(numel(timepoints)==3);
assert(all(timepoints>=1 & timepoints<=T));

default_labels = {'a','b','c'};
if nargin < 5 || isempty(labels)
    labels = default_labels;
end

% ---------- layout ----------
if isempty(coords)
    coords = generate_layout(W);
end

A = W > 0;

% ---------- degree-based node size ----------
deg = sum(A,2);
deg_norm = (deg - min(deg)) / (max(deg)-min(deg) + 1e-9);
NodeSize = 35 + 45 * deg_norm;

% ---------- figure ----------
figure('Color','w','Position',[100,100,1100,350]);

[row, col] = find(A);

for k = 1:3
    subplot(1,3,k); hold on;
    t = timepoints(k);

    % beliefs at time t (for selected topic)
    cdata = X_topic(:,t);
    cdata = min(max(cdata, opts.CLim(1)), opts.CLim(2));

    % ---------- edges ----------
    for e = 1:length(row)
        plot([coords(row(e),1), coords(col(e),1)], ...
             [coords(row(e),2), coords(col(e),2)], ...
             'Color', [0.55 0.75 0.95 opts.EdgeAlpha], ...
             'LineWidth', 0.5);
    end

    % ---------- nodes ----------
    scatter(coords(:,1), coords(:,2), ...
            NodeSize, ...
            cdata, 'filled', ...
            'MarkerFaceAlpha', opts.NodeAlpha, ...
            'MarkerEdgeColor', 'none');

    axis off;
    colormap(redblue);
    caxis(opts.CLim);

    % panel label
    text(-0.12,1.05,labels{k}, ...
         'Units','normalized','FontWeight','bold','FontSize',12);

    % time label
    text(0.5,-0.10,sprintf('t = %d',t), ...
        'Units','normalized','HorizontalAlignment','center', ...
        'FontSize',11);
end

% ---------- colorbar ----------
h = colorbar('Position',[0.93 0.15 0.015 0.7]);
ylabel(h,'Belief Value (-1 = Anti, +1 = Pro)','FontSize',11);

end