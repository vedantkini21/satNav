% Task 7 - ECEF and NED position error

llaEstDegDegM = gpsPvt.allLlaDegDegM; % estimated position from GpsWlsPvt

validPos = isfinite(llaEstDegDegM(:,1)) & ...
    isfinite(llaEstDegDegM(:,2)) & ...
    isfinite(llaEstDegDegM(:,3)); % valid position epochs only

xyzEstM = NaN(size(llaEstDegDegM)); %empty matrix for ECEF positions
xyzEstM(validPos,:) = Lla2Xyz(llaEstDegDegM(validPos,:)); %LLA to ECEF conversion

xyzRefM = mean(xyzEstM(validPos,:),1); % mean ECEF position as reference
llaRefDegDegM = Xyz2Lla(xyzRefM); % reference position in LLA

ecefErrorM = NaN(size(xyzEstM)); %empty matrix for ECEF position error
ecefErrorM(validPos,:) = xyzEstM(validPos,:) - xyzRefM; % ECEF position error

Re2n = RotEcef2Ned(llaRefDegDegM(1),llaRefDegDegM(2)); % ECEF to NED conversion

nedErrorM = NaN(size(ecefErrorM)); %empty matrix for NED position error
nedErrorM(validPos,:) = (Re2n*ecefErrorM(validPos,:)')'; % NED position error

fprintf('\nTask 7 result\n');
fprintf('Number of valid position epochs: %d\n',sum(validPos));

fprintf('Mean LLA as reference: [%.7f deg %.7f deg %.2f m]\n',llaRefDegDegM);

fprintf('Std ECEF error: [%.3f %.3f %.3f] m\n', ...
    std(ecefErrorM(validPos,1)), ...
    std(ecefErrorM(validPos,2)), ...
    std(ecefErrorM(validPos,3)));

fprintf('Std ECEF error: [%.3f %.3f %.3f] m\n', ...
    std(ecefErrorM(validPos,1)), ...
    std(ecefErrorM(validPos,2)), ...
    std(ecefErrorM(validPos,3)));

fprintf('Std NED error: [%.3f %.3f %.3f] m\n', ...
    std(nedErrorM(validPos,1)), ...
    std(nedErrorM(validPos,2)), ...
    std(nedErrorM(validPos,3)));

task7.validPos = validPos;
task7.xyzEstM = xyzEstM;
task7.xyzRefM = xyzRefM;
task7.llaRefDegDegM = llaRefDegDegM;
task7.ecefErrorM = ecefErrorM;
task7.nedErrorM = nedErrorM;

%% Task 8 and 9 - NED position error plots

timeSeconds = gpsPvt.FctSeconds - gpsPvt.FctSeconds(1); % time from first epoch

northErrorM = nedErrorM(:,1); % north position error
eastErrorM = nedErrorM(:,2); % east position error
heightErrorM = -nedErrorM(:,3); % height error from down component

figure;

subplot(2,1,1);
plot(eastErrorM(validPos),northErrorM(validPos),'.b','MarkerSize',8);
grid on;
axis equal;
xlabel('East error (m)');
ylabel('North error (m)');
title('East vs North position error');

subplot(2,1,2);
plot(timeSeconds(validPos),heightErrorM(validPos),'b.-','LineWidth',1.0,'MarkerSize',8);
grid on;
xlabel('Time since first epoch (s)');
ylabel('Height error (m)');
title('Height error with time');

eastSpreadM = max(eastErrorM(validPos)) - min(eastErrorM(validPos));
northSpreadM = max(northErrorM(validPos)) - min(northErrorM(validPos));
heightSpreadM = max(heightErrorM(validPos)) - min(heightErrorM(validPos));

fprintf('\nTask 8 and 9 result\n');
fprintf('East error spread: %.3f m\n',eastSpreadM);
fprintf('North error spread: %.3f m\n',northSpreadM);
fprintf('Height error spread: %.3f m\n',heightSpreadM);

task8.northErrorM = northErrorM(validPos);
task8.eastErrorM = eastErrorM(validPos);
task8.eastSpreadM = eastSpreadM;
task8.northSpreadM = northSpreadM;

task9.timeSeconds = timeSeconds(validPos);
task9.heightErrorM = heightErrorM(validPos);
task9.heightSpreadM = heightSpreadM;


%% Task 10 - NED velocity error plots

velNedMps = gpsPvt.allVelMps; % velocity estimated by GpsWlsPvt in NED

validVel = isfinite(velNedMps(:,1)) & ...
    isfinite(velNedMps(:,2)) & ...
    isfinite(velNedMps(:,3)); % valid velocity epochs only

northVelErrorMps = velNedMps(:,1); % north velocity error
eastVelErrorMps = velNedMps(:,2); % east velocity error
heightVelErrorMps = -velNedMps(:,3); % height velocity error from down velocity

figure;

subplot(2,1,1);
plot(eastVelErrorMps(validVel),northVelErrorMps(validVel),'.b','MarkerSize',8);
grid on;
axis equal;
xlabel('East velocity error (m/s)');
ylabel('North velocity error (m/s)');
title('East vs North velocity error');

subplot(2,1,2);
plot(timeSeconds(validVel),heightVelErrorMps(validVel),'b.-','LineWidth',1.0,'MarkerSize',8);
grid on;
xlabel('Time since first epoch (s)');
ylabel('Height velocity error (m/s)');
title('Height velocity error with time');

eastVelSpreadMps = max(eastVelErrorMps(validVel)) - min(eastVelErrorMps(validVel));
northVelSpreadMps = max(northVelErrorMps(validVel)) - min(northVelErrorMps(validVel));
heightVelSpreadMps = max(heightVelErrorMps(validVel)) - min(heightVelErrorMps(validVel));

fprintf('\nTask 10 result\n');
fprintf('East velocity error spread: %.3f m/s\n',eastVelSpreadMps);
fprintf('North velocity error spread: %.3f m/s\n',northVelSpreadMps);
fprintf('Height velocity error spread: %.3f m/s\n',heightVelSpreadMps);

task10.validVel = validVel;
task10.northVelErrorMps = northVelErrorMps(validVel);
task10.eastVelErrorMps = eastVelErrorMps(validVel);
task10.heightVelErrorMps = heightVelErrorMps(validVel);
task10.eastVelSpreadMps = eastVelSpreadMps;
task10.northVelSpreadMps = northVelSpreadMps;
task10.heightVelSpreadMps = heightVelSpreadMps;
