% Task 4 and 5 - highest elevation GPS satellite pseudorange rate

N = length(gnssMeas.FctSeconds); % no. of epochs
M = length(gnssMeas.Svid); % no. of sats
bcM = gpsPvt.allBcMeters(:);% receiver clock bias
elevDeg = NaN(N,M); %empty matrix generated to store the elevations of satellites

%looping over all epochs
for i = 1:N
    llaDegDegM = gpsPvt.allLlaDegDegM(i,:);
    thisBcM = gpsPvt.allBcMeters(i);
    %getting receiveer position and clock bias at an epoch

    if any(~isfinite(llaDegDegM)) || ~isfinite(thisBcM) %skipping an epoch if invalid, debugging
        continue
    end

    validCols = find(isfinite(gnssMeas.PrM(i,:)) & ...
        isfinite(gnssMeas.tRxSeconds(i,:)));
    if isempty(validCols) % debugging
        continue
    end

    svid = gnssMeas.Svid(validCols)'; % get svid of valid sats
    [gpsEph,ephIndex] = ClosestGpsEph(allGpsEph,svid,gnssMeas.FctSeconds(i)); %getting closest ephemeris for each sat
    if isempty(gpsEph)
        continue %skip if ephemeris not found
    end

    % debugging to keep valid sats only
    cols = validCols(ephIndex);
    numSvs = length(cols);

    %gps week number
    gpsWeek = floor(gnssMeas.FctSeconds(i)/GpsConstants.WEEKSEC);

    %transmit time
    ttxSeconds = gnssMeas.tRxSeconds(i,cols)' - ...
        gnssMeas.PrM(i,cols)'/GpsConstants.LIGHTSPEED;
    dtsvS = GpsEph2Dtsv(gpsEph,ttxSeconds); %satellite clock correction
    dtsvS = dtsvS(:);

    % corrected GPS time input
    gpsTime = [ones(numSvs,1)*gpsWeek,ttxSeconds - dtsvS];
    [svXyzM,dtsvS] = GpsEph2Pvt(gpsEph,gpsTime);
    if isempty(svXyzM)
        continue
    end

    rxXyzM = Lla2Xyz(llaDegDegM); %ECEF xyz of receiver
    Re2n = RotEcef2Ned(llaDegDegM(1),llaDegDegM(2)); %ECEF to NED conversion

    for k = 1:numSvs %looping over satellites
        dtFlightS = (gnssMeas.PrM(i,cols(k)) - thisBcM)/ ... %signal travel time with clock bias and sat clock correction
            GpsConstants.LIGHTSPEED + dtsvS(k);
        svXyzTrxM = FlightTimeCorrection(svXyzM(k,:),dtFlightS); %correct sat position for earth rotation during signal travel

        losNedM = Re2n*(svXyzTrxM - rxXyzM)'; % line of sight in NED frame
        horizM = sqrt(losNedM(1)^2 + losNedM(2)^2); %horizontal component
        elevDeg(i,cols(k)) = atan2(-losNedM(3),horizM)*180/pi; %elevation angle
    end
end

medianElevDeg = NaN(1,M); %median elevation
maxElevDeg = NaN(1,M); %max elevation
pairCount = zeros(1,M); % valid time pairs
firstIndex = cell(1,M);
secondIndex = cell(1,M);

%calculation of mean and max
for j = 1:M
    elevJ = elevDeg(:,j);
    elevJ = elevJ(isfinite(elevJ));
    if ~isempty(elevJ)
        medianElevDeg(j) = median(elevJ);
        maxElevDeg(j) = max(elevJ);
    end

    i0 = (1:N-1)';
    i1 = (2:N)';
    dtS = gnssMeas.FctSeconds(i1) - gnssMeas.FctSeconds(i0);
    prM = gnssMeas.PrM(:,j); % taking pseudorange from gnssMeas function

    ok = isfinite(prM(i0)) & isfinite(prM(i1)) & ...
        isfinite(bcM(i0)) & isfinite(bcM(i1)) & ...
        isfinite(dtS) & dtS > 0;

    firstIndex{j} = i0(ok);
    secondIndex{j} = i1(ok);
    pairCount(j) = sum(ok);
end

validSat = isfinite(medianElevDeg) & pairCount > 0;
validCols = find(validSat);

[~,bestLocalIndex] = max(medianElevDeg(validCols));
bestCol = validCols(bestLocalIndex);
bestSvid = gnssMeas.Svid(bestCol);

i0 = firstIndex{bestCol};
i1 = secondIndex{bestCol};

dtS = gnssMeas.FctSeconds(i1) - gnssMeas.FctSeconds(i0);
prM = gnssMeas.PrM(:,bestCol);

prrFromDiffMps = (prM(i1) - prM(i0))./dtS;
rxClockDriftMps = (bcM(i1) - bcM(i0))./dtS;
prrCorrectedMps = prrFromDiffMps - rxClockDriftMps;

tPlotS = gnssMeas.FctSeconds(i1) - gnssMeas.FctSeconds(1);

% Task 5 - phone measured pseudorange rate for same satellite
phonePrrMps = gnssMeas.PrrMps(:,bestCol); % taking pseudorange rate measured by phone
phonePrrPairMps = phonePrrMps(i1); % matching it with same time epochs as task 4

phoneClockDriftMps = gpsPvt.allBcDotMps(i1); % receiver clock drift from GpsWlsPvt
phonePrrCorrectedMps = phonePrrPairMps - phoneClockDriftMps; %removing receiver clock drift

validPhonePrr = isfinite(phonePrrCorrectedMps); % valid phone pseudorange rate values only

%% Plots %%
figure;
plot(tPlotS,prrCorrectedMps,'b.-','LineWidth',1.0,'MarkerSize',8);
hold on;
plot(tPlotS(validPhonePrr),phonePrrCorrectedMps(validPhonePrr), ...
    'm.-','LineWidth',1.0,'MarkerSize',8);
hold off;
grid on;
xlabel('Time since first epoch (s)');
ylabel('Corrected pseudorange rate (m/s)');
title(sprintf('Task 4 and 5: GPS SVID %d, median elevation %.1f deg', ...
    bestSvid,medianElevDeg(bestCol)));
legend('From pseudorange difference','Phone pseudorange-rate measurement', ...
    'Location','best');

fprintf('Highest-elevation GPS satellite: SVID %d\n',bestSvid);
fprintf('Median elevation: %.2f deg\n',medianElevDeg(bestCol));
fprintf('Maximum elevation: %.2f deg\n',maxElevDeg(bestCol));
fprintf('Number of pseudorange-rate points: %d\n',length(prrCorrectedMps));
fprintf('Number of phone pseudorange-rate points: %d\n',sum(validPhonePrr));

task4.svid = bestSvid;
task4.svidColumn = bestCol;
task4.timeSeconds = tPlotS;
task4.elevationDeg = elevDeg(:,bestCol);
task4.medianElevationDeg = medianElevDeg(bestCol);
task4.maxElevationDeg = maxElevDeg(bestCol);
task4.pseudorangeRateFromDiffMps = prrFromDiffMps;
task4.receiverClockDriftMps = rxClockDriftMps;
task4.correctedPseudorangeRateMps = prrCorrectedMps;

task5.svid = bestSvid;
task5.svidColumn = bestCol;
task5.timeSeconds = tPlotS(validPhonePrr);
task5.phonePseudorangeRateMps = phonePrrPairMps(validPhonePrr);
task5.receiverClockDriftMps = phoneClockDriftMps(validPhonePrr);
task5.correctedPhonePseudorangeRateMps = phonePrrCorrectedMps(validPhonePrr);
