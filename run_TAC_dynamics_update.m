function X_series = run_TAC_dynamics_update(X0, W, C_matrices, T)
% Multi-topic TAC Dynamics (Ye et al.)
%
% CORRECTED Update rule:
%   x_i(t+1) = C_i * x̄_i(t)
%   where x̄_i(t) = sum_j W(i,j) x_j(t)  (social influence)
%
% In matrix form:
%   X̄(t) = W * X(t)           (social influence for all agents)
%   x_i(t+1) = C_i * x̄_i(t)'  (apply logic matrix to each agent)
%
% The key correction: C_i multiplies the social influence vector as a COLUMN vector,
% not as a row vector. This ensures that:
%   - Topic p depends on topics q according to row p of C_i
%   - In cascade structure: Topic 1 (axiom) only depends on itself
%   - In cascade structure: Topic 5 (derived) depends on all previous topics

[n, m] = size(X0);

X_series = zeros(n, m, T);
X_series(:,:,1) = X0;

for t = 1:T-1
    
    X_t = X_series(:,:,t);      % n×m
    social = W * X_t;           % n×m  (interpersonal influence)
    X_next = zeros(n,m);
    
    for i = 1:n
        C_i = C_matrices(:,:,i);          % m×m logic matrix for agent i
        
        % CORRECTED FORMULA:
        % Convert social(i,:) to column vector, multiply by C_i, convert back to row
        social_vec = social(i,:)';        % m×1 column vector
        updated_vec = C_i * social_vec;   % m×1 result
        X_next(i,:) = updated_vec';       % 1×m row vector
        
        % Alternative one-liner (equivalent):
        % X_next(i,:) = (C_i * social(i,:)')';
    end

    % clipping to [-1, 1]
    X_next = min(max(X_next, -1), 1);

    X_series(:,:,t+1) = X_next;
end

end
