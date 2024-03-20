%% Inicialización y configuración de la portadora
clear all; clc; close all;

portadora = nrCarrierConfig;
portadora.NCellID = 1;
portadora.NSizeGrid =52; %Número de EB, por defecto se usa 52 en un espaciado entre subportadoras de 15 kHz a 10MHz de BW.
portadora.SubcarrierSpacing = 15; %Se usa de acuerdo a la norma TS 138 211
portadora.CyclicPrefix = "normal"; %Para 60kHz se puede usar la extendida




%% Se hace la configuración del PDSCH DM-RS

pdsch = nrPDSCHConfig; %Se hace el llamado del objeto para la config del PDSCH.
pdsch.PRBSet = 0:portadora.NSizeGrid-1; %Localización PRB
pdsch.SymbolAllocation = [0,portadora.SymbolsPerSlot];
pdsch.MappingType = 'A';
pdsch.NID = portadora.NCellID;
pdsch.RNTI = 1;
pdsch.VRBToPRBInterleaving = 0;
pdsch.NumLayers = 1;
pdsch.Modulation="16QAM";


pdsch.DMRS.DMRSPortSet = 0:pdsch.NumLayers-1;
pdsch.DMRS.DMRSTypeAPosition = 2;
pdsch.DMRS.DMRSLength = 1;
pdsch.DMRS.DMRSAdditionalPosition = 1;
pdsch.DMRS.DMRSConfigurationType = 2;
pdsch.DMRS.NumCDMGroupsWithoutData = 1;
pdsch.DMRS.NIDNSCID = 1;
pdsch.DMRS.NSCID = 0;

constPlot = comm.ConstellationDiagram; % Constellation diagram object
constPlot.ReferenceConstellation = getConstellationRefPoints(pdsch.Modulation); % Reference constellation values
constPlot.EnableMeasurements = 1; % Enable EVM measurements



%% Se genera el canal TDL
v = 5; %Velocidad del usuario en km/h
fc = 5e9; %Frecuencia de la operadora
c = physconst('lightspeed'); %Velocidad de la luz
fd = (v*1000/3600)/c*fc; %Variación por efecto doppler del U.M



canal = nrTDLChannel;
canal.Seed = 1;
canal.DelayProfile = "TDL-E";
canal.DelaySpread = 3e-7;
canal.MaximumDopplerShift = fd;

canal.NumTransmitAntennas = 1;
canal.NumReceiveAntennas = 1;


info_OFDM= nrOFDMInfo(portadora);
canal.SampleRate = info_OFDM.SampleRate;


infoCanal = info(canal);
maxChDelay = infoCanal.MaximumChannelDelay;
%% Definicion del Canal

dmrsSimbolos = nrPDSCHDMRS(portadora, pdsch); % Simbolos pilotos
dmrsIndices= nrPDSCHDMRSIndices(portadora, pdsch); % Posiciones para insercion de pilotos
[ind_data,info_channel] = nrPDSCHIndices(portadora,pdsch); % Posiciones disponibles para insercion de datos

%Generar Bits utiles de transmision

tStart = tic; 

num_cw = pdsch.NumCodewords;
data = cell(1,num_cw);
txbits = [];

for k=1:num_cw
    data{k} = randi([0 1],info_channel.G(k),1);
    txbits = [txbits; data{k}];
end

%Modulacion de los datos
simbolos_datos = nrPDSCH(portadora, pdsch,data); % Simbolos datos

% Asignacion de recursos
recursos = nrResourceGrid(portadora); % Creacion de la grilla de recursos 624*14
recursos(dmrsIndices) = dmrsSimbolos; % Insercion de simbolos pilotos
recursos(ind_data) = simbolos_datos;% Insercion de datos

senalTX = nrOFDMModulate(portadora, recursos);

senalTX_orig = senalTX;

senalTX = [senalTX; zeros(maxChDelay, size(senalTX,2))];

[senalRX,pathGains,sampleTimes] = canal(senalTX);

EbN0_dB = 0:1:30;  % SNR en dB
modelos = 1;
mat_BER = [];

for model=1:1:modelos+2
    if model <= modelos
        load("CNN_Modelo"+model+".mat"); %Este primer modelo corresponde al generado con MATLAB, haciendo variaciones en los parámetros del canal
        disp("Se ha cargado el modelo "+model)
    elseif model == modelos+1
        disp("Se realizara la estimacion perfecta ")
    elseif model == modelos+2
        disp("Se realizara la estimacion Lineal")
    end
    
    BER = [];
    rmse = [];
    mse = [];

    for l=1:length(EbN0_dB)
        SNR = 10^(EbN0_dB(l)/10); % Relación señal/ruido lineal
        N0 = 1/sqrt(2.0*double(info_OFDM.Nfft)*SNR);
        noise = N0*complex(randn(size(senalRX)),randn(size(senalRX)));
        rxWaveform = senalRX + noise;

        %Timing Synchronization
        pathFilters = getPathFilters(canal);
        [offset,~] = nrPerfectTimingEstimate(pathGains,pathFilters);

        rxWaveform = rxWaveform(1+offset:end, :);
        rxGrid = nrOFDMDemodulate(portadora,rxWaveform); % OFDM-demodulate the synchronized signal.

        % Pad the grid with zeros in case an incomplete slot has been demodulated
        [K,L,R] = size(rxGrid);
        if (L < portadora.SymbolsPerSlot)
            rxGrid = cat(2,rxGrid,zeros(K,portadora.SymbolsPerSlot-L,R));
        end

        %% Estimación de los canales

        estChannelGridPerfect = nrPerfectChannelEstimate(portadora,pathGains,pathFilters,offset,sampleTimes);
        interpChannelGrid = hPreprocessInput(rxGrid,dmrsIndices,dmrsSimbolos);

        % Get perfect noise estimate (from noise realization)
        noiseGrid = nrOFDMDemodulate(portadora,noise(1+offset:end ,:));
        noiseEst = var(noiseGrid(:));

        nnInput = cat(4,real(interpChannelGrid),imag(interpChannelGrid));
        size(nnInput);
        % Use the neural network to estimate the channel
        estChannelGridNN = predict(estimacionRNA,nnInput);
        % Convert results to complex
        estChannelGridNN = complex(estChannelGridNN(:,:,:,1),estChannelGridNN(:,:,:,2));

        rx1 = 10*log10(abs(estChannelGridPerfect(:,3,:)));
        rx2 = 10*log10(abs(estChannelGridNN(:,3,:)));
        rx3 = 10*log10(abs(interpChannelGrid(:,3,:)));

        interp_mse = immse(estChannelGridPerfect(:), double(interpChannelGrid(:)));


        neural_mse = immse(estChannelGridPerfect(:,:,:), double(estChannelGridNN(:,:,:)));
        neural_mape = mape(double(estChannelGridNN(:)), estChannelGridPerfect(:));
        neural_rmse = sqrt(neural_mse);
        rmse = [rmse neural_rmse];
        mse= [mse neural_mse];


        %% Ecualizacion
        if(model==modelos+1)
                        %Se agrega el procesamiento con estimacion lineal
            %Con estimacion Lineal
            [pdschRx,pdschHest] = nrExtractResources(dmrsIndices,rxGrid,interpChannelGrid); % Cambiar la estimacion de canal
            [pdschRx_data,pdschHes_data] = nrExtractResources(ind_data,rxGrid,interpChannelGrid); % Cambiar la estimacion de canal

        elseif model == modelos+2

            %Ya se terminaron los modelos con redes nueronales, se agregara
            %el procesamiento con estimacion Ideal
            %Estimacion perfecta
            [pdschRx,pdschHest] = nrExtractResources(dmrsIndices,rxGrid,estChannelGridPerfect); % Cambiar la estimacion de canal
            [pdschRx_data,pdschHes_data] = nrExtractResources(ind_data,rxGrid,estChannelGridPerfect); % Cambiar la estimacion de canal

        else
            %Con estimacion CNN
            [pdschRx,pdschHest] = nrExtractResources(dmrsIndices,rxGrid,estChannelGridNN); % Cambiar la estimacion de canal
            [pdschRx_data,pdschHes_data] = nrExtractResources(ind_data,rxGrid,estChannelGridNN); % Cambiar la estimacion de canal

        end



        %Proceso de equalizacion
        [pdschEq,csi] = nrEqualizeMMSE(pdschRx,pdschHest,noiseEst); % Revisar estimacion de ruido a partir de la CNN
        [pdschEq_data,csi_data] = nrEqualizeMMSE(pdschRx_data,pdschHes_data,noiseEst); % Revisar estimacion de ruido a partir de la CNN

        %constPlot(fliplr(pdschEq));
        constPlot(fliplr(pdschEq_data));


        % %% Compensacion de Fase
        % 
        % %Crear grilla de recursos auxiliar
        % ProGrid = nrResourceGrid(portadora);
        % ProGrid(dmrsIndices) =pdschEq;
        % ProGrid(ind_data) =pdschEq_data;
        % 
        % compesacion = nrChannelEstimate(portadora,rxGrid,pdschRx);
        % compesacion_data = nrChannelEstimate(portadora,rxGrid,pdschRx_data,noiseEst);
        % phase = angle(sum(compesacion_data,[1 3 4 ]));
        % 
        % Progrid = rxGrid.*exp(-1i*phase)

        % Decodificacion del canal PDSCH
        [rxbits,rxSymbols] = nrPDSCHDecode(portadora,pdsch,pdschEq,noiseEst);
        [rxbits_data,rxSymbols_data] = nrPDSCHDecode(portadora,pdsch,pdschEq_data,noiseEst);

        bits_received = rxbits_data{1,1}<0; % Bits decodificados
        
        N_Wb = NbWrongbit(txbits,bits_received) % Numero de bits erroneos

        if N_Wb ==0 
            N_Wb =1;
        end
        ber = N_Wb/length(txbits)
        BER = [BER ber];
        tEnd = toc(tStart)
        constPlot(fliplr(rxSymbols_data{1,1}));
    end
    mat_BER =[mat_BER;BER];
end

save('BER.mat', "mat_BER");






% save('RMSE.mat', "mat_rmse");
% save('MSE.mat', "mat_mse");
% Gráficas con los resultados
% figure;
% sgtitle(['Comparación de canales con SNR: ' num2str(SNRdB) ' dB'])
% subplot(1,3,1)
% imagesc(abs(interpChannelGrid));
% xlabel('OFDM Symbol');
% ylabel('Subcarrier');
% title({'Lineal Interpolation', ['MSE: ', num2str(interp_mse)]});
%
%
% subplot(1,3,2)
% imagesc(abs(estChannelGridPerfect));
% xlabel('OFDM Symbol');
% ylabel('Subcarrier');
% title('Perfecto')
%
% subplot(1,3,3)
% imagesc(abs(estChannelGridNN));
% xlabel('OFDM Symbol');
% ylabel('Subcarrier');
% title({'Neural Network', ['MSE: ', num2str(neural_mse)]});

%% Otra grafica

% figure;
% hold on
% plot(rx1, 'Color','red','LineWidth',3);
% plot(rx2, 'Color','blue', 'LineStyle','--');
% plot(rx3,'Color', 'green');
% legend({'Ideal', 'Estimacion RNA', 'Lineal'}, "Location","southeast")
% xlabel('Sub-portadora')
% ylabel('|H| (dB)')
% hold off
%

%% Procesado lineal
function hest = hPreprocessInput(rxGrid,dmrsIndices,dmrsSymbols)
% Perform linear interpolation of the grid and input the result to the
% neural network This helper function extracts the DM-RS symbols from
% dmrsIndices locations in the received grid rxGrid and performs linear
% interpolation on the extracted pilots.

% Obtain pilot symbol estimates
dmrsRx = rxGrid(dmrsIndices);
dmrsEsts = dmrsRx .* conj(dmrsSymbols);

% Create empty grids to fill after linear interpolation
[rxDMRSGrid, hest] = deal(zeros(size(rxGrid)));
rxDMRSGrid(dmrsIndices) = dmrsSymbols;

% Find the row and column coordinates for a given DMRS configuration
[rows,cols] = find(rxDMRSGrid ~= 0);
dmrsSubs = [rows,cols,ones(size(cols))];
[l_hest,k_hest] = meshgrid(1:size(hest,2),1:size(hest,1));

% Perform linear interpolation
f = scatteredInterpolant(dmrsSubs(:,2),dmrsSubs(:,1),dmrsEsts, 'natural','nearest');
hest = f(l_hest,k_hest);

end
function refPoints = getConstellationRefPoints(mod)
% Calula los puntos de la constelacion de referencia en el esquema de
% modulacion
switch mod
    case "QPSK"
        nPts = 4;
    case "16QAM"
        nPts = 16;
    case "64QAM"
        nPts = 64;
    case "256QAM"
        nPts = 256;
end
binaryValues = int2bit(0:nPts-1,log2(nPts));
refPoints = nrSymbolModulate(binaryValues(:),mod);
end

function [n_ws]=NbWrongbit(d,dl)
n_ws=0;
for i=1:length(d)
    if d(i)~=dl(i)
        n_ws=n_ws+1;
    end
end

end

