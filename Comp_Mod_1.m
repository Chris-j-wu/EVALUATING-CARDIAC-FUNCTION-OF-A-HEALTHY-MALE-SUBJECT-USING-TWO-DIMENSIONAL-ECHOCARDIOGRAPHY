clear all;

%{ 
Overview of the program:
1. read mp4 video files to video objects
2. let user determine the ED and ES frames they want to pick for each of
the four views from the videos. For example, the user may use:
    Mitral - ED 29 ES 41
    Papailary - ED 34 ES 46
    Apex - ED 36 ES 48
    Apical - ED 33 ES 42
3. save the 8 (4x2) frames chosen by the user to a folder called 'frames'
4. display the frames one by one and let the user pick two points (wait
until the crosshair shows up before clicking) for each image. The two points are
used to calculate the left ventricular short-/long-axis length
5. calculate and print EDV, ESV, and SV
%}

%% Read video files
mitral = read(VideoReader("SA_MitralVolunteer.mp4"));
papilary = read(VideoReader("SA_PapilaryVolunteer.mp4"));
apex = read(VideoReader("SA_ApexVolunteer.mp4"));
apical = read(VideoReader("Apical4chVolunteer.mp4"));

file_names = {'Mitral_ED.jpg', 'Mitral_ES.jpg','Papilary_ED.jpg','Papilary_ES.jpg',
    'Apex_ED.jpg', 'Apex_ES.jpg', 'Apical_ED.jpg', 'Apical_ES.jpg'};

%% Save all the ED and ES frames in a new directory called "frames"
mkdir frames
cd frames

% prompt the user to pick out the frames

frames = zeros(1,8); % stores all frames
for i = 1:length (frames)
    switch i
        case 1
           frames(i) = input('Please enter the end-diastole frame number for the mitral view: ');
        case 2
           frames(i) = input('Please enter the end-systole frame number for the mitral view: ');
        case 3
           frames(i) = input('Please enter the end-diastole frame number for the papilary view: '); 
        case 4
           frames(i) = input('Please enter the end-systole frame number for the papilary view: ');
        case 5
           frames(i) = input('Please enter the end-diastole frame number for the apex view: ');
        case 6
           frames(i) = input('Please enter the end-systole frame number for the apex view: ');
        case 7
           frames(i) = input('Please enter the end-diastole frame number for the apical view: '); 
        case 8
           frames(i) = input('Please enter the end-systole frame number for the apical view: ');
    end
end

video_files = {mitral, papilary, apex, apical}; % stores all video objects read by VideoReader
for i = 1:length(frames)
    image = video_files{round(i/2)}(:,:,:,frames(i));
    imwrite(image, file_names{i}); % write image
end

SCALE = 24; % 24 px per cm
distances = zeros(1, 8); % stores all long- and short-axis lengths

% show user the 8 images they picked one by one and let them pick two
% coordinates for each image 
% the two points are used to calculate the short-/long-axis lengths
for i = 1:length(frames)
    imshow(imread(file_names{i}));
    coor = ginput(2); % take user input for two points
    distances(i) = sqrt((coor(1,1) - coor(2,1))^2 + (coor(1,2) - coor(2,2))^2) / SCALE; % find distance between the two points ans save to array
end
close all;

cd .. 

%% Calculate EDV, ESV, and SV
D = distances(1:6); % short-axis lengths
L = distances(7:8); % long-axis lengths
A = zeros(1,6); % area
for i = 1 : length(D)  
    A(i) = (pi * D(i) ^ 2) / 4; % calculate area and store in array
end

% calculate end-diastolic volume using modified Simpson's rule
EDV = (A(1) + A(3)) * L(1) / 3 + A(5) * L(1) / 6 + pi * (L(1)/3)^3 / 6;

% calcaulte end-systolic volume
ESV = (A(2) + A(4)) * L(2) / 3 + A(6) * L(2) / 6 + pi * (L(2)/3)^3 / 6;

SV = EDV - ESV; % stroke volume
EF = SV / EDV; % ejection fraction
CO = SV * 60; % cardiac output (HR = 60)

% print results
results = ['EDV = ', num2str(EDV),' ESV = ', num2str(ESV), ' SV = ', num2str(SV), ' EF = ', num2str(EF), ' CO = ', num2str(CO)];
disp(results);