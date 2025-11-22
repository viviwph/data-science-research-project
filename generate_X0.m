function X0 = generate_X0(n, m)

cfg.mu    = 0.5 * ones(1,m);
cfg.kappa = 4  * ones(1,m);
cfg.scale = 'att';      % ensures range [-1,1]
cfg.corr  = 0;
cfg.seed  = 1;

[X0, ~] = generate_X0_core(n, m, cfg);

end