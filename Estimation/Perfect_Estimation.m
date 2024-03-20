function [Est] = Perfect_Estimation(Parameters)
%% ----------------- Estimacion de Canal Perfecta -----------------------
Parameters.Perfect_estChannelGrid = nrPerfectChannelEstimate(Parameters.portadora,Parameters.pathGains,Parameters.pathFilters,Parameters.offset,Parameters.sampleTimes);
Parameters.Lineal_MSE= [Parameters.Lineal_MSE immse(Parameters.Perfect_estChannelGrid(:), double(Parameters.interpChannelGrid(:)))];


[Parameters.Perfect_pdschRx,Perfect_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.Perfect_estChannelGrid);
[Parameters.Perfect_pdschEq,Perfect_csi] = nrEqualizeMMSE(Parameters.Perfect_pdschRx,Perfect_pdschHes,Parameters.noiseEst);

[Perfect_bits_received,Perfect_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Perfect_pdschEq,Parameters.noiseEst);
Parameters.Perfect_rxbits = [Parameters.Perfect_rxbits;Perfect_bits_received{1,1}<0]; % Bits decodificados
Est = Parameters;
end