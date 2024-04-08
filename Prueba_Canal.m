%% Inicialización y configuración de la portadora
clear all; clc;

portadora = nrCarrierConfig;
portadora.NCellID = 1;
portadora.NSizeGrid =52; %Número de EB, por defecto se usa 52 en un espaciado entre subportadoras de 15 kHz a 10MHz de BW.
portadora.SubcarrierSpacing = 15; %Se usa de acuerdo a la norma TS 138 211
portadora.CyclicPrefix = "normal"; %Para 60kHz se puede usar la extendida


load("Models/Denoising2.mat"); %Este primer modelo corresponde al generado con MATLAB, haciendo variaciones en los parámetros del canal

%% Se hace la condiguración del PDSCH DM-RS

pdsch = nrPDSCHConfig; %Se hace el llamado del objeto para la config del PDSCH.
pdsch.PRBSet = 0:portadora.NSizeGrid-1; %Localización PRB
pdsch.SymbolAllocation = [0,portadora.SymbolsPerSlot];
pdsch.MappingType = 'A';
pdsch.NID = portadora.NCellID;
pdsch.RNTI = 1;
pdsch.VRBToPRBInterleaving = 0;
pdsch.NumLayers = 1;
pdsch.Modulation="QPSK";


pdsch.DMRS.DMRSPortSet = 0:pdsch.NumLayers-1;
pdsch.DMRS.DMRSTypeAPosition = 2;
pdsch.DMRS.DMRSLength = 1;
pdsch.DMRS.DMRSAdditionalPosition = 1;
pdsch.DMRS.DMRSConfigurationType = 2;
pdsch.DMRS.NumCDMGroupsWithoutData = 1;
pdsch.DMRS.NIDNSCID = 1; 
pdsch.DMRS.NSCID = 0;   


%% Se genera el canal TDL
v = 100; %Velocidad del usuario en km/h
fc = 5e9; %Frecuencia de la operadora
c = physconst('lightspeed'); %Velocidad de la luz
fd = (v*1000/3600)/c*fc; %Variación por efecto doppler del U.M


SNRdB = 3;
canal = nrTDLChannel;
canal.Seed = 1;
canal.DelayProfile = "TDL-A";
canal.DelaySpread = 3e-7;
canal.MaximumDopplerShift = fd;

canal.NumTransmitAntennas = 1;
canal.NumReceiveAntennas = 1;


info_OFDM= nrOFDMInfo(portadora);
canal.SampleRate = info_OFDM.SampleRate;


infoCanal = info(canal);
maxChDelay = infoCanal.MaximumChannelDelay;
%% EN ESTA PARTE DE PRESENTA EL ENVÍO DE UNA SEÑAL

dmrsSimbolos = nrPDSCHDMRS(portadora, pdsch);
dmrsIndices = nrPDSCHDMRSIndices(portadora, pdsch);

recursos = nrResourceGrid(portadora);
recursos(dmrsIndices) = dmrsSimbolos;

senalTX = nrOFDMModulate(portadora, recursos);

senalTX = [senalTX; zeros(maxChDelay, size(senalTX,2))];

[senalRX,pathGains,sampleTimes] = canal(senalTX);


SNR = 10^(SNRdB/10); % Relación señal/ruido lineal
N0 = 1/sqrt(2.0*double(info_OFDM.Nfft)*SNR);
noise = N0*complex(randn(size(senalRX)),randn(size(senalRX)));
rxWaveform = senalRX + noise;
%% 
pathFilters = getPathFilters(canal); 
[offset,~] = nrPerfectTimingEstimate(pathGains,pathFilters);

rxWaveform = rxWaveform(1+offset:end, :);
rxGrid = nrOFDMDemodulate(portadora,rxWaveform);

% Pad the grid with zeros in case an incomplete slot has been demodulated
[K,L,R] = size(rxGrid);
if (L < portadora.SymbolsPerSlot)
    rxGrid = cat(2,rxGrid,zeros(K,portadora.SymbolsPerSlot-L,R));
end


%% Estimación de los canales
estChannelGridPerfect = nrPerfectChannelEstimate(portadora,pathGains,pathFilters,offset,sampleTimes);
interpChannelGrid = hPreprocessInput(rxGrid,dmrsIndices,dmrsSimbolos);


nnInput = cat(4,real(interpChannelGrid),imag(interpChannelGrid));
size(nnInput)
% Use the neural network to estimate the channel
estChannelGridNN = predict(estimacionRNA,nnInput);
% Convert results to complex 
estChannelGridNN = complex(estChannelGridNN(:,:,:,1),estChannelGridNN(:,:,:,2));
%

%%%%PARA LA RED DE TIPO DENOISING %%%%%%%%%%%%%%%%%%%
estChannelGridNN = interpChannelGrid - estChannelGridNN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rx1 = 10*log10(abs(estChannelGridPerfect(:,10,:)));
rx2 = 10*log10(abs(estChannelGridNN(:,10,:)));
rx3 = 10*log10(abs(interpChannelGrid(:,10,:)));

interp_mse = immse(estChannelGridPerfect(:), double(interpChannelGrid(:)));

neural_mse = immse(estChannelGridPerfect(:,:,:), double(estChannelGridNN(:,:,:)));
neural_mape = mape(double(estChannelGridNN(:)), estChannelGridPerfect(:));
neural_rmse = sqrt(neural_mse);

[~, ser] = symerr(senalTX, senalRX);

%% Gráficas con los resultados
figure;
sgtitle(['Comparación de canales con SNR: ' num2str(SNRdB) ' dB'])
subplot(1,3,1)
imagesc(abs(interpChannelGrid));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title({'Lineal Interpolation', ['MSE: ', num2str(interp_mse)]});


subplot(1,3,2)
imagesc(abs(estChannelGridPerfect));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title('Perfecto')

subplot(1,3,3)
imagesc(abs(estChannelGridNN));
xlabel('OFDM Symbol');
ylabel('Subcarrier');
title({'Neural Network', ['MSE: ', num2str(neural_mse)]});

%% Otra grafica

figure;
hold on
plot(rx1, 'Color','red','LineWidth',3);
plot(rx2, 'Color','blue', 'LineStyle','--');
plot(rx3,'Color', 'green');
legend({'Ideal', 'Estimacion RNA', 'Lineal'}, "Location","southeast")
xlabel('Sub-portadora')
ylabel('|H| (dB)')
hold off

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

