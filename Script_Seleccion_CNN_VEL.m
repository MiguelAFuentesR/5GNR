format shortEng
format compact
close all

addpath('Estimation');
addpath('Functions');
addpath('Generation');
addpath('Graph_Functions');
addpath('Models');
addpath('Outputs');

rng(45)

app = [];
app.Pam_sim = [];% Parametros de la simulacion

app.Pam_sim.Modulation = "16QAM";
app.Pam_sim.Channel = "TDL-A";

%% SNR Config
app.Pam_sim.SNR_STATIC = false;
app.Pam_sim.SNR_Init = 0; % Valor Estatico de SNR
app.Pam_sim.SNR_intervalos = 10;
app.Pam_sim.SNR_max = 20; %Valor maximo que sera emulado (Se empieza en cero hasta ese valor)

if app.Pam_sim.SNR_STATIC
    app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:1:app.Pam_sim.SNR_Init; % Relación señal/ruido lineal
else
    app.Pam_sim.SNR_dB= app.Pam_sim.SNR_Init:app.Pam_sim.SNR_intervalos:app.Pam_sim.SNR_max;
end

app.Pam_sim.Vel_sim_Estatic = false;

app.Pam_sim.Vel_init = 0;
app.Pam_sim.Vel_step = 10;
app.Pam_sim.Vel_end = 120;



if app.Pam_sim.Vel_sim_Estatic
    app.Pam_sim.Vel_values = app.Pam_sim.Vel_init ;
else
    app.Pam_sim.Vel_values = app.Pam_sim.Vel_init:app.Pam_sim.Vel_step:app.Pam_sim.Vel_end  ;
end


%% --------------- Estimation Config


app.Pam_sim.CNNmodel_2 = 5;
app.Pam_sim.CNNEstimation = true;

app.Pam_sim.CNNEstimation_2 = false;
app.Pam_sim.Autoencoder_Estimation = false;
app.Pam_sim.EstimacionPractica = false;
app.Pam_sim.Denoising_Estimation = false;
app.Pam_sim.Denoising_Estimation_resta = false;


app.Pam_sim.Compensacion_Fase = false;% Realizar compensacion de fase con pilotos PT-RS para CNN

app.Pam_sim.Save_Variables  = true;

%% ------------- Data config

app.Pam_sim.Transmision_IMG = false; % Envio de una imagen
app.Pam_sim.Transmision_Bits = false;
app.Pam_sim.Bits_Deseados = 1200000;
app.Pam_sim.Num_Frames = 5; %Numero de frames deseados a enviar
app.Pam_sim.Path_IMG = '/media/miguel/Universidad/Tesis/Codigos_Finales/Chacon.png';

%%
app.Pam_sim.models = {'Lineal','Perfect'};
%% Ciclo de Procesamiento (Simulacion transmision en el tiempo )

for i = 1:1:8
    app.Pam_sim.CNNmodel_1 = i;
    disp(["Estimando con Red Neuronal ",i]);
    app.Pam_sim.models = [app.Pam_sim.models 'CNN'];
    app.Pam_sim.estimacionRNA_1 = load("CNN_Modelo"+app.Pam_sim.CNNmodel_1+".mat").estimacionRNA;
    for Velo = app.Pam_sim.Vel_values
        app.Pam_sim.SNR_Recorridas =[];
        app.Pam_sim.User_Velocity = Velo;
        %Inicialización y configuración de la portadora, Modulacion y canal
        % Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
        app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion

        for snr = app.Pam_sim.SNR_dB
            disp(['SNR de ',num2str(snr),' dB'])
            app.Pam_sim =Variables_initialization(app.Pam_sim,snr);
            app.Pam_sim.SNR_Recorridas = [app.Pam_sim.SNR_Recorridas snr];
            for Indice_Ranura = 0:app.Pam_sim.slots - 1

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

                    tStart_CNN = tic;
                    app.Pam_sim = CNN_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_1);
                    app.Pam_sim.tEnd_CNN = toc(tStart_CNN);
                    app.Pam_sim.CNN_pdschEq_sin = app.Pam_sim.CNN_pdschEq ;

                end

                %disp(['Slot ',num2str(Indice_Ranura),' Procesado'])

                app.Pam_sim = Metricas_Slot(app.Pam_sim);

                %Constelaciones(app.Pam_sim);
                %Waterfall_Estimation_Time(app.Pam_sim,Indice_Ranura,snr);
            end

            app.Pam_sim = Matrix_metricas(app.Pam_sim);

            %Graficas_Metricas(app.Pam_sim);

        end
        %Waterfall_Estimation_Slot(app.Pam_sim,Indice_Ranura,snr);
        Save_parameters_CNN(app.Pam_sim);
        %disp("Velocidad de "+Velo+"km/h Terminada")
    end
end
