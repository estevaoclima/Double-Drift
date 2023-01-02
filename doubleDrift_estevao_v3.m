%% Basics
sca;
close all;
clear;
% Setup PTB
PsychDefaultSetup(2);
% Set to the external secondary monitor (if there's one)
screenNumber = max(Screen('Screens'));
% Define B&W
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,...
    [0 0 1800 1000], 32, 2, [], [], [], kPsychGUIWindow);
% Get the size of the screen in window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
% Get the center coordinate
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing % NAO ENTENDI P QUE SERVE ISSO...
%Screen('BlendFunction', window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Get the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
% Set maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);



%% GABOR infos
% Dimension of the region where will draw the Gabor in pixels
gaborDimPix = windowRect(4) / 10; % original: 4 ultimo 2
% Sigma of Gaussian
sigma = gaborDimPix / 5;% original: 7   20  13 ultimo 24
% Parameters
orientation = -135; % 90 gira 90 graus 45
contrast = 0.9; %antes era 0.7
aspectRatio = 1.0; % funciona em 1.0
phase = 0; % funciona wem 0
% Spatial Frequency (Cycles Per Pixel)
numCycles = 1; % original = 5 funciona bem com 3 7 ultimo 1
freq = numCycles / gaborDimPix;
% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5).
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
[gabortex, gaborrect] = CreateProceduralGabor(window, gaborDimPix, gaborDimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);
% Randomise the phase of the Gabors and make a properties matrix.
propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];



%% Drawing
% FLip to the vertical retrace rate
vbl = Screen('Flip', window);
% We will update the stimulus on each frame
waitframes = 1;
% Choose an arbitary value at which our Gabor will drift
phasePerFrame = 7 * pi; % original 4 %% frequencia do oscilacao do gabor bom em 6


%% moving grid
%% Grid will oscilate with a sinewave function to the left and right
amplitude = screenYpixels*0.1; % funciona bem com 0.3 0.09
frequency = 0.3; % ultimo era 0.9   funciona bem com 0.2; porem 0.1 pode ter melhorado a relacao movimento externo vs interno
angFreq = 2*pi*frequency; % era 2
startPhase = 0;
time = 0;



%% DOT
rng('shuffle')
% Determine a random position for the dot
dotXpos = rand*screenXpixels;
dotYpos = rand*screenYpixels;
% Dot charac:
dotColor = [1 0 0]; % red color
dotSizePix = 25; % size in pixels


while ~KbCheck
    %Position of the square on this frame
    gridPos = amplitude*sin(angFreq*time + startPhase);
    %gridPos = amplitude*sin(time+startPhase);

    % Define Gabor's position
    %dstRect = OffsetRect(gaborrect, 1200, yCenter-100+gridPos);
    dstRect = OffsetRect(gaborrect, 1300+gridPos, yCenter-50+gridPos);

    % Draw the Gabor
    Screen('DrawTextures', window, gabortex, [], dstRect, orientation, [], [], [], [],...
        kPsychDontDoRotation, propertiesMat');
     
    % fixation Dot 
    Screen('DrawDots', window, [xCenter-500; yCenter], 20, [0.25 0.25 0.25], [], 2);

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Update the phase element of the properties matrix 
    if cos(angFreq*time + startPhase) < 0
        j = -1;
    else
        j = 1;
    end
    propertiesMat(1) = propertiesMat(1) - phasePerFrame*j; % add if statement para inverter sentido da rotacao

    % increment the time
    time = time + ifi;

end

Priority(0);
sca;
