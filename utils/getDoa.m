for m = 1:numpulse
    % Update sensor, target and calculate target angle as seen by the sensor
    [sensorpos,sensorvel] = sensormotion(1/prf);
    [tgtpos,tgtvel] = tgtmotion(1/prf);
    [~,tgtang] = rangeangle(tgtpos,sensorpos);
    % Simulate propagation of pulse in direction of targets
    pulse = waveform();
    [pulse,txstatus] = transmitter(pulse);
    pulse = radiator(pulse,tgtang);
    pulse = tgtchannel(pulse,sensorpos,tgtpos,sensorvel,tgtvel);

    % Collect target returns at sensor
    pulse = target(pulse);
    tsig(:,:,m) = collector(pulse,tgtang);                       % Target + clutter
    tsig(:,:,m) = receiver(tsig(:,:,m),...
        ~(txstatus>0));                         % Target echo only
end
DoaCube = tsig(tgtCellIdx, :, :);
Doasig = reshape(DoaCube,M*N, 1);
Doasig = Doasig/norm(Doasig);
Doavec = 1e-1*reshape(tsig, rngnum, M*numpulse);