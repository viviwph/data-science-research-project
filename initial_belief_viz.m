% %% ===============================================================
% % FINAL CLEAN VERSION — uniform y-axis + tighter legend + simple title
% % ===============================================================
% 
% % ========== 1. X0 generation ==========
% N = 500;
% m = 5;
% fracA = 0.3;
% X0 = generate_X0_groups(N, m, fracA);
% 
% % Split
% nA = round(fracA * N);
% XA = X0(1:nA,:);
% XB = X0(nA+1:end,:);
% 
% % ========== 2. Settings ==========
% colors = [0.85 0.33 0.10;    % Group A orange
%           0.20 0.60 0.80];   % Group B blue
% 
% edges = linspace(min(X0(:)), max(X0(:)), 25);
% ymax = 2.5;     % unified y-axis
% 
% % ========== 3. Figure layout (2×3) ==========
% figure('Color','w','Units','normalized','Position',[0.05 0.05 0.90 0.80]);
% t = tiledlayout(2, 3, 'TileSpacing','compact', 'Padding','compact');
% 
% hA = [];
% hB = [];
% 
% % ========== 4. Subplots (hist + KDE) ==========
% for j = 1:m
%     ax = nexttile(j);
%     hold(ax, 'on');
% 
%     % Histogram group A
%     ha = histogram(ax, XA(:,j), edges, 'Normalization','pdf');
%     ha.FaceColor = colors(1,:);
%     ha.FaceAlpha = 0.30;
%     ha.EdgeColor = 'none';
% 
%     % Histogram group B
%     hb = histogram(ax, XB(:,j), edges, 'Normalization','pdf');
%     hb.FaceColor = colors(2,:);
%     hb.FaceAlpha = 0.30;
%     hb.EdgeColor = 'none';
% 
%     % KDE group A
%     [fA,xA] = ksdensity(XA(:, j));
%     plot(ax, xA, fA, 'LineWidth', 3.0, 'Color', colors(1,:));
% 
%     % KDE group B
%     [fB,xB] = ksdensity(XB(:, j));
%     plot(ax, xB, fB, 'LineWidth', 3.0, 'Color', colors(2,:));
% 
%     % Formatting
%     title(ax, sprintf('Topic %d', j), 'FontWeight','bold', 'FontSize',15);
%     xlabel(ax, 'Belief', 'FontWeight','bold');
%     ylabel(ax, 'Density', 'FontWeight','bold');
% 
%     grid(ax, 'on');
%     box(ax, 'on');
%     set(ax, 'FontSize', 12);
% 
%     % *** FORCE uniform scale ***
%     ylim(ax, [0 ymax]);
% 
%     if isempty(hA), hA = ha; end
%     if isempty(hB), hB = hb; end
% end
% 
% % ========== 5. Legend in tile 6 ==========
% axL = nexttile(6);  % last tile for legend
% axis(axL,'off');
% hold(axL,'on');
% 
% % Tighter spacing: y = 0.65 and 0.45
% plot(axL, [0.10 0.35], [0.65 0.65], 'LineWidth', 4, 'Color', colors(1,:));
% text(axL, 0.38, 0.65, 'Group A', 'FontSize',16, 'FontWeight','bold');
% 
% plot(axL, [0.10 0.35], [0.45 0.45], 'LineWidth', 4, 'Color', colors(2,:));
% text(axL, 0.38, 0.45, 'Group B', 'FontSize',16, 'FontWeight','bold');
% 
% xlim(axL, [0 1]);
% ylim(axL, [0 1]);
% 
% % ========== 6. Simple clean title ==========
% sgtitle('Initial Belief Distributions X(0): Polarization', ...
%     'FontSize', 16, 'FontWeight','bold');

% %% ===== CONSENSUS SCENARIO VISUALISATION =====
% 
% n = 500;
% m = 5;
% X0 = generate_X0(n, m);    % your function
% 
% figure('Color','w','Units','normalized','Position',[0.05 0.05 0.90 0.75]);
% tiledlayout(2,3,'TileSpacing','compact','Padding','compact');
% 
% edges = linspace(min(X0(:)), max(X0(:)), 25);
% 
% for j = 1:m
%     ax = nexttile(j); hold(ax,'on');
% 
%     % histogram
%     h = histogram(ax, X0(:,j), edges, 'Normalization','pdf');
%     h.FaceColor = [0.2 0.6 0.8];
%     h.FaceAlpha = 0.35;
%     h.EdgeColor = 'none';
% 
%     % KDE
%     [f,x] = ksdensity(X0(:,j));
%     plot(ax, x, f, 'LineWidth',3, 'Color',[0.2 0.45 0.8]);
% 
%     title(ax, sprintf('Topic %d',j), 'FontWeight','bold','FontSize',12);
%     xlabel(ax,'Belief','FontWeight','bold');
%     ylabel(ax,'Density','FontWeight','bold');
% 
%     ylim(ax,[0 1.0]);
%     grid(ax,'on');
% end
% 
% sgtitle('Initial Belief Distribution X(0): Consensus Scenario', ...
%         'FontSize',16,'FontWeight','bold');


%% ===== SUBGROUP SCENARIO VISUALISATION =====

n = 500; 
m = 5;
fracA = 0.3;

X0 = generate_X0_subgroup(n, m, fracA);

nA = round(fracA * n);
XA = X0(1:nA,:);
XB = X0(nA+1:end,:);

colors = [0.85 0.33 0.10;   % Group A
          0.20 0.60 0.80];  % Group B

edges = linspace(min(X0(:)), max(X0(:)), 25);

figure('Color','w','Units','normalized','Position',[0.05 0.05 0.92 0.82]);
t = tiledlayout(2,3,'TileSpacing','compact','Padding','compact');

ymax = 2.0;

for j = 1:m
    ax = nexttile(j); hold(ax,'on');

    % histograms
    ha = histogram(ax,XA(:,j),edges,'Normalization','pdf');
    ha.FaceColor = colors(1,:); ha.FaceAlpha = 0.30; ha.EdgeColor = 'none';
    
    hb = histogram(ax,XB(:,j),edges,'Normalization','pdf');
    hb.FaceColor = colors(2,:); hb.FaceAlpha = 0.30; hb.EdgeColor = 'none';
    
    % KDE
    [fA,xA] = ksdensity(XA(:,j));
    [fB,xB] = ksdensity(XB(:,j));
    plot(ax,xA,fA,'LineWidth',3,'Color',colors(1,:));
    plot(ax,xB,fB,'LineWidth',3,'Color',colors(2,:));

    % labels + grid
    title(ax, sprintf('Topic %d',j),'FontWeight','bold','FontSize',12);
    xlabel(ax,'Belief','FontWeight','bold');
    ylabel(ax,'Density','FontWeight','bold');
    grid(ax,'on');
    
    % *** unified y-limit & tick spacing ***
    ylim(ax, [0 ymax]);
    yticks(ax, 0:0.5:ymax);   % force tick spacing = 0.5
end

% ===== Legend tile =====
axL = nexttile(6);
axis(axL,'off'); hold(axL,'on');
plot(axL,[0.15 0.45],[0.65 0.65],'LineWidth',4,'Color',colors(1,:));
text(axL,0.50,0.65,'Group A','FontSize',16,'FontWeight','bold');
plot(axL,[0.15 0.45],[0.40 0.40],'LineWidth',4,'Color',colors(2,:));
text(axL,0.50,0.40,'Group B','FontSize',16,'FontWeight','bold');

xlim(axL,[0 1]); ylim(axL,[0 1]);

sgtitle('Initial Belief Distributions X(0): Subgroup', ...
        'FontSize',16,'FontWeight','bold');