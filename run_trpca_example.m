%% Iterative TRPCA-Based SAR Change Detection Example
%
% This example demonstrates how to execute the iterative TRPCA-based
% change detection method proposed in:
%
% "An Iterative Unsupervised Change Detection Method Based on Robust PCA
% for Small SAR Image Datasets."
%
% Before running this example:
%
%   1. Download the CARABAS-II dataset.
%   2. Copy one surveillance image to:
%
%          data/surveillance.mat
%
%   3. Copy one reference image to:
%
%          data/reference.mat
%
% Both MAT files must contain the SAR image in a variable named "im".

clc
close all

%% Configure repository

setup

%% Define input files

surveillanceFile = fullfile( ...
    'data', ...
    'surveillance.mat');

referenceFile = fullfile( ...
    'data', ...
    'reference.mat');

%% Load SAR images

surveillanceImage = load_sar_image(surveillanceFile);
referenceImage = load_sar_image(referenceFile);

%% Configure method parameters

parameters = default_parameters();

%% Run the proposed iterative TRPCA method

result = iterative_trpca_cd( ...
    surveillanceImage, ...
    referenceImage, ...
    parameters);

%% Display results

figure

tiledlayout(1,3, ...
    'TileSpacing','compact', ...
    'Padding','compact');

nexttile
imagesc(surveillanceImage)
axis image off
title('Surveillance Image')

nexttile
imagesc(referenceImage)
axis image off
title('Reference Image')

nexttile
imagesc(result.detectionMap)
axis image off
title(sprintf( ...
    'Detection Map (\\lambda multiplier = %g)', ...
    result.lambdaMultiplier))

colormap(gray)

sgtitle('Iterative TRPCA-Based SAR Change Detection')