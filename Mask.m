% A transparency (alpha) mask.

classdef Mask < handle
    
    properties (SetAccess = private)
        texture
    end
    
    properties (Access = private)
        matrix
    end
    
    methods
        
        % Constructs a mask from an M-by-N-by-1 matrix. A value of 0 is completely transparent. A value of 255 is
        % completely opaque.
        function obj = Mask(matrix)
            if ~isa(matrix, 'uint8')
                error('Matrix must be of class uint8')
            end
            
            obj.matrix = matrix;
        end
        
        function init(obj, canvas)
            width = size(obj.matrix, 2);
            height = size(obj.matrix, 1);
            
            mask = zeros(height, width, 4, 'uint8');
            mask(:, :, 4) = obj.matrix;
            
            obj.texture = TextureObject(canvas, 2);
            obj.texture.setImage(mask);
            obj.texture.generateMipmap();
        end
        
    end
    
    methods (Static)
        
        % Creates a circular envelope mask.
        function mask = createCircleMask(resolution)
            if nargin < 1
                resolution = 256;
            end
            
            distanceMatrix = createDistanceMatrix(resolution);
            
            circle = uint8((distanceMatrix <= 1) * 255);
            mask = Mask(circle);
        end
        
        % Creates a gaussian envelope mask.
        function mask = createGaussianMask(resolution)
            if nargin < 1
                resolution = 256;
            end
            
            distanceMatrix = createDistanceMatrix(resolution);
            
            sigma = 1/3;
            gaussian = uint8(exp(-distanceMatrix.^2 / (2 * sigma^2)) * 255);
            mask = Mask(gaussian);
        end
        
    end
    
end

function m = createDistanceMatrix(size)
    step = 2 / (size - 1);
    [xx, yy] = meshgrid(-1:step:1, -1:step:1);
    m = sqrt(xx.^2 + yy.^2);
end