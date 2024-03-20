
function [Est] = Simulation_Configuration(Parameters)

%Configuracion de la transmision 5GNR 

Parameters.fc = 5e9; %Frecuencia de la operadora

%Inicialización y configuración de la Pam_sim.portadora

Parameters.portadora = nrCarrierConfig;
Parameters.portadora.NCellID = 1;
Parameters.portadora.NSizeGrid =52; %Número de EB, por defecto se usa 52 en un espaciado entre subportadoras de 15 kHz a 10MHz de BW.
Parameters.portadora.SubcarrierSpacing = 15; %Se usa de acuerdo a la norma TS 138 211
Parameters.portadora.CyclicPrefix = "normal"; %Para 60kHz se puede usar la extendida



% Definicion de los parametros Pam_sim.pdsch

Parameters.pdsch = nrPDSCHConfig; %Se hace el llamado del objeto para la config del Pam_sim.pdsch.
Parameters.pdsch.PRBSet = 0:Parameters.portadora.NSizeGrid-1; %Localización PRB
Parameters.pdsch.SymbolAllocation = [0,Parameters.portadora.SymbolsPerSlot];
Parameters.pdsch.MappingType = 'A';
Parameters.pdsch.NID = Parameters.portadora.NCellID;
Parameters.pdsch.RNTI = 1;
Parameters.pdsch.VRBToPRBInterleaving = 0;
Parameters.pdsch.NumLayers = 1;
Parameters.pdsch.Modulation=Parameters.Modulation;


% Definicion de parametros DM-RS
Parameters.pdsch.DMRS.DMRSPortSet = 0:Parameters.pdsch.NumLayers-1;
Parameters.pdsch.DMRS.DMRSTypeAPosition = 2;
Parameters.pdsch.DMRS.DMRSLength = 2;
Parameters.pdsch.DMRS.DMRSAdditionalPosition = 1;
Parameters.pdsch.DMRS.DMRSConfigurationType = 1;
Parameters.pdsch.DMRS.NumCDMGroupsWithoutData = 1;
Parameters.pdsch.DMRS.NIDNSCID = 1;
Parameters.pdsch.DMRS.NSCID = 0;


%Definicion de parametros PT-RS

Parameters.pdsch.EnablePTRS = 1;
Parameters.pdsch.PTRS.TimeDensity = 1;
Parameters.pdsch.PTRS.FrequencyDensity = 2;
Parameters.pdsch.PTRS.REOffset = '00';
Parameters.pdsch.PTRS.PTRSPortSet = [];


modulation = string(Parameters.pdsch.Modulation);  % Convert modulation scheme to string type
Puntos = Reference_Points(modulation);


Parameters.constPlot = comm.ConstellationDiagram; % Objeto para el graficado de la constelacion
Parameters.constPlot.ReferenceConstellation = Puntos; % Valores de referencia de la constelacion
Parameters.constPlot.EnableMeasurements = 1; % Activar la medida del EVM


%% Se genera el canal TDL

Parameters.v = Parameters.User_Velocity; %Velocidad del usuario en km/h
Parameters.fc = physconst('lightspeed'); %Velocidad de la luz
%Variación por efecto doppler del U.M :
Parameters.fd = (Parameters.v*1000/3600)/Parameters.fc*Parameters.fc;


Parameters.canal = nrTDLChannel;
Parameters.canal.Seed = 1;
Parameters.canal.DelayProfile = Parameters.Channel; %Definicion del perfil de lcanal
Parameters.canal.DelaySpread = 3e-7;
Parameters.canal.MaximumDopplerShift = Parameters.fd;

Parameters.canal.NumTransmitAntennas = 1;
Parameters.canal.NumReceiveAntennas = 1;


Parameters.info_OFDM= nrOFDMInfo(Parameters.portadora);
Parameters.canal.SampleRate = Parameters.info_OFDM.SampleRate;


Parameters.infoCanal = info(Parameters.canal);
Parameters.maxChDelay = Parameters.infoCanal.MaximumChannelDelay;






%% Elementos que no es necesarios reiniciar en el bucle
%Obtener los indices PDSCH
[Parameters.Indices_Pdsch,Parameters.Informacion_Indices_PDSCH] = nrPDSCHIndices(Parameters.portadora,Parameters.pdsch);


Parameters.Complemento = 0;

if  Parameters.Transmision_IMG
    Parameters.Image = imread(Parameters.Path_IMG);
    Parameters.trData = transpose (reshape((dec2bin(typecast(Parameters.Image(:), 'uint8'), 8) - '0').', 1, []));
    Parameters.slots = ceil(length(Parameters.trData)/(Parameters.Informacion_Indices_PDSCH.G));
    Parameters.Num_Frames = ceil(Parameters.slots/Parameters.portadora.SlotsPerFrame) ;
    Parameters.simbolos_ranura = Parameters.portadora.SymbolsPerSlot; % Simbolos en una ranura

elseif Parameters.Transmision_Bits
    Parameters.trData = randi([0 1],Parameters.Bits_Deseados,1);
    Parameters.slots = ceil(Parameters.Bits_Deseados/(Parameters.Informacion_Indices_PDSCH.G));
    Parameters.Num_Frames = ceil(Parameters.slots/Parameters.portadora.SlotsPerFrame) ;
    Parameters.simbolos_ranura = Parameters.portadora.SymbolsPerSlot; % Simbolos en una ranura
else
    %Cantidad de Slots (Ranuras)
    Parameters.slots = Parameters.portadora.SlotsPerFrame*Parameters.Num_Frames; % Ranuras en la onda
    Parameters.simbolos_ranura = Parameters.portadora.SymbolsPerSlot; % Simbolos en una ranura
end

% Display RMS EVM
Parameters.refSymbols = Reference_Points(string(Parameters.pdsch.Modulation)) ;
Parameters.evm = comm.EVM('ReferenceSignalSource','Estimated from reference constellation','ReferenceConstellation',Parameters.refSymbols);


% Obtener los simbolos e indices DM-RS (Pilotos estimacion de canal)
Parameters.Simbolos_dmrs = nrPDSCHDMRS(Parameters.portadora,Parameters.pdsch);
Parameters.Indices_dmrs = nrPDSCHDMRSIndices(Parameters.portadora,Parameters.pdsch);


% Obtener los simbolos e indices PT-RS (Pilotos estimacion de fase)
Parameters.Simbolos_ptrs = nrPDSCHPTRS(Parameters.portadora,Parameters.pdsch);
Parameters.Indices_ptrs = nrPDSCHPTRSIndices(Parameters.portadora,Parameters.pdsch);

%Se reinicia Cada que termina un valor de Velocidad 
% 
Parameters = Variable_Generation(Parameters,'Time_Grid_','',true); % Crea variable Time_Grid_CNN 
Parameters = Variable_Generation(Parameters,'','_rxbits',true); % Crea variable CNN_rxbits
Parameters = Variable_Generation(Parameters,'Mat_','_BER',true); % Crea variable Mat_CNN_BER 
Parameters = Variable_Generation(Parameters,'Mat_','_MSE',true); % Crea variable Mat_CNN_BER 
Parameters = Variable_Generation(Parameters,'Mat_','_EVM',true); % Crea variable Mat_CNN_BER 
Parameters = Variable_Generation(Parameters,'Mat_','_Time',true); % Crea variable Mat_CNN_BER 

Est = Parameters;
end