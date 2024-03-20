function [Est] = Practical_Estimation(Parameters)
%% ----------------- Estimacion de Canal Practica -----------------------
[Parameters.Practical_estChannelGrid,Parameters.Practical_noiseEst] = nrChannelEstimate(Parameters.portadora,Parameters.Grilla_Subframe_rx,Parameters.Indices_dmrs,Parameters.Simbolos_dmrs,'CDMLengths',Parameters.pdsch.DMRS.CDMLengths);

Parameters.Practical_MSE = immse(Parameters.Perfect_estChannelGrid(:), double(Parameters.Practical_estChannelGrid(:)));

[Practical_pdschRx,Practical_pdschHest] = nrExtractResources(Parameters.Indices_Pdsch,Parameters.Grilla_Subframe_rx,Parameters.Practical_estChannelGrid);
[Parameters.Practical_pdschEq,csi] = nrEqualizeMMSE(Practical_pdschRx,Practical_pdschHest,Parameters.Practical_noiseEst);

[Practical_bits_received,Practical_receivedrxSymbols] = nrPDSCHDecode(Parameters.portadora,Parameters.pdsch,Parameters.Practical_pdschEq,Parameters.Practical_noiseEst);
Parameters.Practical_rxbits = [Parameters.Practical_rxbits;Practical_bits_received{1,1}<0]; % Bits decodificados

Est = Parameters;
end