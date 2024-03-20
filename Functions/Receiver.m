function [Est] = Receiver(Parameters)


Parameters.txWaveform = [Parameters.txWaveform; zeros(Parameters.maxChDelay,size(Parameters.txWaveform,2))];
[Parameters.rxWaveform,Parameters.pathGains,Parameters.sampleTimes] = Parameters.canal(Parameters.txWaveform);

%Adicion AWGN
Parameters.N0 = 1/sqrt(2.0*Parameters.canal.NumReceiveAntennas*double(Parameters.info_OFDM.Nfft)*Parameters.SNR_Lineal);
Parameters.noise = Parameters.N0*complex(randn(size(Parameters.txWaveform)),randn(size(Parameters.txWaveform)));

Parameters.rxWaveform = Parameters.rxWaveform +Parameters.noise;
% Sincronizacion de tiempo
Parameters.pathFilters = getPathFilters(Parameters.canal);
[Parameters.offset,mag] = nrPerfectTimingEstimate(Parameters.pathGains,Parameters.pathFilters);

Parameters.rxWaveform = Parameters.rxWaveform(1+Parameters.offset:end,:);


%% ------------  Demodulacion OFDM ----------------------------
Parameters.Grilla_Subframe_rx = nrOFDMDemodulate(Parameters.portadora,Parameters.rxWaveform);
% Completar grilla con ceros en caso de que se demodule de forma
% incompleta

[K,L,R] = size(Parameters.Grilla_Subframe_rx);
if (L < Parameters.portadora.SymbolsPerSlot)
    Parameters.Grilla_Subframe_rx = cat(2,Parameters.Grilla_Subframe_rx,zeros(K,Parameters.portadora.SymbolsPerSlot-L,R));
end
Est = Parameters;
end