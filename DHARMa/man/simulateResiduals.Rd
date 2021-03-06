% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulateResiduals.R
\name{simulateResiduals}
\alias{simulateResiduals}
\title{Create simulated residuals}
\usage{
simulateResiduals(fittedModel, n = 250, refit = F,
  integerResponse = NULL, plot = F, seed = 123, method = c("PIT",
  "traditional"), ...)
}
\arguments{
\item{fittedModel}{a fitted model  of a class supported by DHARMa}

\item{n}{number of simulations. The smaller the number, the higher the stochastic error on the residuals. Also, for very small n, discretization artefacts can influence the tests. Default is 250, which is a relatively safe value. You can consider increasing to 1000 to stabilize the simulated values.}

\item{refit}{if FALSE, new data will be simulated and scaled residuals will be created by comparing observed data with new data. If TRUE, the model will be refit on the simulated data (parametric bootstrap), and scaled residuals will be created by comparing observed with refitted residuals.}

\item{integerResponse}{if TRUE, noise will be added at to the residuals to maintain a uniform expectations for integer responses (such as Poisson or Binomial). Usually, the model will automatically detect the appropriate setting, so there is no need to adjust this setting.}

\item{plot}{if TRUE, \code{\link{plotResiduals}} will be directly run after the residuals have been calculated}

\item{seed}{the random seed to be used within DHARMa. The default setting, recommended for most users, is keep the random seed on a fixed value 123. This means that you will always get the same randomization and thus teh same result when running the same code. NULL = no new seed is set, but previous random state will be restored after simulation. FALSE = no seed is set, and random state will not be restored. The latter two options are only recommended for simulation experiments. See vignette for details.}

\item{method}{the quantile randomization method used. The two options implemented at the moment are probability integral transform (PIT-) residuals (current default), and the "traditional" randomization procedure, that was used in DHARMa until version 0.3.0. For details, see \code{\link{getQuantile}}}

\item{...}{parameters to pass to the simulate function of the model object. An important use of this is to specify whether simulations should be conditional on the current random effect estimates, e.g. via re.form. Note that not all models support syntax to specify conditionao or unconditional simulations. See also details}
}
\value{
An S3 class of type "DHARMa", essentially a list with various elements. Implemented S3 functions include plot, print and \code{\link{residuals.DHARMa}}. Residuals returns the calculated scaled residuals.
}
\description{
The function creates scaled residuals by simulating from the fitted model. Residuals can be extracted with \code{\link{residuals.DHARMa}}. See \code{\link{testResiduals}} for an overview of residual tests, \code{\link{plot.DHARMa}} for an overview of available plots.
}
\details{
There are a number of important considerations when simulating from a more complex (hierarchical) model:

\strong{Re-simulating random effects / hierarchical structure}: in a hierarchical model, we have several stochastic processes aligned on top of each other. Specifically, in a GLMM, we have a lower level stochastic process (random effect), whose result enters into a higher level (e.g. Poisson distribution). For other hierarchical models such as state-space models, similar considerations apply.

In such a situation, we have to decide if we want to re-simulate all stochastic levels, or only a subset of those. For example, in a GLMM, it is common to only simulate the last stochastic level (e.g. Poisson) conditional on the fitted random effects. This is often referred to as a conditional simuation. For controlling how many levels should be re-simulated, the simulateResidual function allows to pass on parameters to the simulate function of the fitted model object. Please refer to the help of the different simulate functions (e.g. ?simulate.merMod) for details. For merMod (lme4) model objects, the relevant parameters are parameters are use.u and re.form

If the model is correctly specified, the simulated residuals should be flat regardless how many hierarchical levels we re-simulate. The most thorough procedure would therefore be to test all possible options. If testing only one option, I would recommend to re-simulate all levels, because this essentially tests the model structure as a whole. This is the default setting in the DHARMa package. A potential drawback is that re-simulating the lower-level random effects creates more variability, which may reduce power for detecting problems in the upper-level stochastic processes. In particular dispersion tests may produce different results when switching from conditional to unconditional simulations, and often the conditional simulation is more sensitive.

\strong{Integer responses}: a second complication is the treatment of inter responses. Imaging we have observed a 0, and we predict 30\% zeros - what is the quantile that we should display for the residual? To deal with this problem and maintain a uniform response, the option integerResponse adds a uniform noise from -0.5 to 0.5 on the simulated and observed response, which creates a uniform distribution - you can see this via hist(ecdf(runif(10000))(runif(10000))).

 DHARMa will try to automatically if the fitted model has an integer or discrete distribution via the family argument. However, in some cases the family does not allow to uniquely identify the distribution type. For example, a tweedie distribution can be inter or continuous. Therefore, DHARMa will additionally check the simulation results for repeated values, and will change the distribution type if repeated values are found (a message is displayed in this case).

\strong{Refitting or not}: a third issue is how residuals are calculated. simulateResiduals has two options that are controlled by the refit parameter:

1. if refit = FALSE (default), new data is simulated from the fitted model, and residuals are calculated by comparing the observed data to the new data

2. if refit = TRUE, a parametric bootstrap is performed, meaning that the model is refit on the new data, and residuals are created by comparing observed residuals against refitted residuals. I advise against using this method per default (see more comments in the vignette), unless you are really sure that you need it.

\strong{Residuals per group}: In many situations, it can be useful to look at residuals per group, e.g. to see how much the model over / underpredicts per plot, year or subject. To do this, use \code{\link{recalculateResiduals}}, together with a grouping variable (see also help)

\strong{Transformation to other distributions}: DHARMa calculates residuals for which the theoretical expectation (assuming a correctly specified model) is uniform. To transfor this residuals to another distribution (e.g. so that a correctly specified model will have normal residuals) see \code{\link{residuals.DHARMa}}.
}
\examples{
library(lme4)

testData = createData(sampleSize = 100, overdispersion = 0.5, family = poisson())
fittedModel <- glmer(observedResponse ~ Environment1 + (1|group), 
                     family = "poisson", data = testData)

simulationOutput <- simulateResiduals(fittedModel = fittedModel)

# standard plot 
plot(simulationOutput)

# one of the possible test, for other options see ?testResiduals / vignette
testDispersion(simulationOutput)

# the calculated residuals can be accessed via 
residuals(simulationOutput)

# transform residuals to other pdf, see ?residuals.DHARMa for details
residuals(simulationOutput, quantileFunction = qnorm, outlierValues = c(-7,7))

# calculating residuals per group
simulationOutput = recalculateResiduals(simulationOutput, group = testData$group)
plot(simulationOutput, quantreg = FALSE)



}
\seealso{
\code{\link{testResiduals}}, \code{\link{plot.DHARMa}}, \code{\link{plotResiduals}}, \code{\link{print.DHARMa}}, \code{\link{residuals.DHARMa}}, \code{\link{recalculateResiduals}}
}
