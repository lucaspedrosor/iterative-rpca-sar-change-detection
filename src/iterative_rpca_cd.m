function result = iterative_rpca_cd(surveillanceImage, referenceImage, parameters)
%ITERATIVE_RPCA_CD Iterative RPCA-based SAR change detection.
%
%   RESULT = ITERATIVE_RPCA_CD(SURVEILLANCEIMAGE, REFERENCEIMAGE, PARAMETERS)
%   applies the iterative RPCA-based change detection method proposed in:
%
%   "An Iterative Unsupervised Change Detection Method Based on Robust PCA
%   for Small SAR Image Datasets."
%
%   Inputs
%   ------
%   surveillanceImage : 2-D numeric matrix
%       Surveillance SAR image.
%
%   referenceImage : 2-D numeric matrix
%       Reference SAR image. It must have the same size as the surveillance
%       image.
%
%   parameters : structure
%       parameters.lambdaInitial
%       parameters.lambdaStep
%       parameters.lambdaMax
%       parameters.neighborhoodRadius
%       parameters.tolerance
%       parameters.maxIterations
%
%   Output
%   ------
%   result : structure
%       result.detectionMap
%       result.lowRank
%       result.sparse
%       result.lambda
%       result.lambdaMultiplier
%       result.iterations
%       result.imageHeight
%       result.imageWidth
%       result.parameters
%
%   Notes
%   -----
%   At each iteration, the reference image is reconstructed as
%
%       I_R^(t) = L_R^(t) + S_R^(t)
%
%   and appended to the original surveillance and reference images.
%
%   The complete low-rank and sparse components are stored only for the
%   final iteration to reduce memory usage. Intermediate detection maps are
%   stored in result.iterations.

    if nargin < 3 || isempty(parameters)
        parameters = default_parameters();
    end

    validateattributes( ...
        surveillanceImage, ...
        {'numeric'}, ...
        {'2d', 'nonempty', 'finite'}, ...
        mfilename, ...
        'surveillanceImage', ...
        1);

    validateattributes( ...
        referenceImage, ...
        {'numeric'}, ...
        {'2d', 'nonempty', 'finite'}, ...
        mfilename, ...
        'referenceImage', ...
        2);

    if ~isstruct(parameters)
        error( ...
            'iterative_rpca_cd:InvalidParameters', ...
            'parameters must be a structure.');
    end

    requiredFields = { ...
        'lambdaInitial', ...
        'lambdaStep', ...
        'lambdaMax', ...
        'neighborhoodRadius', ...
        'tolerance', ...
        'maxIterations'};

    for fieldIndex = 1:numel(requiredFields)
        fieldName = requiredFields{fieldIndex};

        if ~isfield(parameters, fieldName)
            error( ...
                'iterative_rpca_cd:MissingParameter', ...
                'Missing required parameter: parameters.%s', ...
                fieldName);
        end
    end

    if ~isequal(size(surveillanceImage), size(referenceImage))
        error( ...
            'iterative_rpca_cd:ImageSizeMismatch', ...
            'The surveillance and reference images must have the same size.');
    end

    if parameters.lambdaStep <= 0
        error( ...
            'iterative_rpca_cd:InvalidLambdaStep', ...
            'parameters.lambdaStep must be greater than zero.');
    end

    if parameters.lambdaMax < parameters.lambdaInitial
        error( ...
            'iterative_rpca_cd:InvalidLambdaRange', ...
            ['parameters.lambdaMax must be greater than or equal to ' ...
             'parameters.lambdaInitial.']);
    end

    if parameters.neighborhoodRadius < 0 || ...
            fix(parameters.neighborhoodRadius) ~= parameters.neighborhoodRadius
        error( ...
            'iterative_rpca_cd:InvalidNeighborhoodRadius', ...
            ['parameters.neighborhoodRadius must be a nonnegative ' ...
             'integer.']);
    end

    if parameters.tolerance <= 0
        error( ...
            'iterative_rpca_cd:InvalidTolerance', ...
            'parameters.tolerance must be greater than zero.');
    end

    if parameters.maxIterations <= 0 || ...
            fix(parameters.maxIterations) ~= parameters.maxIterations
        error( ...
            'iterative_rpca_cd:InvalidMaxIterations', ...
            'parameters.maxIterations must be a positive integer.');
    end

    surveillanceImage = double(surveillanceImage);
    referenceImage = double(referenceImage);

    [imageHeight, imageWidth] = size(surveillanceImage);

    % Convert each SAR image into one row of the RPCA input matrix.
    surveillanceVector = reshape(transpose(surveillanceImage), 1, []);
    referenceVector = reshape(transpose(referenceImage), 1, []);

    originalInput = [
        surveillanceVector
        referenceVector
    ];

    currentInput = originalInput;
    reconstructedReferences = [];

    lambdaMultipliers = ...
        parameters.lambdaInitial: ...
        parameters.lambdaStep: ...
        parameters.lambdaMax;

    numberOfIterations = numel(lambdaMultipliers);

    iterations(numberOfIterations) = struct( ...
        'iteration', [], ...
        'lambdaMultiplier', [], ...
        'lambda', [], ...
        'detectionMap', []);

    finalLowRank = [];
    finalSparse = [];
    finalDetectionMap = [];
    finalLambda = [];
    finalLambdaMultiplier = [];

    for iterationIndex = 1:numberOfIterations

        lambdaMultiplier = lambdaMultipliers(iterationIndex);

        lambda = ...
            lambdaMultiplier / sqrt(max(size(currentInput)));

        fprintf( ...
            ['Iteration %d/%d | lambda multiplier = %.4g | ' ...
             'lambda = %.4g\n'], ...
            iterationIndex, ...
            numberOfIterations, ...
            lambdaMultiplier, ...
            lambda);

        [lowRank, sparse] = RobustPCA( ...
            currentInput, ...
            lambda, ...
            10 * lambda, ...
            parameters.tolerance, ...
            parameters.maxIterations);

        [detectionMap, ~] = apply_method_rules( ...
            sparse, ...
            imageWidth, ...
            parameters.neighborhoodRadius);

        iterations(iterationIndex).iteration = iterationIndex;
        iterations(iterationIndex).lambdaMultiplier = lambdaMultiplier;
        iterations(iterationIndex).lambda = lambda;
        iterations(iterationIndex).detectionMap = detectionMap;

        finalLowRank = lowRank;
        finalSparse = sparse;
        finalDetectionMap = detectionMap;
        finalLambda = lambda;
        finalLambdaMultiplier = lambdaMultiplier;

        if iterationIndex < numberOfIterations

            % Reconstruct the reference image as defined in the paper:
            %
            %     I_R^(t) = L_R^(t) + S_R^(t)
            reconstructedReference = ...
                lowRank(2,:) + sparse(2,:);

            reconstructedReferences = [
                reconstructedReferences
                reconstructedReference
            ];

            % Increase the number of input images at each iteration:
            %
            %     I_S, I_R, I_R^(1), I_R^(2), ..., I_R^(t)
            currentInput = [
                originalInput
                reconstructedReferences
            ];
        end
    end

    result.detectionMap = finalDetectionMap;
    result.lowRank = finalLowRank;
    result.sparse = finalSparse;
    result.lambda = finalLambda;
    result.lambdaMultiplier = finalLambdaMultiplier;
    result.iterations = iterations;
    result.imageHeight = imageHeight;
    result.imageWidth = imageWidth;
    result.parameters = parameters;
end