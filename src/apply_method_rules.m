function [detectionMap, detectionVector] = apply_method_rules( ...
    sparseComponent, imageWidth, neighborhoodRadius)
%APPLY_METHOD_RULES Apply the Method Rules to the sparse component.
%
%   [DETECTIONMAP, DETECTIONVECTOR] = APPLY_METHOD_RULES(
%   SPARSECOMPONENT, IMAGEWIDTH, NEIGHBORHOODRADIUS) applies the Method
%   Rules proposed in the paper.
%
%   The rules are:
%
%   1. Detections are considered only in the sparse component associated
%      with the surveillance image, represented by the first row or slice.
%
%   2. Only positive sparse values are considered.
%
%   3. A positive detection in the surveillance image is rejected when
%      sparse content is present within the specified neighborhood in any
%      reference image.
%
%   Inputs
%   ------
%   sparseComponent : numeric matrix or 3-D numeric array
%       RPCA input:
%           N-by-(height*width), where each row represents one image.
%
%       TRPCA input:
%           height-by-width-by-N, where each slice represents one image.
%
%   imageWidth : positive integer
%       Width of the original SAR images. Required when the sparse
%       component is provided in matrix form.
%
%   neighborhoodRadius : nonnegative integer
%       Distance from the central pixel to the comparison-window border.
%       The window size is:
%
%           (2*neighborhoodRadius + 1)-by-
%           (2*neighborhoodRadius + 1)
%
%       Set this value to zero to disable the neighborhood comparison.
%
%   Outputs
%   -------
%   detectionMap : 2-D numeric matrix
%       Sparse surveillance content remaining after the Method Rules.
%
%   detectionVector : row vector
%       Vectorized representation of detectionMap.

    arguments
        sparseComponent {mustBeNumeric, mustBeNonempty}
        imageWidth (1,1) double {mustBeInteger, mustBePositive}
        neighborhoodRadius (1,1) double ...
            {mustBeInteger, mustBeNonnegative} = 9
    end

    % Rule 2: discard negative sparse values.
    positiveSparse = sparseComponent;
    positiveSparse(positiveSparse < 0) = 0;

    % Convert the RPCA matrix representation into an image stack.
    if ismatrix(positiveSparse)

        numberOfPixels = size(positiveSparse, 2);

        if mod(numberOfPixels, imageWidth) ~= 0
            error( ...
                'apply_method_rules:InvalidImageWidth', ...
                ['The number of pixels in each sparse row must be ' ...
                 'divisible by imageWidth.']);
        end

        imageHeight = numberOfPixels / imageWidth;
        numberOfImages = size(positiveSparse, 1);

        sparseStack = zeros( ...
            imageHeight, ...
            imageWidth, ...
            numberOfImages, ...
            'like', ...
            positiveSparse);

        for imageIndex = 1:numberOfImages
            sparseStack(:,:,imageIndex) = transpose(reshape( ...
                positiveSparse(imageIndex,:), ...
                imageWidth, ...
                imageHeight));
        end

    elseif ndims(positiveSparse) == 3

        sparseStack = positiveSparse;
        imageHeight = size(sparseStack, 1);

        if size(sparseStack, 2) ~= imageWidth
            error( ...
                'apply_method_rules:ImageWidthMismatch', ...
                'imageWidth does not match the width of the sparse stack.');
        end

    else
        error( ...
            'apply_method_rules:InvalidInputDimensions', ...
            'The sparse component must be a 2-D matrix or a 3-D array.');
    end

    numberOfImages = size(sparseStack, 3);

    if numberOfImages < 2
        error( ...
            'apply_method_rules:InsufficientImages', ...
            ['At least one surveillance image and one reference image ' ...
             'are required.']);
    end

    % Rule 1: only the first sparse image can generate detections.
    surveillanceSparse = sparseStack(:,:,1);

    if neighborhoodRadius == 0
        detectionMap = surveillanceSparse;
        detectionVector = reshape(transpose(detectionMap), 1, []);
        return;
    end

    if 2 * neighborhoodRadius + 1 > ...
            min(imageHeight, imageWidth)
        error( ...
            'apply_method_rules:NeighborhoodTooLarge', ...
            'The comparison neighborhood is larger than the input image.');
    end

    detectionMap = zeros( ...
        imageHeight, ...
        imageWidth, ...
        'like', ...
        sparseStack);

    rowRange = ...
        neighborhoodRadius + 1:imageHeight - neighborhoodRadius;

    columnRange = ...
        neighborhoodRadius + 1:imageWidth - neighborhoodRadius;

    for row = rowRange
        for column = columnRange

            if surveillanceSparse(row, column) <= 0
                continue;
            end

            referenceNeighborhood = sparseStack( ...
                row-neighborhoodRadius:row+neighborhoodRadius, ...
                column-neighborhoodRadius:column+neighborhoodRadius, ...
                2:end);

            % Rule 3: retain the surveillance detection only when no
            % positive reference content exists inside the neighborhood.
            if ~any(referenceNeighborhood(:) > 0)
                detectionMap(row, column) = ...
                    surveillanceSparse(row, column);
            end
        end
    end

    detectionVector = reshape(transpose(detectionMap), 1, []);
end