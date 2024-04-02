function app = Complet_Simulation(app)

try


    %% ------------------- SIMULATION CONFIGURATION ----------------------------
    %%%%%%Para el valor del SNR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if app.Pam_sim.SNR_STATIC
        app.Pam_sim.SNR_Init = app.EditField_SNRValue.Value;
        app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:1:app.Pam_sim.SNR_Init; % Relación señal/ruido lineal
    else
        aux = round(app.RangeSliderSNR.Value);
        app.Pam_sim.SNR_Init = aux(1);
        app.Pam_sim.SNR_max = aux(2);
        app.Pam_sim.SNR_dB = app.Pam_sim.SNR_Init:app.Pam_sim.SNR_intervalos:app.Pam_sim.SNR_max;
    end

    %%%%% Para la velocidad %%%%%%%%%%%%%%%%%%%%%%%%%%
    if app.Pam_sim.Vel_sim_Estatic
        app.Pam_sim.Vel_values = app.EditField_vel_init.Value;
    else
        aux2 = round(app.RangeSlider_Vel.Value);
        app.Pam_sim.Vel_init = aux2(1);
        app.Pam_sim.Vel_end = aux2(2);
        app.Pam_sim.Vel_values = app.Pam_sim.Vel_init:app.Pam_sim.Vel_step:app.Pam_sim.Vel_end;
    end

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

    %% ------------------------------- INIT SIMULATION -------------------------------------
    for Velo = app.Pam_sim.Vel_values
        app.Pam_sim.User_Velocity = Velo;
        app.Pam_sim.SNR_Recorridas  = [];
        %Inicialización y configuración de la portadora, Modulacion y canal
        % Parametros : Tipo de modulacion, Perfil de canal, Velocidad Usuario
        app.Pam_sim = Simulation_Configuration(app.Pam_sim);% Parametros de la simulacion
        for snr = app.Pam_sim.SNR_dB
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
                    app.Pam_sim = Denoising_Estimation(app.Pam_sim,app.Pam_sim.estimacionRNA_Denoising);
                    app.Pam_sim.tEnd_Denoising= toc(tStart_Denoising);
                end
                %% ----------------- Estimacion de Canal Practica ---------------------
                if app.Pam_sim.EstimacionPractica
                    tStart_Practical = tic;
                    app.Pam_sim = Practical_Estimation(app.Pam_sim);
                    app.Pam_sim.tEnd_Practical = toc(tStart_Practical);
                end

                %% ----------------- Compensacion de fase de los Simbolos ----------------
                if app.Pam_sim.Compensacion_Fase
                    app.Pam_sim  = Phase_Compensantion(app.Pam_sim);
                end
                %disp(['Slot ',num2str(Indice_Ranura),' Procesado'])

                app.Pam_sim = Metricas_Slot(app.Pam_sim);

                %Constelaciones(app.Pam_sim);
                app = App_Waterfall_Estimation_Time(app,app.Pam_sim,Indice_Ranura,snr);
            end
            app.Pam_sim = Matrix_metricas(app.Pam_sim);
        end
        disp("Velocidad de "+Velo+"km/h Terminada")
        if app.Pam_sim.Save_Variables
            Save_parameters(app.Pam_sim);
        end
    end

catch error
  x = 0 ;
   uialert(app.ChannelEstimationwithANNUIFigure,['  There was an error! The message was:   ',error.message, ' the identifier was: ',error.identifier,],"Invalid File","Icon","error");
end
%uialert(app.UIFigure,['  There was an error! The message was:   ',error.message, ' the identifier was: ',error.identifier,],"Invalid File","Icon","error");
%% ------------------------------- END SIMULATION --------------------------------------


end