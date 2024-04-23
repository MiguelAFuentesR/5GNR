%%%% GRAFICAS DEL DESEMEPEÑO DEL MODELO %%%%%%%%%%%%%%%%%%
clear all; clc; close all;

CNN_Latency = [17.13, 0.35 , 0.97, 1.32, 39.08, 7.85, 42.96, 7.48];
CNN_MSE = [0.0115, 0.0359, 0.0341, 0.0206, 0.0108, 0.0132, 0.0127, 0.0150];
Label_CNN = ["CNN1", "CNN2", "CNN3", "CNN4","CNN5", "CNN6", "CNN7", "CNN8"];

Autoencoder_Latency = [19.28, 22.21, 113.15];
Autoencoder_MSE = [0.0221, 0.0237, 0.0096];
Label_Autoencoder = ["Autoencoder1", "Autoencoder2", "Autoencoder3"];

Denoising_Latency = [32.52, 32.52];
Denoising_MSE = [0.0130, 0.0098];
Label_Denoising = ["Denoising1", "Denoising2"];

%% Se generan las gráficas
plot(CNN_Latency, CNN_MSE,'LineWidth',3,'Color',"#F86E6E", Marker="*", LineStyle="none", MarkerMode="manual")
text(CNN_Latency, CNN_MSE+0.001, Label_CNN, Color='#F86E6E', FontSize=12,FontSmoothing='on', FontWeight='bold');
hold on
plot(Autoencoder_Latency, Autoencoder_MSE,'LineWidth',3,'Color',"#004074", Marker="square", LineStyle="none", MarkerMode="manual")
text(Autoencoder_Latency-5, Autoencoder_MSE+0.001, Label_Autoencoder, Color='#004074', FontSize=12,FontSmoothing='on', FontWeight='bold');
plot(Denoising_Latency, Denoising_MSE,'LineWidth',3,'Color',"#32B90A", Marker="diamond", LineStyle="none", MarkerMode="manual")
text(Denoising_Latency-5, Denoising_MSE+0.001, Label_Denoising, Color='#32B90A', FontSize=12,FontSmoothing='on', FontWeight='bold');
hold off
ylabel('Función de error (MSE)', 'FontSize',15);
xlabel('Latencia (ms)', 'FontSize',15)
grid on;
xlim([-1 125])
title('Desempeño de los estimadores de canal', FontSize=15)



