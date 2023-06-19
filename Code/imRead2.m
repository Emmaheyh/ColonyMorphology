function M = imRead2(varargin)
% Load tiff image file(s).
%
% Usage: M = imRead2
%        M = imRead2(name)
%        M = imRead2(..., 'range', value)
%        M = imRead2(..., 'show', [false]|true)
%
% NAME: A string that specifies the name and path of the file to be loaded.
%
% If NAME contains the wild card '*', all files satisfying the given
% pattern will be loaded and put into a image stack.
%
% If NAME is not specified or is empty (''), a window will appear to let
% user select the file(s) to be loaded.
%
% RANGE: A string specifying the frames to load.
% For example, '2:2:end' means loading all even frames. Default: '1:end'.
%
% SHOW: A logical varible specifying whether to display loading progress.
% Default: true.
%
% M: An array storing the image(s). The size of M can be Ny x Nx (single
% frame image), Ny x Nx x 3 (single frame truecolor image), Ny x Nx x Nt
% (single channel movie), and Ny x Nx x 3 x Nt (truecolor movie).
% If no image is found, or user cancels the loading while selecting the
% file, the program returns an empty arrary -- [].
%
% Written by Jintao Liu @ Suel Lab, UCSD.
% Version 0.3.2. Created on May 04, 2015. Last modified on Aug 05, 2017.

[filename, opt] = parseInput(varargin{:});

% filename is a cell array of file names and path
% opt contains all the input values

N_file = numel(filename);
if N_file < 1
    error('No image found!')
elseif N_file == 1
    info = imfinfo(filename{1}, 'tif');
    index = 1:numel(info);
else
    index = 1:N_file;
end
index = eval(['index(' opt.range ')']);


tmp = imWhos(filename{1});
M_class = tmp.class;
M_size  = [tmp.size(1:end-1), numel(index)];
M_bytes = tmp.bytes / tmp.size(end) * M_size(end);


if ispc  % memory checking currently only availabel on Windows
    [~, sys] = memory;
    if M_bytes > sys.PhysicalMemory.Available
        error('Not enough memory.');
    end
end


M = zeros(M_size, M_class);
idx = repmat({':'}, 1, length(M_size)-1);
for m = 1:M_size(end)
    if N_file == 1
        M(idx{:},m) = imread(filename{1}, index(m), 'info', info);
    else
        M(idx{:},m) = imread(filename{index(m)}, 'tif');
        % warning: only load first frame if there are multiple frames
    end
    if opt.show
        fprintf('%d/%d\n',m,M_size(end));
    end
end


function [filename, opt] = parseInput(varargin)    
    argin = inputParser;
    argin.addOptional('name', '', @ischar)
    argin.addParamValue('range', '1:end', @ischar)
    argin.addParamValue('show', true)
    argin.parse(varargin{:})
    
    opt  = argin.Results;
    
    if isempty(opt.name)
        [filename, filepath] = uigetfile({'*.tif; *.tiff'}, ...
            'Select a TIFF file to load');
        if filename == 0
            filename = {};
        else
            filename = {filename};
        end
    else
        filename = ls2(opt.name);
        filepath = fileparts(opt.name);
        if isempty(filepath)
            filepath = pwd;
        end
    end
    for k = 1:numel(filename)
        filename{k} = [filepath '/' filename{k}];
    end
end

end