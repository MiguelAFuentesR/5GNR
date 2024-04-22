function [Est] = Lineal_Estimation(Parameters)
%% ----------------- Estimacion de Canal Lineal -----------------------
Parameters.interpChannelGrid = hPreprocessInput(Parameters.Grilla_Subframe_rx,Parameters.Indices_dmrs,Parameters.Simbolos_dmrs);
Parameters.Lineal_estChannelGrid = Parameters.interpChannelGrid;
%Obtener una estimación perfecta del ruido (a partir de la realización del ruido)
Parameters.noiseGrid = nrOFDMDemodulate(Parameters.portadora,Parameters.noise(1+Parameters.offset:end ,:));
Parameters.noiseEst = var(Parameters.noiseGrid(:));

[Parameters.Lineal_pdschRx,Lineal_pdschHes] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.interpChannelGrid);
[Parameters.Lineal_pdschEq,Lineal_csi] = nrEqualizeMMSE(Parameters.Lineal_pdschRx,Lineal_pdschHes,Parameters.noiseEst);

[Lineal_bits_received,Lineal_rxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Lineal_pdschEq,Parameters.noiseEst);
Parameters.Lineal_rxbits = [Parameters.Lineal_rxbits;Lineal_bits_received{1,1}<0]; % Bits decodificados



Est = Parameters;
end