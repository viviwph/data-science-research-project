%% =====================================================================
%  run_full_simulation.m 
%
%  Run multi-topic simulations for 3 scenarios:
%     (1) global consensus        – all agents share one logic C
%     (2) subgroup disagreement   – two group-level C_A, C_B
%     (3) polarization            – C_B is a column-flipped version of C_A
%
%  Output files:
%     sim_consensus.mat
%     sim_disagreement.mat
%     sim_polarization.mat
%
%  These .mat files contain:
%       X_series  (n×m×T)
%       W         (n×n)
%       coords    ([] → auto layout)
%
% =====================================================================

clear; clc;

%% ------------------------
%  Global parameters
% -------------------------
N = 500;      % number of agents
m = 5;        % number of topics
T = 200;       % time steps

coords = [];  % plot auto layout


%% ------------------------
%  Influence network W (WS)
% -------------------------
d = 6;        % mean degree
p = 0.05;      % rewiring probability
seed_W = 4;

W = create_initial_W_matrix(N, d, p, [], seed_W, 'WS');


%% ------------------------
%  Initial beliefs X(0)
% ------------------------
X0 = generate_X0(N, m);   % in [-1,1]


%% =====================================================================
%  Scenario 1 – consensus
% =====================================================================

C_homo = generateC_update(N, m, ...
    'scenario', 'consensus', ...
    'type',     'homogeneous', ...
    'seed',     1);

X_series_homo = run_TAC_dynamics_update(X0, W, C_homo, T);

save('sim_consensus.mat', 'X_series_homo', 'W', 'coords');
disp('✓ Scenario 1 saved: sim_consensus.mat');



%% =====================================================================
%  Scenario 2 – Subgroup disagreement (two logic matrices)
% =====================================================================
X0 = generate_X0_subgroup(N, m, 0.3);

C_sub = generateC_update(N, m, ...
    'scenario',     'subgroup', ...
    'type',         'group_hetero', ...
    'ratio_groupA', 0.3, ...
    'seed',         2);

X_series_sub = run_TAC_dynamics_update(X0, W, C_sub, T);

save('sim_disagreement.mat', 'X_series_sub', 'W', 'coords');
disp('✓ Scenario 2 saved: sim_disagreement.mat');



%% =====================================================================
%  Scenario 3 – Polarization (competing logic)
% =====================================================================
X0 = generate_X0_groups(N, m, 0.3);

C_pol = generateC_update(N, m, ...
    'scenario',       'polarization', ...
    'type',           'group_hetero', ...
    'ratio_groupA',   0.3, ...
    'seed',           3);

X_series_pol = run_TAC_dynamics_update(X0, W, C_pol, T);

save('sim_polarization.mat', 'X_series_pol', 'W', 'coords');
disp('✓ Scenario 3 saved: sim_polarization.mat');



%% =====================================================================
disp('======================================================');
disp('All TAC simulations completed successfully.');
disp('======================================================');