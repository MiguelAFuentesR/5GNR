function parametros = Configuracion_Portadora()
% Con esta función se hace la configuración de los parámetros asociados con
% la portadora, el PDSCH y el DM RS

    parametros.Carrier = nrCarrierConfig;         %Se importa el objeto para la portadora
    parametros.Carrier.NSizeGrid = 52;            % Ancho de banda en términos de bloques de recursos (51 RBs para separación subportadora de 15 kHz con 10 MHz)
    parametros.Carrier.SubcarrierSpacing = 15;    % Separación de portadoras en la banda inferior a 6 GHz
    parametros.Carrier.CyclicPrefix = 'Normal';   % Se usa 'extended' al manejar SCS de 60 KHz
    parametros.Carrier.NCellID = 2;               % Identidad de la celda

    % Antenas de transmisión y recepción
    parametros.NTxAnts = 1;                      % #Antenas de PDSCH
    parametros.NRxAnts = 1;                      % #Antenas en la U.M

    % Configuración PDSCH y DM RS
    parametros.PDSCH = nrPDSCHConfig;
    parametros.PDSCH.PRBSet = 0:parametros.Carrier.NSizeGrid-1; % Ubicación de Physical Resource Block
    parametros.PDSCH.SymbolAllocation = [0, parametros.Carrier.SymbolsPerSlot];           % Ubicación de los PDSCH en las ranuras
    parametros.PDSCH.MappingType = 'A';     % Mapeo A: 2-3 símbolo, mapeo B desde cualquier otro símbolo
    parametros.PDSCH.NID = parametros.Carrier.NCellID; % Identificación
    parametros.PDSCH.RNTI = 1;
    parametros.PDSCH.VRBToPRBInterleaving = 0; % Desactivado del mapeo intercalado
    parametros.PDSCH.NumLayers = 1;            % Capas de transmisión de PDSCH
    parametros.PDSCH.Modulation = 'QPSK';   % Lista modulación: 'QPSK', '16QAM', '64QAM', '256QAM'

    % DM-RS configuration
    parametros.PDSCH.DMRS.DMRSPortSet = 0:parametros.PDSCH.NumLayers-1; % Puertos para el DM RS
    parametros.PDSCH.DMRS.DMRSTypeAPosition = 2;      % Se ubica en el tercer simbolo: 0-13, 2 -> [ranura 3]
    parametros.PDSCH.DMRS.DMRSLength = 1;             % Longitud del símbolo DM-RS
    parametros.PDSCH.DMRS.DMRSAdditionalPosition = 1; % Posición adicional 
    parametros.PDSCH.DMRS.DMRSConfigurationType = 2;  % Confoguración de DM-RS, tipo 1 o tipo 2
    parametros.PDSCH.DMRS.NumCDMGroupsWithoutData = 1;% #Grupos CDM sin tener datos
    parametros.PDSCH.DMRS.NIDNSCID = 1;               % No sé muy bien que es
    parametros.PDSCH.DMRS.NSCID = 0;                  % Inicialización de aleatoriedad
end