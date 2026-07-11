function result = iterative_trpca_cd( ...
    surveillanceImage, referenceImage, parameters)
%ITERATIVE_TRPCA_CD Iterative TRPCA-based SAR change detection.
%
%   RESULT = ITERATIVE_TRPCA_CD(SURVEILLANCEIMAGE, REFERENCEIMAGE,
%   PARAMETERS) applies the iterative TRPCA-based change detection method
%   proposed in:
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
%   The input tensor is organized as:
%
%       number of images x image height x image width
%
%   At each iteration, the reference image is reconstructed as
%
%       I_R^(t) = L_R^(t) + S_R^(t)
%
%   and appended along the first dimension of the input tensor.

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
            'iterative_trpca_cd:InvalidParameters', ...
            'parameters must be a structure.');
    end

    requiredFields = { ...
        'lambdaInitial', ...
        'lambdaStep', ...
        'lambdaMax', ...
        'neighborhoodRadius'};

    for fieldIndex = 1:numel(requiredFields)
        fieldName = requiredFields{fieldIndex};

        if ~isfield(parameters, fieldName)
            error( ...
                'iterative_trpca_cd:MissingParameter', ...
                'Missing required parameter: parameters.%s', ...
                fieldName);
        end
    end

    if ~isequal(size(surveillanceImage), size(referenceImage))
        error( ...
            'iterative_trpca_cd:ImageSizeMismatch', ...
            'The surveillance and reference images must have the same size.');
    end

    if parameters.lambdaStep <= 0
        error( ...
            'iterative_trpca_cd:InvalidLambdaStep', ...
            'parameters.lambdaStep must be greater than zero.');
    end

    if parameters.lambdaMax < parameters.lambdaInitial
        error( ...
            'iterative_trpca_cd:InvalidLambdaRange', ...
            ['parameters.lambdaMax must be greater than or equal to ' ...
             'parameters.lambdaInitial.']);
    end

    if parameters.neighborhoodRadius < 0 || ...
            fix(parameters.neighborhoodRadius) ~= ...
            parameters.neighborhoodRadius
        error( ...
            'iterative_trpca_cd:InvalidNeighborhoodRadius', ...
            ['parameters.neighborhoodRadius must be a nonnegative ' ...
             'integer.']);
    end

    surveillanceImage = double(surveillanceImage);
    referenceImage = double(referenceImage);

    [imageHeight, imageWidth] = size(surveillanceImage);

    % Tensor organization:
    %
    %   dimension 1: images
    %   dimension 2: image rows
    %   dimension 3: image columns
    originalInput = zeros( ...
        2, ...
        imageHeight, ...
        imageWidth);

    originalInput(1,:,:) = surveillanceImage;
    originalInput(2,:,:) = referenceImage;

    currentInput = originalInput;

    reconstructedReferences = zeros( ...
        0, ...
        imageHeight, ...
        imageWidth);

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

        [numberOfImages, tensorHeight, tensorWidth] = ...
            size(currentInput);

        lambda = lambdaMultiplier / ...
            sqrt(max(numberOfImages, tensorHeight) * tensorWidth);

        fprintf( ...
            ['Iteration %d/%d | lambda multiplier = %.4g | ' ...
             'lambda = %.4g\n'], ...
            iterationIndex, ...
            numberOfIterations, ...
            lambdaMultiplier, ...
            lambda);

        [lowRank, sparse, ~, ~, ~] = ...
            trpca_tnn(currentInput, lambda);

        % Convert the sparse tensor into the matrix convention expected by
        % apply_method_rules:
        %
        %   number of images x number of pixels
        sparseMatrix = zeros( ...
            numberOfImages, ...
            imageHeight * imageWidth);

        for imageIndex = 1:numberOfImages

            sparseImage = squeeze( ...
                sparse(imageIndex,:,:));

            sparseMatrix(imageIndex,:) = reshape( ...
                transpose(sparseImage), ...
                1, ...
                []);
        end

        [detectionMap, ~] = apply_method_rules( ...
            sparseMatrix, ...
            imageWidth, ...
            parameters.neighborhoodRadius);

        iterations(iterationIndex).iteration = iterationIndex;
        iterations(iterationIndex).lambdaMultiplier = ...
            lambdaMultiplier;
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
            reconstructedReference = squeeze( ...
                lowRank(2,:,:) + sparse(2,:,:));

            reconstructedReferences(end + 1,:,:) = ...
                reconstructedReference;

            % Increase the number of tensor images at each iteration:
            %
            %     I_S, I_R, I_R^(1), I_R^(2), ..., I_R^(t)
            currentInput = cat( ...
                1, ...
                originalInput, ...
                reconstructedReferences);
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