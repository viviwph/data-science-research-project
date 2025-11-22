function X0 = generate_X0_subgroup(n, m, fracA)

% group sizes
nA = round(fracA * n);
nB = n - nA;

% mild subgroup separation
muA = 0.65 * ones(1,m);
muB = 0.35 * ones(1,m);
kappa = 6 * ones(1,m);

alphaA = muA .* kappa;
betaA  = (1 - muA) .* kappa;

alphaB = muB .* kappa;
betaB  = (1 - muB) .* kappa;

% ----- Group A -----
XA = zeros(nA, m);
for j = 1:m
    XA(:, j) = betarnd(alphaA(j), betaA(j), nA, 1);
end

% ----- Group B -----
XB = zeros(nB, m);
for j = 1:m
    XB(:, j) = betarnd(alphaB(j), betaB(j), nB, 1);
end

% Combine
X0 = [XA; XB];

% Scale to [-1,1]
X0 = 2 * X0 - 1;

end