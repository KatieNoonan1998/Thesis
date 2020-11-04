function FishSeperation(DicomName)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version 1.3: Some fish are much closer than anticipated, some even
% overlapping. Reduced necessary distance between fish. Runs from 200 to
% 50, cut from n to n+100.

% Make HA error line

% Fix averaging for that line

% Change sectioning loop

% Check out bwlabel

Info = dicominfo(DicomName);

DicomName = DicomName(1 : (end - 4));

[FishHA, Map] = dicomread(Info);

figure()

imshow(FishHA, Map)

Amount = input('How many fish in the image:?\n');

%% Removing the hydrox

VerticalSlice = FishHA(:, 10);

figure()

% imshow(VerticalSlice, Map)

AverageMinV = mean(min(Vertical));

Below = (VerticalSlice <= AverageMinV);

Count = 0;

for n = [1 : (length(Below) - 1)]
    
    if Below(n) ~= Below(n + 1)
        
            Count = Count + 1;
            
            Reference = floor(0.6*n);
            
    end
    
    if Count > 1
        
        n = ceil(1.2*n);
        
        break;
        
    end
    
end

Fish = FishHA((n : end), :);

figure()

imshow(Fish, Map)
% 
% close all

%%

VLength = size(Fish, 1);

HLength = size(Fish, 2);

MidHSlice = FishHA(((ceil(VLength/2) - 5) : (floor(VLength/2) + 5)), (1 : 800));

% imshow(MidHSlice, Map)

%% Range of Background

Background = FishHA((1:Reference), :);

AverageMin = roundn(mean(min(Background)), 2);

AverageMax = roundn(mean(max(Background)), 2);

FishMidline = FishHA(round(VLength/2), :);

Between = (FishMidline <= AverageMax) == (FishMidline >= AverageMin);

%% Counting Fish

Count = 0;

Number = 0;

SplitIndex = [];

Runs = 50;

for n = [1 : (length(Between) - 1)]
    
    if Between(n) == 1
        
        if Between(n) == Between(n + 1)
        
            Count = Count + 1;
            
        end
        
    end
    
    if Count > Runs
        
        Count = 0;
        
        Number =  Number + 1;
        
        SplitIndex(1, (Number)) = n + 2*Runs;
        
    end
    
end

SplitIndex = [0, SplitIndex];

close all
        
%%

Remove = zeros(1, length(SplitIndex));

for n = [2 : length(SplitIndex)]
    
    if SplitIndex(n) - SplitIndex(n - 1) <= 1.2*Runs
        
        Remove(n - 1) = n;
    
    end
    
end

Remove = nonzeros(Remove')';

SplitIndex(Remove) = [];

if length(SplitIndex) <= Amount
    
    SplitIndex = [SplitIndex, HLength];
    
end

%%

figure(1)

imshow(FishHA, Map)

for n = [2 : length(SplitIndex)]
        
    figure(n - 1)
    
    Name = sprintf("%s.%d.dcm", DicomName, (n - 1));
    
    Box = Fish(:, ((1 + SplitIndex(n - 1)) : SplitIndex(n)));

    imshow(Box, Map)
    
    dicomwrite(Box, convertStringsToChars(Name))
    
end