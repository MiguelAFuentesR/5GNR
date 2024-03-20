%En este archivo se desarrollaran las graficas 
clear all
close all 
clc

marks = ["o","pentagram","square","diamond","^","+","hexagram",".","x","_","|","square","diamond","^","v","<",">","*"];
lines = ["-","--",":","-."];
Labels = ["CNN","Practical","Perfect","Interpolacion","Rayleight","Theorical"] ;
Labels_2 = ["CNN","Practical","Interpolacion"] ;
%colors = ["r","g","b","c","m","k"];
Vel_values = zeros(1,8);
Vel_values = [5;10 ;20; 30; 60; 90; 120;150];
colors = ["k"];


Pam_sim = load('Paremeters_Velo_120.mat').Pam_sim;
EbN0_dB = Pam_sim.SNR_dB;  % SNR en dB


%% ------------------------------ BER ----------------------------------------


%% MSE, BER, EVM

%% Matrices asociadas a la respuesta de los modelos en funcion de la velocidad del usuario 
% 
% v= 0:5:150;  %Velocidad del usuario en km/h
% EbN0_dB = 15;% SNR en dB
% load("RMSE_vel.mat");
% load("MSE_vel.mat")
% 
% [au,xd] = size(mat_rmse_vel);
% v= 0:5:150;
% figure();
% for j=1:au
%     hold on
%     plot(v,mat_rmse_vel(j,:),lines(randi(length(lines)))+marks(j)+colors(randi(length(colors))))
%     grid on
%     xticks([0:5:150])
%     xlabel("V(km/h)")
%     ylabel("RMSE")
%     title("RMSE en funcion de la velocidad del usuario con SNR = 15 dB")
%     legend (sprintfc('Modelo %.1i',1:au),'Location','northeast')
% end

%% Grafrico del EVM vs BER 
Mat_BER =[];
Mat_EVM =[];
Mat_MSE =[];

Mat_CNN_MSE =[];
Mat_Practical_MSE =[];
Mat_Lineal_MSE =[];


Mat_CNN_BER =[];
Mat_Practical_BER =[];
Mat_Lineal_BER =[];

Mat_CNN_EVM =[];
Mat_Practical_EVM =[];
Mat_Lineal_EVM =[];

% 
% 
% for i = 1:1:length(Vel_values)
%     mo = load('Paremeters_Velo_'+string(Vel_values(i))+'.mat');
%     Pam_sim = mo.Pam_sim;
% 
%     Mat_BER(:,:,i) = [Pam_sim.CNN_BER; Pam_sim.Practical_BER; Pam_sim.Perfect_BER; Pam_sim.Lineal_BER];
%     Mat_EVM(:,:,i) = [Pam_sim.CNN_EVM; Pam_sim.Practical_EVM; Pam_sim.Perfect_EVM; Pam_sim.Lineal_EVM];
%     Mat_MSE(:,:,i) = [Pam_sim.CNN_MSE; Pam_sim.Practical_MSE; Pam_sim.Lineal_MSE];
% 
%     Mat_CNN_MSE(i,:) = Pam_sim.CNN_MSE;
%     Mat_Practical_MSE(i,:) = Pam_sim.Practical_MSE;
%     Mat_Lineal_MSE(i,:) = Pam_sim.Lineal_MSE;
% 
%     Mat_CNN_BER(i,:) = Pam_sim.CNN_BER;
%     Mat_Practical_BER(i,:) = Pam_sim.Practical_BER;
%     Mat_Lineal_BER(i,:) = Pam_sim.Lineal_BER;
% 
%     Mat_CNN_EVM(i,:) = Pam_sim.CNN_EVM;
%     Mat_Practical_EVM(i,:) = Pam_sim.Practical_EVM;
%     Mat_Lineal_EVM(i,:) = Pam_sim.Lineal_EVM;
% end
% 
% [SNR,VEL] = meshgrid(EbN0_dB,Vel_values);
% 
% figure;
% t = tiledlayout(2,2);
% %///////////////////////////////////////////
% ax1 = nexttile
% surface(VEL,SNR,Mat_CNN_MSE);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("EVM (%)")
% view([80 20])
% title("Estimación CNN")
% %///////////////////////////////////////////
% ax2 = nexttile
% surface(VEL,SNR,Mat_Practical_MSE);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("EVM (%)")
% view([80 20])
% 
% title("Estimación Practica")
% %///////////////////////////////////////////
% ax3 = nexttile
% surface(VEL,SNR,Mat_Lineal_MSE);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("EVM (%)")
% view([80 20])
% colormap(ax3,gray)
% title("Estimación Lineal")
% 
% set(gca,'XScale','log')
% 
% 
% figure;
% t2 = tiledlayout(2,2);
% %///////////////////////////////////////////
% ax_1 = nexttile
% surf(VEL,Mat_CNN_MSE,Mat_CNN_BER,SNR);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("BER")
% view([80 20])
% title("Estimación CNN")
% %///////////////////////////////////////////
% ax_2 = nexttile
% surf(VEL,Mat_Practical_MSE,Mat_Practical_BER,SNR);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("BER")
% view([80 20])
% title("Estimación Practica")
% %///////////////////////////////////////////
% ax_3 = nexttile
% surf(VEL,Mat_Lineal_MSE,Mat_Lineal_BER,SNR);
% hcb=colorbar;
% hcb.Title.String = "SNR (dB)";
% shading flat
% xlabel("Velocidad (km/h)")
% ylabel("MSE")
% zlabel("BER")
% view([80 20])
% colormap(ax_3,gray)
% title("Estimación Lineal")
% 
% set(gca,'ZScale','log')

%% METRICAS BER 


%% Matrices asociadas a la respuesta de los modelos en funcion de la relacion señal a ruido 

figure();
plot(EbN0_dB,Pam_sim.CNN_MSE,lines(randi(length(lines)))+marks(randi(length(lines))))
hold on
plot(EbN0_dB,Pam_sim.Practical_MSE,lines(randi(length(lines)))+marks(randi(length(lines))))
plot(EbN0_dB,Pam_sim.Lineal_MSE,lines(randi(length(lines)))+marks(randi(length(lines))))
%set(gca,'yscale','log')
grid on
%xticks(EbN0_dB)
%set(gca,'xscale','log')
xlabel("SNR(dB)")
ylabel("MSE")
title("MSE en funcion de SNR")
legend (Labels_2,'Location','northeast')

%% Matrices asociadas al BER de los modelos


figure();
semilogy(EbN0_dB,Pam_sim.CNN_BER,lines(randi(length(lines)))+marks(randi(length(lines))))
hold on
semilogy(EbN0_dB,Pam_sim.Practical_BER,lines(randi(length(lines)))+marks(randi(length(lines))))
semilogy(EbN0_dB,Pam_sim.Perfect_BER,lines(randi(length(lines)))+marks(randi(length(lines))))
semilogy(EbN0_dB,Pam_sim.Lineal_BER,lines(randi(length(lines)))+marks(randi(length(lines))))
set(gca,'yscale','log')
grid on
%xticks(EbN0_dB)
%set(gca,'xscale','log')
snr = 10.^(EbN0_dB/10);
rayleight = 0.5.*( 1 - sqrt( (0.5.*snr) ./ (1+0.5.*snr) ) );
semilogy(EbN0_dB, rayleight,'DisplayName','Rayleight');
%semilogy(EbN0_dB,erfc(sqrt(0.5*10.^(EbN0_dB/10))),'-k')
xlabel("SNR(dB)")
ylabel("BER")
title("BER en funcion de SNR")
legend (Labels,'Location','northeast')
