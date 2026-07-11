function sarImage = load_sar_image(filename)
%LOAD_SAR_IMAGE Load a SAR image stored in a MAT file.
%
%   SARIMAGE = LOAD_SAR_IMAGE(FILENAME) loads the variable "im" from the
%   specified MAT file.
%
%   The function checks whether the file exists, whether the variable "im"
%   is present, and whether the loaded image is a valid two-dimensional
%   numeric array.

    arguments
        filename (1,:) char
    end

    if ~isfile(filename)
        error( ...
            'load_sar_image:FileNotFound', ...
            'The input file was not found: %s', ...
            filename);
    end

    data = load(filename);

    if ~isfield(data, 'im')
        error( ...
            'load_sar_image:MissingVariable', ...
            'The file "%s" does not contain a variable named "im".', ...
            filename);
    end

    sarImage = data.im;

    if ~isnumeric(sarImage) || ndims(sarImage) ~= 2
        error( ...
            'load_sar_image:InvalidImage', ...
            'The variable "im" must be a two-dimensional numeric array.');
    end

    if any(~isfinite(sarImage), 'all')
        error( ...
            'load_sar_image:InvalidValues', ...
            'The SAR image contains NaN or Inf values.');
    end

    sarImage = double(sarImage);
end