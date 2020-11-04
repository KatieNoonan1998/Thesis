% FishSeperation('I20200309143906.dcm')
% 
% DicomName = 'I20200309145048.dcm';

Info = dicominfo('I20200309143906.dcm');

[FishHA, Map] = dicomread(Info);

figure()

imshow(FishHA, Map)

Amount = input('How many fish in the image:?\n');

%% Removing the hydrox

VerticalSlice = FishHA(:, 10);

figure()

imshow(VerticalSlice, Map)

AverageMinV = sum(min(VerticalSlice))/length(min(VerticalSlice));

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

imshow(Fish)
% 
% close all

%%

VLength = size(Fish, 1);

HLength = size(Fish, 2);

MidHSlice = FishHA(((ceil(VLength/2) - 5) : (floor(VLength/2) + 5)), :);

imshow(MidHSlice, Map)

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