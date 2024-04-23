%%%% Se carga el modelo neuronal
clear all; clc; close all;


% Se importan los datos necesrios para evaluar los modelos
data = load("C:\Users\pipea\OneDrive\Escritorio\Codigos Finales 1\X_train1.mat").x_train;
label = load("C:\Users\pipea\OneDrive\Escritorio\Codigos Finales 1\Y_train1.mat").y_train;

ratio = 0.75; %Porcentaje para la separación de los datos

[trainId,~,testId] = dividerand(1000,ratio,0.0,1-ratio);

x_train = data(:,:,:,trainId);
y_train = label(:,:,:,trainId);

x_val = data(:,:,:,testId);
y_val = label(:,:,:,testId);

x_train = cat(4, x_train(:,:,1,:), x_train(:,:,2,:));
y_train = cat(4, y_train(:,:,1,:), y_train(:,:,2,:));

x_test = cat(4, x_val(:,:,1,:), x_val(:,:,2,:));
y_test = cat(4, y_val(:,:,1,:), y_val(:,:,2,:));
%% Se carga el modelo
clc

CNN = load("5GNR\Models\Denoising2.mat");
CNN = CNN.estimacionRNA;

%% Se evalúa el desempeño con los datos

val_MSE = [];
for i=1:size(x_test,4)
    perform = predict(CNN, x_test(:,:,:,i));
    perform = x_test(:,:,:,i)-perform;
    aux = immse(double(perform), y_test(:,:,:,i));
    val_MSE(i) = aux;
end
val_MSE = mean(val_MSE);
%% 

hPC = dlhdl.ProcessorConfig();
hPC.TargetFrequency = 1800; %%%%% Con la velocidad de reloj en MHz
hPC.TargetPlatform = 'Xilinx Zynq ZC706 evaluation kit';

%% 

hPC.estimatePerformance(CNN)