function problem3_multigrid
% löst -u'' + u = x^2 mit linearen Basisfunktionen

a = 0;
b = 1;
ul = 0;
ur = 0.1;

n = 512;
elements = linspace(a, b, n+1);
h = 1/n;

basis = {@(x) 1-x, @(x) x};

% lokale Matrizen
m = 1/6 * [2 1
           1 2];
k = [ 1 -1
     -1  1];

tic 

% node ordering
B = zeros(n, 2);

parfor i=1:n
    B(i, :) = [i, i+1];
end

% Assemblierung
M = createMatrix(m, B, h);
K = createMatrix(k, B, 1/h);

A = M+K;

fb = createVector(basis, B, linspace(a, b, n+1), @(x) x.^2);

% Randbedingungen beachten
[A, fb] = dirichletBoundary(A, fb, [1, n+1], [ul, ur]);

% lösen
u = multigridSolve(A, fb, ceil(log2(n)));

% u = multigridSolve(A, fb, 4);

% [Dinv, L, R] = jacobiDecompose(A);
% 
% for i=1:5000
%     u = Dinv*(fb-(L+R)*u);
% end

toc

% exakte Lösung
x = linspace(a, b, 1000);
y = (exp(1-x).*(exp(1)*ul - ur - 2*exp(1) + 3))/(exp(2)-1) ...
    + (exp(x).*(-ul + exp(1)*ur - 3*exp(1) + 2))/(exp(2)-1) + x.^2 + 2;

% Basisfunktionen
Phi = createBasis(basis, elements, x, B);

% plotten
plot(x, Phi*u, x, y);
legend('Näherung', 'exakt', 'location', 'Best');

fprintf('Fehler: %d\n', norm(Phi*u-y'));

end
