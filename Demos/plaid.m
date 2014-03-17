function plaid()
    % Open a window in windowed-mode.
    window = Window([640, 480], false);
    
    % Create a canvas on the window.
    canvas = Canvas(window);
    
    % Set the canvas background color to gray.
    canvas.setClearColor(0.5);
    canvas.clear();
    
    % Create two grating stimuli to layer on one another.
    grating1 = Grating();
    grating1.position = canvas.size / 2;
    grating1.size = [300, 300];
    grating1.spatialFreq = 1/100; % 1 cycle per 100 pixels
    grating1.orientation = 45;
    
    grating2 = Grating();
    grating2.position = grating1.position;
    grating2.size = grating1.size;
    grating2.spatialFreq = grating1.spatialFreq;
    grating2.orientation = 135;
    grating2.opacity = 0.5;
    
    % Assign a circular envelope mask to the gratings.
    grating1.setMask(Mask.createCircularEnvelope());
    grating2.setMask(Mask.createCircularEnvelope());
    
    % Create a 5 second presentation.
    presentation = Presentation(5);
    
    % Add the grating stimuli to the presentation.
    presentation.addStimulus(grating1);
    presentation.addStimulus(grating2);
    
    % Define the grating phases as functions of time. The first grating will shift 360 degrees per second. The second 
    % grating will shift 180 degrees per second.
    presentation.addController(grating1, 'phase', @(state)state.time * 360);
    presentation.addController(grating2, 'phase', @(state)state.time * 180);
    
    % Play the presentation on the canvas!
    presentation.play(canvas);
    
    % Window automatically closes when the window object is deleted.
end