function parameters = default_parameters()
%DEFAULT_PARAMETERS Default parameters for the iterative change detection
%methods proposed in the paper.

    parameters.lambdaInitial = 1;
    parameters.lambdaStep = 1;
    parameters.lambdaMax = 13;

    parameters.neighborhoodRadius = 9;

    parameters.tolerance = 1e-6;
    parameters.maxIterations = 500;

end