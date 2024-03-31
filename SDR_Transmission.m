format shortEng
format compact
close all

path_x = pwd ;
addpath([path_x,'/Estimation/']);
addpath([path_x,'/Functions/']);
addpath([path_x,'/Generation/']);
addpath([path_x,'/Graph_Functions/']);
addpath([path_x,'/Models/']);
addpath([path_x,'/Outputs/']);
addpath([path_x,'/App/']);

rng(45)

app = [];
app.Pam_sim = [];% Parametros de la simulacion
app.Pam_sim.Modulation = "64QAM";
app.Pam_sim.Channel = "TDL-D";
app.Pam_sim.SNR = 10;
app.Pam_sim.User_Velocity = 10;


%% --------------- Estimation Config
app.Pam_sim.CNNmodel_1 = 1;
app.Pam_sim.CNNmodel_2 = 5;
app.Pam_sim.CNNEstimation = true;
app.Pam_sim.CNNEstimation_2 = false;
app.Pam_sim.Autoencoder_Estimation = false;
app.Pam_sim.EstimacionPractica = true;
app.Pam_sim.Denoising_Estimation = false;
app.Pam_sim.Denoising_Estimation_resta = false;


app.Pam_sim.Compensacion_Fase = false;% Realizar compensacion de fase con pilotos PT-RS para CNN
app.Pam_sim.Save_Variables  = true;

%% ------------- Data config

app.Pam_sim.Transmision_IMG = false; % Envio de una imagen
app.Pam_sim.Transmision_Bits = false;
app.Pam_sim.Bits_Deseados = 1200000;
app.Pam_sim.Num_Frames = 3; %Numero de frames deseados a enviar
app.Pam_sim.Path_IMG = '/media/miguel/Universidad/Tesis/Codigos_Finales/Chacon.png';

%%
app.Pam_sim.models = {'Lineal','Perfect'};

if app.Pam_sim.CNNEstimation
    app.Pam_sim.models = [app.Pam_sim.models 'CNN'];
    app.Pam_sim.estimacionRNA_1 = load("CNN_Modelo"+app.Pam_sim.CNNmodel_1+".mat").estimacionRNA;
end
if app.Pam_sim.CNNEstimation_2
    app.Pam_sim.models = [app.Pam_sim.models 'CNN_2'];
    app.Pam_sim.estimacionRNA_2 = load("CNN_Modelo"+app.Pam_sim.CNNmodel_2+".mat").estimacionRNA;

end
if app.Pam_sim.Autoencoder_Estimation
    app.Pam_sim.estimacionRNA_Autoencoder = load("Autoencoder.mat").estimacionRNA;
    app.Pam_sim.models = [app.Pam_sim.models 'Autoencoder'];
end
if app.Pam_sim.EstimacionPractica
    app.Pam_sim.models = [app.Pam_sim.models 'Practical'];
end
if app.Pam_sim.Denoising_Estimation
    if app.Pam_sim.Denoising_Estimation_resta
        app.Pam_sim.estimacionRNA_Denoising= load("Denoising2.mat").estimacionRNA;
    else
        app.Pam_sim.estimacionRNA_Denoising= load("Denoising.mat").estimacionRNA;
    end
    app.Pam_sim.models = [app.Pam_sim.models 'Denoising'];
end


%% Ciclo de Procesamiento (Simulacion transmision en el tiempo )



app.Pam_sim.SNR_Recorridas =[];

%Inicialización y configuración de la portadora, Modulacion y canal
% Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion

app.Pam_sim =Variables_initialization(app.Pam_sim,app.Pam_sim.SNR);
app.Pam_sim.SNR_Recorridas = [app.Pam_sim.SNR_Recorridas app.Pam_sim.SNR];

switch app.Pam_sim.pdsch.Modulation
    case "QPSK"
        bits_symbol = 2;
    case "16QAM"
        bits_symbol = 4;
    case "64QAM"
        bits_symbol = 6;
    case "256QAM"
        bits_symbol = 8;
end
symbols_ofdm_slot = 624*14;
symbols_info_ofdm_slot = length(app.Pam_sim.Indices_Pdsch); 
symbols_info_ofdm_FRAME = 10*symbols_info_ofdm_slot;

bits_per_slot = symbols_ofdm_slot * bits_symbol;
bits_info_per_slot = symbols_info_ofdm_slot*bits_symbol;

bits_info_per_FRAME = 10*bits_info_per_slot;


% UN SLOT CADA 1 ms 
Total_Transmision_seg = bits_per_slot/1e-3;
Total_Transmision_seg_Frame = bits_info_per_FRAME/10e-3
Total_Transmision_info_seg = bits_info_per_slot/1e-3;
app.Pam_sim.real_throughput_FRAME = [];
Frames_transmitted = 0;

for Indice_Ranura = 1:app.Pam_sim.slots 

    disp(['Slot ',num2str(Indice_Ranura),' Enviado'])
    app.Pam_sim.Indice_Ranura = Indice_Ranura;
    %% ------------ Transmisor  ----------------------------
    tStart_trans = tic;
    app.Pam_sim = Transmitter(app.Pam_sim);
    app.Pam_sim.tEnd_trans = toc(tStart_trans);
    %% ------------ Receptor (AWGN - CANAL TDL) ---------------------------
    tStart_recep = tic;
    app.Pam_sim = Receiver(app.Pam_sim);
    app.Pam_sim.tEnd_recep = toc(tStart_recep);
    %% ------------  Estimacion de Canal Lineal ---------------------------
    tStart_Lineal = tic;
    app.Pam_sim = Lineal_Estimation(app.Pam_sim);
    app.Pam_sim.tEnd_Lineal = toc(tStart_Lineal);
    %% ----------------- Estimacion de Canal Perfecta ---------------------
    tStart_Perfect = tic;
    app.Pam_sim = Perfect_Estimation(app.Pam_sim);
    app.Pam_sim.tEnd_Perfect = toc(tStart_Perfect);
    %% ----------------- Estimacion de Canal con CNN ---------------------
    if app.Pam_sim.CNNEstimation
        if app.Pam_sim.CNNEstimation_2
            tStart_CNN = tic;
            app.Pam_sim = CNN_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_1);
            app.Pam_sim.tEnd_CNN = toc(tStart_CNN);
            app.Pam_sim.CNN_pdschEq_sin = app.Pam_sim.CNN_pdschEq ;

            tStart_CNN_2 = tic;
            app.Pam_sim = CNN_2_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_2);
            app.Pam_sim.tEnd_CNN_2 = toc(tStart_CNN_2);
            app.Pam_sim.CNN_2_pdschEq_sin = app.Pam_sim.CNN_2_pdschEq ;
        else
            tStart_CNN = tic;
            app.Pam_sim = CNN_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_1);
            app.Pam_sim.tEnd_CNN = toc(tStart_CNN);
            app.Pam_sim.CNN_pdschEq_sin = app.Pam_sim.CNN_pdschEq ;
        end
    end
    %% ----------------- Estimacion de Canal con AUTOENCODER --------------
    if app.Pam_sim.Autoencoder_Estimation
        tStart_Autoencoder= tic;
        app.Pam_sim = Autoencoder_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_Autoencoder);
        app.Pam_sim.tEnd_Autoencoder = toc(tStart_Autoencoder);
    end
    %% ----------------- Estimacion de Canal con Red Denoising --------------
    if app.Pam_sim.Denoising_Estimation
        tStart_Denoising= tic;
        load("Denoising.mat");
        app.Pam_sim = Denoising_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_Denoising);
        app.Pam_sim.tEnd_Denoising= toc(tStart_Denoising);
    end
    %% ----------------- Estimacion de Canal Practica ---------------------
    if app.Pam_sim.EstimacionPractica
        tStart_Practical = tic;
        app.Pam_sim = Practical_Estimation(app.Pam_sim);
        app.Pam_sim.tEnd_Practical = toc(tStart_Practical);
    end
    app.Pam_sim.Practical_pdschEq_sin = app.Pam_sim.Practical_pdschEq;
    %% ----------------- Compensacion de fase de los Simbolos ----------------
    if app.Pam_sim.Compensacion_Fase
        app.Pam_sim  = Phase_Compensantion(app.Pam_sim,app.Pam_sim.Practical_estChannelGrid);
    end
    %disp(['Slot ',num2str(Indice_Ranura),' Procesado'])
    app.Pam_sim = Metricas_Slot(app.Pam_sim);
    if Indice_Ranura>0 
        if mod(Indice_Ranura,10) == 0
            Bits_slot_tx =  app.Pam_sim.txbits(end-length(app.Pam_sim.Indices_Pdsch)+1:end);
            Bits_slot_rx = app.Pam_sim.Lineal_rxbits(end-length(app.Pam_sim.Indices_Pdsch)+1:end);
            [Ber_frame,app.Pam_sim ] = Ber_Estimation(Bits_slot_tx,Bits_slot_rx,app.Pam_sim);
            %[Ber_slot,app.Pam_sim ] = Ber_Estimation(Bits_slot_tx,Bits_slot_rx,app.Pam_sim);
            Frames_transmitted = Frames_transmitted+1;
            Bits_Utils_FRAME = bits_info_per_FRAME-app.Pam_sim.Wrong_Bits; % Bits transmitidos por frame
            real_throughput_FRAME = Bits_Utils_FRAME/10e3; 
            app.Pam_sim.real_throughput_FRAME = [app.Pam_sim.real_throughput_FRAME real_throughput_FRAME];
        end
    end

   
end




app.Pam_sim = Matrix_metricas(app.Pam_sim); % Metricas por dB




Constelaciones(app.Pam_sim);
%Waterfall_Estimation_Time(app.Pam_sim,Indice_Ranura,a  pp.Pam_sim.SNR);
snrIdx = 1;
%simThroughput(snrIdx) = simThroughput(snrIdx) + app.Pam_sim.Mat_Practical_BER(end)
fprintf('\nThroughput(Mbps) for %d frame(s) = %.4f\n',app.Pam_sim.Num_Frames,Total_Transmision_seg/1e6);
%fprintf('Throughput(%%) for %d frame(s) = %.4f\n',simLocal.NFrames,simThroughput(snrIdx)*100/maxThroughput(snrIdx));



%Graficas_Metricas(app.Pam_sim);

%Waterfall_Estimation_Slot(app.Pam_sim,Indice_Ranura,snr);
%Save_parameters(app.Pam_sim);

