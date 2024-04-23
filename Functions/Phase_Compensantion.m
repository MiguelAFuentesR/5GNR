function [Est] = Phase_Compensantion(Parameters,model)

% Inicializar la rejilla temporal para almacenar los símbolos ecualizados
tempGrid = nrResourceGrid(Parameters.portadora,Parameters.pdsch.NumLayers);

Grid_Estimated = Parameters.(model+"_estChannelGrid");
% Extraer símbolos PT-RS de la rejilla recibida y estimada
[ptrsRx,ptrsHest,~,~,~,ptrsLayerIndices] = nrExtractResources(Parameters.Indices_ptrs,Parameters.Grilla_Subframe_rx,Grid_Estimated,tempGrid);

% Ecualizacion de los símbolos PT-RS y asignarlos a tempGrid
ptrsEq = nrEqualizeMMSE(ptrsRx,ptrsHest,Parameters.noiseEst);
tempGrid(ptrsLayerIndices) = ptrsEq;

% Estimacion del canal residual en las ubicaciones PT-RS en
% tempGrid
cpe = nrChannelEstimate(tempGrid,Parameters.Indices_ptrs,Parameters.Simbolos_ptrs);

% Estimacion del angulo de compensacion
cpe = angle(sum(cpe,[1 3 4]));

%  Asignacion de los símbolos PDSCH ecualizados a tempGrid
tempGrid(Parameters.Indices_Pdsch) = Parameters.(model+"_pdschEq");

% CP en cada símbolo OFDM dentro del rango de referencia
% PT-RS OFDM
if numel(Parameters.Informacion_Indices_PDSCH.PTRSSymbolSet) > 0
    symLoc = Parameters.Informacion_Indices_PDSCH.PTRSSymbolSet(1)+1:Parameters.Informacion_Indices_PDSCH.PTRSSymbolSet(end)+1;
    tempGrid(:,symLoc,:) = tempGrid(:,symLoc,:).*exp(-1i*cpe(symLoc));
end
% Extrae los simbolos
Parameters.(model+"_pdschEq")= tempGrid(Parameters.Indices_Pdsch);

Est = Parameters;
end