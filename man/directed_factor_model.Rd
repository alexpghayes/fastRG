% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/directed_factor_model.R
\name{directed_factor_model}
\alias{directed_factor_model}
\title{Create a directed factor model graph}
\usage{
directed_factor_model(
  X,
  S,
  Y,
  ...,
  expected_in_degree = NULL,
  expected_out_degree = NULL,
  expected_density = NULL
)
}
\arguments{
\item{X}{A \code{\link[=matrix]{matrix()}} or \link[=matrix]{Matrix()} representing real-valued
latent node positions encoding community structure of
incoming edges. Entries must be positive.}

\item{S}{A \code{\link[=matrix]{matrix()}} or \link[=matrix]{Matrix()} mixing matrix. Entries
must be positive.}

\item{Y}{A \code{\link[=matrix]{matrix()}} or \link[=matrix]{Matrix()} representing real-valued
latent node positions encoding community structure of
outgoing edges. Entries must be positive.}

\item{...}{Ignored. For internal developer use only.}

\item{expected_in_degree}{If specified, the desired expected in degree
of the graph. Specifying \code{expected_in_degree} simply rescales \code{S}
to achieve this. Defaults to \code{NULL}. Specify only one of
\code{expected_in_degree}, \code{expected_out_degree}, and \code{expected_density}.}

\item{expected_out_degree}{If specified, the desired expected out degree
of the graph. Specifying \code{expected_out_degree} simply rescales \code{S}
to achieve this. Defaults to \code{NULL}. Specify only one of
\code{expected_in_degree}, \code{expected_out_degree}, and \code{expected_density}.}

\item{expected_density}{If specified, the desired expected density
of the graph. Specifying \code{expected_density} simply rescales \code{S}
to achieve this. Defaults to \code{NULL}. Specify only one of
\code{expected_in_degree}, \code{expected_out_degree}, and \code{expected_density}.}
}
\value{
A \code{directed_factor_model} S3 class based on a list
with the following elements:
\itemize{
\item \code{X}: The incoming latent positions as a \code{\link[=Matrix]{Matrix()}} object.
\item \code{S}: The mixing matrix as a \code{\link[=Matrix]{Matrix()}} object.
\item \code{Y}: The outgoing latent positions as a \code{\link[=Matrix]{Matrix()}} object.
\item \code{n}: The number of nodes with incoming edges in the network.
\item \code{k1}: The dimension of the latent node position vectors
encoding incoming latent communities (i.e. in \code{X}).
\item \code{d}: The number of nodes with outgoing edges in the network.
Does not need to match \code{n} -- rectangular adjacency matrices
are supported.
\item \code{k2}: The dimension of the latent node position vectors
encoding outgoing latent communities (i.e. in \code{Y}).
}
}
\description{
A directed factor model graph is a directed
generalized Poisson random dot product graph. The edges
in this graph are assumpted to be independent and Poisson
distributed. The graph is parameterized by its expected
adjacency matrix, with is \verb{E[A] = X S Y'}. We do not recommend
that causal users use this function, see instead \code{directed_dcsbm()}
and related functions, which will formulate common variants
of the stochastic blockmodels as undirected factor models
\emph{with lots of helpful input validation}.
}
\examples{

n <- 10000

k1 <- 5
k2 <- 3

d <- 5000

X <- matrix(rpois(n = n * k1, 1), nrow = n)
S <- matrix(runif(n = k1 * k2, 0, .1), nrow = k1, ncol = k2)
Y <- matrix(rexp(n = k2 * d, 1), nrow = d)

fm <- directed_factor_model(X, S, Y)
fm

sane_fm <- directed_factor_model(X, S, Y, expected_in_degree = 50)
sane_fm

}
