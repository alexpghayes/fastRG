
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fastRG

<!-- badges: start -->

<!-- badges: end -->

fastRG quickly samples a generalized random product graph, which is a
generalization of a broad class of network models. Given matrices
\(X \in R^{n \times K_x}\), \(Y \in R^{n \times K_y}\), and
\(S \in R^{K_x \times K_y}\) each with positive entries, fastRG samples
a matrix with expectation \(X S Y^T\) and independent Poisson entries.
[See the tech report for sampling Bernoulli
entries](https://arxiv.org/abs/1703.02998).

The basic idea of the algorithm is to first sample the number of edges,
\(m\), and then put down edges one-by-one. It runs in \(\mathcal O(m)\)
operations. For example, in sparse graphs \(m = \mathcal O(n)\) and the
algorithm is dramatically faster than element-wise algorithms which run
in \(\mathcal O(n^2)\) operations.

## TODO

  - Talk to Karl about license
  - Talk to Karl about authorship

## Installation

`fastRG` is not yet on CRAN. You can install the development version
with:

``` r
# install.package("devtools")
devtools::install_github("alexpghayes/fastRG")
```

## Example Usage

The easiest way to use `fastRG` is to use wrapper functions that sample
from population graph models. For example, to sample from an Erdos-Renyi
graphn = 1,000,000$ nodes and expected degree 5, we can use the `er()`
function.

``` r
A <- er(n = 10^6, avgDeg = 5)
A
```

By default we always get a `Matrix::sparseMatrix()`, but if we can also
ask for the graph as an edgelist as well. This results in a fast way to
create `igraph` objects using `igraph::graph_from_edgelist()`.

``` r
library(igraph)

n <- 10000
K <- 5

X <- matrix(rpois(n = n * K, 1), nrow = n)
S <- matrix(runif(n = K * K, 0, .0001), nrow = K)

howManyEdges(X, S)[-1]
A <- fastRG(X, S, simple = T)

el <- fastRG(X, S, simple = TRUE, returnEdgeList = TRUE)
g <- graph_from_edgelist(el)
```

or fastRG also allows for simulating from E(A) = X S Y’, where A and S
could be rectangular. This is helpful for bipartite graphs or matrices
of features.

``` r
n <- 10000
d <- 1000
K1 <- 5
K2 <- 3

X <- matrix(rpois(n = n * K1, 1), nrow = n)
Y <- matrix(rpois(n = d * K2, 1), nrow = d)
S <- matrix(runif(n = K1 * K2, 0, .1), nrow = K1)

A <- fastRG(X, S, Y, avgDeg = 10)
```

or

``` r
K <- 10
n <- 500
pi <- rexp(K) + 1
pi <- pi / sum(pi) * 3
B <- matrix(rexp(K^2) + 1, nrow = K)
diag(B) <- diag(B) + mean(B) * K
theta <- rexp(n)

A <- dcsbm(theta, pi, B, avgDeg = 50)
# here is the average degree:
mean(rowSums(A))

# If we remove multiple edges, the avgDeg parameter is not trustworthy:
A <- dcsbm(theta, pi, B, avgDeg = 50, PoissonEdges = F)
mean(rowSums(A))

# but it is a good upper bound when the graph is sparse:
n <- 10000
A <- dcsbm(rexp(n), pi, B, avgDeg = 50, PoissonEdges = F)
mean(rowSums(A))
```

or

``` r
# This draws a 100 x 100 adjacency matrix from each model.
#   Each image might take around 5 seconds to render.

K <- 10
n <- 100
pi <- rexp(K) + 1
pi <- pi / sum(pi) * 3
B <- matrix(rexp(K^2) + 1, nrow = K)
diag(B) <- diag(B) + mean(B) * K
theta <- rexp(n)
A <- dcsbm(theta, pi, B, avgDeg = 50)
image(as.matrix(t(A[, n:1])), col = grey(seq(1, 0, len = 20)))


K <- 2
n <- 100
alpha <- c(1, 1) / 5
B <- diag(c(1, 1))
theta <- n
A <- dcMixed(theta, alpha, B, avgDeg = 50)
image(as.matrix(t(A[, theta:1])) / max(A), col = grey(seq(1, 0, len = 20)))


n <- 100
K <- 2
pi <- c(.7, .7)
B <- diag(c(1, 1))
theta <- n
A <- dcOverlapping(theta, pi, B, avgDeg = 50)
image(as.matrix(t(A[, n:1])) / max(A), col = grey(seq(1, 0, len = 20)))


K <- 10
n <- 100
pi <- rexp(K) + 1
pi <- pi / sum(pi)
B <- matrix(rexp(K^2), nrow = K)
B <- B / (3 * max(B))
diag(B) <- diag(B) + mean(B) * K
A <- sbm(n, pi, B)
image(as.matrix(t(A[, n:1])), col = grey(seq(1, 0, len = 20)))
mean(A)
```

``` r
# this samples a DC-SBM with 10,000 nodes
#  then computes, and plots the leading eigenspace.
#  the code should run in less than a second.

require(rARPACK)
require(stats)
K <- 10
n <- 10000
pi <- rexp(K) + 1
pi <- pi / sum(pi)
pi <- -sort(-pi)
B <- matrix(rexp(K^2) + 1, nrow = K)
diag(B) <- diag(B) + mean(B) * K
A <- dcsbm(rgamma(n, shape = 2, scale = .4), pi, B, avgDeg = 20, simple = T)
mean(rowSums(A))

# leading eigen of regularized Laplacian with tau = 1
D <- Diagonal(n, 1 / sqrt(rowSums(A) + 1))
ei <- eigs_sym(D %*% A %*% D, 10)

# normalize the rows of X:
X <- t(apply(ei$vec[, 1:K], 1, function(x) return(x / sqrt(sum(x^2) + 1 / n))))

# taking a varimax rotation makes the leading vectors pick out clusters:
X <- varimax(X, normalize = FALSE)$loadings

par(mfrow = c(5, 1), mar = c(1, 2, 2, 2), xaxt = "n", yaxt = "n")

# plot 1000 elements of the leading eigenvectors:
s <- sort(sample(n, 1000))
for (i in 1:5) {
  plot(X[s, i], pch = ".")
}
dev.off()
```

or

``` r
# This samples a 1M node graph.
# Depending on the computer, sampling the graph should take between 10 and 30 seconds
#   Then, taking the eigendecomposition of the regularized graph laplacian should take between 1 and 3 minutes
# The resulting adjacency matrix is a bit larger than 100MB.
# The leading eigenvectors of A are highly localized
K <- 3
n <- 1000000
pi <- rexp(K) + 1
pi <- pi / sum(pi)
pi <- -sort(-pi)
B <- matrix(rexp(K^2) + 1, nrow = K)
diag(B) <- diag(B) + mean(B) * K
A <- dcsbm(rgamma(n, shape = 2, scale = .4), pi, B, avgDeg = 10)
D <- Diagonal(n, 1 / sqrt(rowSums(A) + 10))
L <- D %*% A %*% D
ei <- eigs_sym(L, 4)

s <- sort(sample(n, 10000))
X <- t(apply(ei$vec[, 1:K], 1, function(x) return(x / sqrt(sum(x^2) + 1 / n))))
plot(X[s, 3]) # highly localized eigenvectors
```

To sample from a degree corrected and node contextualized graph…

``` r
n <- 10000 # number of nodes
d <- 1000 # number of features
K <- 5 # number of blocks


# Here are the parameters for the graph:

pi <- rexp(K) + 1
pi <- pi / sum(pi) * 3
B <- matrix(rexp(K^2) + 1, nrow = K)
diag(B) <- diag(B) + mean(B) * K
theta <- rexp(n)
paraG <- dcsbm(theta = theta, pi = pi, B = B, parametersOnly = T)


# Here are the parameters for the features:

thetaY <- rexp(d)
piFeatures <- rexp(K) + 1
piFeatures <- piFeatures / sum(piFeatures) * 3
BFeatures <- matrix(rexp(K^2) + 1, nrow = K)
diag(BFeatures) <- diag(BFeatures) + mean(BFeatures) * K

paraFeat <- dcsbm(theta = thetaY, pi = piFeatures, B = BFeatures, parametersOnly = T)

# the node "degrees" in the features, should be related to their degrees in the graph.
X <- paraG$X
X@x <- paraG$X@x + rexp(n) # the degree parameter should be different. X@x + rexp(n) makes feature degrees correlated to degrees in graph.

# generate the graph and features
A <- fastRG(paraG$X, paraG$S, avgDeg = 10)
features <- fastRG(X, paraFeat$S, paraFeat$X, avgDeg = 20)
```

## Mathematical Details

fastRG samples a Poisson gRPG where \(\lambda_{ij} = X_i' S Y_j\) is the
rate parameter for edge \(i,j\). If multiEdges is set to FALSE, then it
samples a Bernoulli gRPG where the probability of edge \((i,j)\) is
\(1 - exp(-\lambda_{ij})\). In sparse graphs, this is a good
approximation to having edge probabilities \(\lambda_{ij}\). Arugments
can keep self loops or keep the graph directed.

er, cl, sbm, dcsbm, dcOverlapping, and dcMixed are wrappers for fastRG
that sample the Erdos-Renyi, Chung-Lu, Stochastic Blockmodel, Degree
Corrected Stochastic Blockmodel, the Degree Corrected Overlapping
Stochastic Blockmodel, and the Degree Corrected Mixed Membership
Stochastic Blockmodel. To remove Degree correction, set theta = rep(1,
n) or set theta equal to the number of desired nodes \(n\).

If selfLoops == T, then fastRG retains the selfloops. If selfLoops == F,
then fastRG uses a poisson approximation to the binomial in the
following sense: Let \(M\sim poisson(\sum_{uv} \lambda_{uv})\) be the
number of edges. fastRG approximates edge probabilities of
\(Poisson(\lambda_{ij})\) with
\(Binomial(M, \lambda_{ij}/\sum_{uv}\lambda_{uv})\). This approximation
is good when total edges is order \(n\) or larger and
\(\max \lambda_{ij}\) is order constant or smaller. Under er and sbm,
there is a default correction that removes this issue.

If directed == T, then fastRG does not symmetrize the graph. If directed
== F, then fastRG symmetrizes S and A.

If PoissonEdges == T, then fastRG keeps the multiple edges and avgDeg
calculations are on out degree (i.e. rowSums). If PoissonEdges == F,
then fastRG thresholds each edge so that multiple edges are replaced by
single edges. In this case, only SBM has edge probabilities exactly
given by \(\lambda\) (up to scaling for avgDeg). The other techniques
have edge probabilities \(1 - exp(-\lambda)\).

If Y is specified, then it returns a sparse matrix, with poisson
entries, where \(E(A) = X S Y'\). This is useful for creating sparse
rectangular matrices. For example, this could be a feature matrix. Or,
it could be a “rectangular adjacency matrix” for a bipartite graph.
