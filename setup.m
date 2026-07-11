function setup()
%SETUP Configure the MATLAB path for this repository.
%
%   Run this function once before executing the examples.

    repositoryRoot = fileparts(mfilename('fullpath'));

    addpath(fullfile(repositoryRoot, 'src'));

    rpcaPath = fullfile(repositoryRoot, 'external', 'RobustPCA');
    trpcaPath = fullfile( ...
        repositoryRoot, ...
        'external', ...
        'Tensor-Robust-Principal-Component-Analysis-TRPCA');

    if isfolder(rpcaPath)
        addpath(genpath(rpcaPath));
    else
        warning( ...
            'setup:RobustPCANotFound', ...
            ['RobustPCA was not found in external/RobustPCA. ' ...
             'Download it from https://github.com/dlaptev/RobustPCA']);
    end

    if isfolder(trpcaPath)
        addpath(genpath(trpcaPath));
    else
        warning( ...
            'setup:TRPCANotFound', ...
            ['TRPCA was not found in external/' ...
             'Tensor-Robust-Principal-Component-Analysis-TRPCA. ' ...
             'Download it from https://github.com/canyilu/' ...
             'Tensor-Robust-Principal-Component-Analysis-TRPCA']);
    end

    fprintf('Repository paths configured successfully.\n');
end