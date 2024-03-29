function images()
    % Open a window in windowed-mode and create a canvas.
    window = Window([640, 480], false);
    canvas = Canvas(window);
    
    % Read a few images from file.
    imagesDir = fullfile(fileparts(mfilename('fullpath')), 'Images');
    butterflyImage = imread(fullfile(imagesDir, 'butterfly.jpg'));
    
    [horseImage, ~, horseAlpha] = imread(fullfile(imagesDir, 'horse.png'));
    horseImage(:, :, 4) = horseAlpha;
    
    % Create a few image stimuli.
    butterfly = Image(butterflyImage);
    butterfly.size = [size(butterflyImage, 2), size(butterflyImage, 1)];
    butterfly.position = canvas.size / 2;
    
    mask = Mask.createGaussianEnvelope();
    butterfly.setMask(mask);  
    
    darkHorse = Image(horseImage);
    darkHorse.size = [size(horseImage, 2), size(horseImage, 1)];
    darkHorse.color = 0;
    
    lightHorse = Image(horseImage);
    lightHorse.size = [-size(horseImage, 2)/2, size(horseImage, 1)/2];
    lightHorse.color = 1;
    
    % Create controllers to change the horse positions as functions of time.
    lightHorsePositionController = PropertyController(lightHorse, 'position', @(state)[canvas.width-state.time*75-100, canvas.height/2]);
    darkHorsePositionController = PropertyController(darkHorse, 'position', @(state)[state.time*100, canvas.height/2-50]);
    
    % Create a 6 second presentation and add the stimuli and controllers.
    presentation = Presentation(6);
    presentation.addStimulus(lightHorse);
    presentation.addStimulus(butterfly);
    presentation.addStimulus(darkHorse);
    presentation.addController(lightHorsePositionController);
    presentation.addController(darkHorsePositionController);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end