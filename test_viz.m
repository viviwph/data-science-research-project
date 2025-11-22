%load('sim_polarization.mat')
%plot_belief_network_evolution(X_series_pol, W, coords, [1 50 200],[],[],5);

%load('sim_consensus.mat')
%plot_belief_network_evolution(X_series_homo, W, coords, [1 50 200],[],[],5);

% load('sim_disagreement.mat')
% plot_belief_network_evolution(X_series_sub, W, coords, [1 50 200],[],[],5);


% Mode 2:
%plot_opinions_timeseries(X_series_homo, 2);
plot_opinions_timeseries(X_series_sub, 2);
%plot_opinions_timeseries(X_series_pol, 2);

%plot_opinions_timeseries(X_series_homo, 6);
plot_opinions_timeseries(X_series_sub, 6);
%plot_opinions_timeseries(X_series_pol, 6);
