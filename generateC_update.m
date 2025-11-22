function C_matrices = generateC_update(nAgents, m, varargin)
% generateC - IMPROVED Logic-matrix generator with stronger cascade structure
%
% Key improvements:
%   1. Stronger cascade hierarchy (Topic 1: 100% self, Topic 5: 90% dependency)
%   2. Structural differences for Scenario 2 (different reasoning paths)
%   3. Multiple opposing links for Scenario 3 (stronger polarization)
%
% Scenarios (name–value: 'scenario'):
%   'consensus'    : all agents share one logic matrix (global consensus)
%   'subgroup'     : two group-level matrices with STRUCTURAL differences
%   'polarization' : two group-level matrices with MULTIPLE competing links
%
% Types (name–value: 'type'):
%   'homogeneous'  : all agents use the same C (consensus case)
%   'group_hetero' : two groups with different C (subgroup / polarization)
%
% Other name–value parameters:
%   'ratio_groupA' : fraction of agents in group 1 (default 0.5)
%   'seed'         : RNG seed for reproducibility (default 1)
%   'noise_level'  : small per-agent perturbation (default 0.02)
%   'cascade_strength' : 'weak', 'medium', 'strong' (default 'strong')
%
% Output:
%   C_matrices : m × m × nAgents  logic matrices, each row satisfies:
%       (1) C(p,p) >= 0 (can be 0 for strong cascade)
%       (2) sum_q |C(p,q)| = 1

    % -----------------------------
    % 0) Parse options
    % -----------------------------
    p = inputParser;
    addParameter(p, 'scenario',       'consensus');
    addParameter(p, 'type',           'group_hetero');
    addParameter(p, 'ratio_groupA',   0.5);
    addParameter(p, 'seed',           1);
    addParameter(p, 'noise_level',    0.02);  % Reduced from 0.03
    addParameter(p, 'cascade_strength', 'strong');  % 'weak', 'medium', 'strong'
    parse(p, varargin{:});
    opt = p.Results;

    scenario = lower(opt.scenario);
    cascade_strength = lower(opt.cascade_strength);

    % -----------------------------
    % 1) RNG seed
    % -----------------------------
    if ~isempty(opt.seed)
        rng(opt.seed);
    end

    % -----------------------------
    % 2) Cascade-style mask (unchanged)
    % -----------------------------
    mask = zeros(m);
    for r = 1:m
        mask(r,r) = 1;
        if r > 1
            mask(r,1:r-1) = 1;
        end
    end

    % -----------------------------
    % 3) Build C matrices based on scenario
    % -----------------------------
    
    switch scenario
        case 'consensus'
            % All agents share the same strong cascade structure
            C_group1 = build_strong_cascade(m, cascade_strength);
            C_group2 = C_group1;
            
        case 'subgroup'
            % Two groups with STRUCTURAL differences (different reasoning paths)
            C_group1 = build_subgroup_C1(m);  % "Economic-driven" logic
            C_group2 = build_subgroup_C2(m);  % "Cultural-driven" logic
            
        case 'polarization'
            % Two groups with MULTIPLE opposing links
            C_group1 = build_polarization_C1(m);  % "Pro-immigration" logic
            C_group2 = build_polarization_C2(m);  % "Anti-immigration" logic
            
        otherwise
            error('Unknown scenario: %s', scenario);
    end

    % -----------------------------
    % 4) Assign matrices to agents
    % -----------------------------
    C_matrices = zeros(m, m, nAgents);

    switch lower(opt.type)
        case 'homogeneous'
            C_matrices = repmat(C_group1, 1, 1, nAgents);

        case 'group_hetero'
            n_group1 = round(opt.ratio_groupA * nAgents);
            n_group1 = max(0, min(nAgents, n_group1));
            idx_g1   = 1:n_group1;
            idx_g2   = n_group1+1:nAgents;

            % Base assignment
            for i = idx_g1
                C_matrices(:,:,i) = C_group1;
            end
            for i = idx_g2
                C_matrices(:,:,i) = C_group2;
            end

            % Small per-agent noise
            for i = 1:nAgents
                C0    = C_matrices(:,:,i);
                noise = opt.noise_level * (2*rand(size(C0)) - 1);
                C_pert = C0 + noise .* mask;

                % Row-wise re-normalisation
                for r = 1:m
                    idx_off = find(mask(r,:) == 1 & (1:m) ~= r);
                    if isempty(idx_off)
                        C_pert(r,:) = 0;
                        C_pert(r,r) = 1;
                        continue;
                    end

                    signs_base = sign(C0(r,:));
                    abs_vals   = abs(C_pert(r,:));
                    
                    % Keep total off-diagonal mass close to original
                    orig_off_total = sum(abs(C0(r,idx_off)));
                    row_off_total  = min(max(orig_off_total, 0.1), 0.95);

                    u = abs_vals(idx_off);
                    if sum(u) == 0
                        u = ones(size(u));
                    end
                    u = u / sum(u);

                    C_pert(r,idx_off) = signs_base(idx_off) .* (row_off_total * u);
                    C_pert(r,r)       = 1 - row_off_total;
                end

                C_matrices(:,:,i) = C_pert;
            end

        otherwise
            error('Unknown type: %s', opt.type);
    end
end

% =========================================================================
% Helper functions to build specific C matrices
% =========================================================================

function C = build_strong_cascade(m, strength)
    % Build a strong cascade structure
    % Topic 1: 100% self-retention (axiom)
    % Topics 2-5: progressively stronger dependency on upper topics
    
    C = zeros(m);
    
    % Topic 1: axiom (100% self)
    C(1,1) = 1.0;
    
    if strcmp(strength, 'weak')
        % Weak cascade: more self-retention
        self_retention = [1.0, 0.5, 0.4, 0.3, 0.2];
    elseif strcmp(strength, 'medium')
        % Medium cascade
        self_retention = [1.0, 0.3, 0.25, 0.2, 0.15];
    else  % 'strong'
        % Strong cascade: minimal self-retention for derived topics
        self_retention = [1.0, 0.2, 0.15, 0.1, 0.05];
    end
    
    for r = 2:m
        C(r,r) = self_retention(r);
        off_total = 1 - self_retention(r);
        
        % Distribute off-diagonal weight with emphasis on Topic 1
        weights = zeros(1, r-1);
        weights(1) = 0.5;  % Topic 1 always gets 50% of off-diagonal
        if r > 2
            % Remaining 50% distributed among Topic 2 to r-1
            remaining = 0.5;
            for q = 2:r-1
                weights(q) = remaining / (r-1);
            end
        end
        
        % Normalize and apply
        weights = weights / sum(weights);
        C(r, 1:r-1) = off_total * weights;
    end
end

function C = build_subgroup_C1(m)
    % Group 1: "Economic-driven" logic
    % Strong path: Topic 1 (economy) → Topic 3 (labor) → Topic 5 (policy)
    
    C = zeros(m);
    C(1,1) = 1.0;  % Axiom
    
    % Topic 2: moderate dependency on Topic 1
    C(2, 1:2) = [0.6, 0.4];
    
    % Topic 3: STRONG dependency on Topic 1 (economic focus)
    C(3, 1:3) = [0.6, 0.2, 0.2];
    
    % Topic 4: balanced
    C(4, 1:4) = [0.3, 0.3, 0.2, 0.2];
    
    % Topic 5: emphasizes Topic 1 (economy) and Topic 3 (labor)
    C(5, 1:5) = [0.4, 0.1, 0.3, 0.1, 0.1];
end

function C = build_subgroup_C2(m)
    % Group 2: "Cultural-driven" logic
    % Strong path: Topic 2 (culture) → Topic 4 (security) → Topic 5 (policy)
    
    C = zeros(m);
    C(1,1) = 1.0;  % Axiom
    
    % Topic 2: more self-retention (cultural identity)
    C(2, 1:2) = [0.3, 0.7];
    
    % Topic 3: WEAK dependency on Topic 1
    C(3, 1:3) = [0.2, 0.3, 0.5];
    
    % Topic 4: emphasizes Topic 2 (culture)
    C(4, 1:4) = [0.1, 0.5, 0.2, 0.2];
    
    % Topic 5: emphasizes Topic 2 (culture) and Topic 4 (security)
    C(5, 1:5) = [0.1, 0.4, 0.1, 0.3, 0.1];
end

function C = build_polarization_C1(m)
    % Group 1: "Pro-immigration" logic
    % Positive interpretation: economy, culture, labor → support immigration
    
    C = zeros(m);
    C(1,1) = 1.0;
    
    C(2, 1:2) = [0.6, 0.4];
    C(3, 1:3) = [0.5, 0.3, 0.2];
    C(4, 1:4) = [0.3, 0.3, 0.2, 0.2];
    
    % Topic 5: MULTIPLE POSITIVE links
    % Interpretation: good economy → support, cultural diversity → support, etc.
    C(5, 1:5) = [+0.35, +0.30, +0.25, -0.05, +0.05];
    % Note: slight negative on Topic 4 (security concern), but overall positive
end

function C = build_polarization_C2(m)
    % Group 2: "Anti-immigration" logic
    % Negative interpretation: economy, culture, labor → oppose immigration
    
    C = zeros(m);
    C(1,1) = 1.0;
    
    % Topics 2-4: same as Group 1 (consensus on these)
    C(2, 1:2) = [0.6, 0.4];
    C(3, 1:3) = [0.5, 0.3, 0.2];
    C(4, 1:4) = [0.3, 0.3, 0.2, 0.2];
    
    % Topic 5: MULTIPLE NEGATIVE links (OPPOSING Group 1)
    % Interpretation: economic competition → oppose, cultural conflict → oppose, etc.
    C(5, 1:5) = [-0.30, -0.30, -0.25, +0.10, +0.05];
    % Note: positive on Topic 4 (security priority), overall negative
end
