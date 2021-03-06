% Run the calculateBoundaryCrossingLatency for each subject

% UCDMC13
getTurnDirectionAfterTeleport(...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Subjects/UCDMC13/Behavioral Data/s1_patientTeleporterData.txt', ...
    0, ...
    'TeleporterA', ...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Pepisode_Behavior/csv/UCDMC13_TeleporterA_Turn_Direction.csv');


% UCDMC14
getTurnDirectionAfterTeleport(...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Subjects/UCDMC14/Behavioral Data/TeleporterA/s2_patientTeleporterData.txt', ...
    0, ...
    'TeleporterA', ...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Pepisode_Behavior/csv/UCDMC14_TeleporterA_Turn_Direction.csv');

getTurnDirectionAfterTeleport(...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Subjects/UCDMC14/Behavioral Data/TeleporterB/s2_patientTeleporterData 2.txt', ...
    0, ...
    'TeleporterB', ...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Pepisode_Behavior/csv/UCDMC14_TeleporterB_Turn_Direction.csv');


% UCDMC15
getTurnDirectionAfterTeleport(...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Subjects/UCDMC15/Behavioral Data/TeleporterA/s3_FindStore_TeleporterA_FIXED.txt', ...
    1, ...
    'TeleporterA', ...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Pepisode_Behavior/csv/UCDMC15_TeleporterA_Turn_Direction.csv');

getTurnDirectionAfterTeleport(...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Subjects/UCDMC15/Behavioral Data/TeleporterB/s3_FindStore_TeleporterB_FIXED.txt', ...
    1, ...
    'TeleporterB', ...
    '/Users/Lindsay/Documents/MATLAB/iEEG/Group Analysis/Pepisode_Behavior/csv/UCDMC15_TeleporterB_Turn_Direction.csv');