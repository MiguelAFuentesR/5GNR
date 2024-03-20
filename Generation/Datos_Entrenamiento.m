%% En este archivo se presenta la generación de los datos de entrenamiento
% Para todas las redes neuronales artificiales que se usen en esta tesis

function [x_train, y_train] = Datos_Entrenamiento(dataSize)

%Esta función genera los datos para entrenamiento de la RNA. El valor de
%dataSize es para hacer el proceso iterativo con la generación de canales 
%aleatorios con diversas variaciones: tipo, doppler shift, delay spread.
%Lo que se hace es generar un sincronización yuna demodulación OFDM para
%recuperar los simbolos piloto y una interpolación lineal por cada
%iteracion, la información del canal exacto es el target de la RNA. Retorna
%datos de entrenamiento y las etiquetas.

    fprintf('Comenzando la generación de datos...\n')

    % Listado de los posibles canales de nrTDLChannel
    delayProfiles = {'TDL-A', 'TDL-B', 'TDL-C', 'TDL-D', 'TDL-E'};

    %Se recuperan las configuraciones de la portadora
    simParameters = Configuracion_Portadora();
    portadora = simParameters.Carrier;
    pdsch = simParameters.PDSCH;

    %Se crea el canal TDLcon el cual se va a hacer el entrenamiento
    nTxAnts = simParameters.NTxAnts;
    nRxAnts = simParameters.NRxAnts;

    canal = nrTDLChannel; %objeto asociado con el canal TDL
    canal.NumTransmitAntennas = nTxAnts;
    canal.NumReceiveAntennas = nRxAnts;

    % Se canfigura la tasa de muestreo con la 
    waveformInfo = nrOFDMInfo(portadora);
    canal.SampleRate = waveformInfo.SampleRate;

    % Se obtiene el retraso máximo en el canal
    chInfo = info(canal);
    maxChDelay = chInfo.MaximumChannelDelay;

    % Se recuperan los indices y simbolos de las señales de referencia
    dmrsSimbolos = nrPDSCHDMRS(portadora,pdsch);
    dmrsIndices = nrPDSCHDMRSIndices(portadora,pdsch);

    % Se crea la cuadrícula de recursos
    grid = nrResourceGrid(portadora,nTxAnts);

    % PDSCH DM-RS precodificación y mapeo
    [~,dmrsAntIndices] = nrExtractResources(dmrsIndices,grid);
    grid(dmrsAntIndices) = dmrsSimbolos;

    % Modulación OFDM de la portadora
    txWaveform_original = nrOFDMModulate(portadora,grid);

    % Se crea un interpolador lineal
    [rows,cols] = find(grid ~= 0);
    dmrsSubs = [rows, cols, ones(size(cols))];
    hest = zeros(size(grid));
    [l_hest,k_hest] = meshgrid(1:size(hest,2),1:size(hest,1));

    % Se genera los datos vacíos que van a ser llenados con cada iteración
    muestras = dataSize;
    [x_train, y_train] = deal(zeros([624 14 2 muestras]));

    % Se genera un ciclo en el cual se hace una variación aleatoria de las
    %configuraciones del canal, variando parámetros. En x_train se guardan
    %los datos propios de la interpolación lineal y en y_train se almacenan
    %las estimaciones perfectas

    for i = 1:muestras
        % Se usa esta sentencia para configurar parámetros en principiono
        % modificables
        canal.release

        % Con cada iteración se tiene un generador aleatorio 
        canal.Seed = randi([1001 2000]);

        % Se toma de manera aleatorio el tipo de canal TDL, el delay spread
        % y el cambio máximo debido al efeto Doppler
        canal.DelayProfile = string(delayProfiles(randi([1 numel(delayProfiles)])));
        canal.DelaySpread = randi([1 300])*1e-9;
        canal.MaximumDopplerShift = randi([1 500]);

        % Se envía la portadora configurada al canal y se usan ceros para
        % completar la información en la forma de onda transitida, con el
        % propósito de reducir las retrasos por multitrayectoria y hacer
        % una
        
        txWaveform = [txWaveform_original; zeros(maxChDelay, size(txWaveform_original,2))];
        [rxWaveform,pathGains,sampleTimes] = canal(txWaveform);

        % Se configura la relación señal a ruido para sumar el ruído a la señal 
        % que es captada en el receptor. 
        SNRdB = randi([0 40]);  % Valores aleatorios entre [0 a 40] dB
        SNR = 10^(SNRdB/10);    % Relación señal a ruido lineal
        N0 = 1/sqrt(2.0*nRxAnts*double(waveformInfo.Nfft)*SNR); %Función AWGN
        noise = N0*complex(randn(size(rxWaveform)),randn(size(rxWaveform)));
        rxWaveform = rxWaveform + noise; %Señal recibida

        % Sincronización perfecta, donde se hace la captura de trayecto con
        % mayor potencia

        pathFilters = getPathFilters(canal); % Se toman encuentra la respuesta al impulso del canal
        [offset,~] = nrPerfectTimingEstimate(pathGains,pathFilters); 

        rxWaveform = rxWaveform(1+offset:end, :); 

        % Se realiza la demodulación OFDM para generar una cuadrícula de
        % recursos aproximada.
        rxGrid = nrOFDMDemodulate(portadora,rxWaveform);
        [K,L,R] = size(rxGrid); %[Subportadoras Simbolos OFDM valor] 
        if (L < portadora.SymbolsPerSlot)
            rxGrid = cat(2,rxGrid,zeros(K,portadora.SymbolsPerSlot-L,R));
        end

        % Se hace la estimación perfecta del canal, el cual no incluye la
        % precodificación del txWaveForm
        estChannelGridPerfect = nrPerfectChannelEstimate(portadora,pathGains, ...
            pathFilters,offset,sampleTimes);

        % Interpolación lineal
        dmrsRx = rxGrid(dmrsIndices);
        dmrsEsts = dmrsRx .* conj(dmrsSimbolos);
        f = scatteredInterpolant(dmrsSubs(:,2),dmrsSubs(:,1),dmrsEsts);
        hest = f(l_hest,k_hest);

        % Se separan los componentes real e imag del canal perfecto y el de
        % la estimación con interpolación lineal
        rx_grid = cat(3, real(hest), imag(hest));
        est_grid = cat(3, real(estChannelGridPerfect), ...
            imag(estChannelGridPerfect));

        % Se añade con cada iteración la interpolación lineal para x_train
        % y la estimación perfecta para el y_train
        x_train(:,:,:,i) = rx_grid;
        y_train(:,:,:,i) = est_grid;

        % Seguidor de la generación de cada muestra para el dataset de
        % entrenamiento
        if mod(i,round(muestras/25)) == 0
            fprintf('%3.2f%% completado\n',i/muestras*100);
        end
    end
    fprintf('Generación de datos de entrenamiento completa!\n')
    save("X_train.mat", "x_train");
    save("Y_train.mat","y_train");
end
