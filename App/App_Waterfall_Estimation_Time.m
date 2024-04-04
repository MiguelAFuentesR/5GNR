function [app] = App_Waterfall_Estimation_Time(app,Parameters,Indice_Ranura,snr)

Filas = 3;
Columnas = 3;
Pos = 0;
%% Gráficas con los resultados
[~,s] = size(Parameters.Time_Grid_Lineal);
Slot = s/14;  %Numero total de slots actuales 

if mod(Indice_Ranura,10) == 0
    Frame = 1+Indice_Ranura/10;
else
    Frame = 1+floor(Indice_Ranura/10);
end

if Indice_Ranura >= 10
Indice_Ranura = mod(Indice_Ranura,10);
end

drawnow
%sgtitle([' Respuesta de magnitud de canal estimada para el Frame ' num2str(Frame) ' Slot ' num2str(Indice_Ranura+1) ' con SNR: ' num2str(snr) ' dB'])
app.Titulo_TimeLabel.Text = ([' Respuesta de magnitud de canal estimada para el Frame ' num2str(Frame) ' Slot ' num2str(Indice_Ranura+1) ' con SNR: ' num2str(snr) ' dB']);


%app.Pam_sim.Grap1_type 

%% Description for Graph 1
EVM_Graph1 = Parameters.(app.Pam_sim.Grap1_type +"_EVM");
Time_Graph1 = Parameters.(app.Pam_sim.Grap1_type +"_Time");

%% Description for Graph 2
EVM_Graph2 = Parameters.(app.Pam_sim.Grap2_type +"_EVM");
Time_Graph2 = Parameters.(app.Pam_sim.Grap2_type +"_Time");

%% Description for Graph 3
if strcmp(app.Pam_sim.Grap1_type,"Perfect")
    MSE_Graph1 = [0];
else
    MSE_Graph1 = Parameters.(app.Pam_sim.Grap1_type +"_MSE");
end
if strcmp(app.Pam_sim.Grap2_type,"Perfect")
    MSE_Graph2 = [0];
else
    MSE_Graph2 = Parameters.(app.Pam_sim.Grap2_type +"_MSE");
end
if strcmp(app.Pam_sim.Grap3_type,"Perfect")
    MSE_Graph3 = [0];
else
    MSE_Graph3 = Parameters.(app.Pam_sim.Grap3_type +"_MSE");
end



EVM_Graph3 = Parameters.(app.Pam_sim.Grap3_type +"_EVM");
Time_Graph3 = Parameters.(app.Pam_sim.Grap3_type +"_Time");

try
    BER_Graph1 = Parameters.("Mat_"+app.Pam_sim.Grap1_type+"_BER");
    BER_Graph2 = Parameters.("Mat_"+app.Pam_sim.Grap2_type+"_BER");
    BER_Graph3 = Parameters.("Mat_"+app.Pam_sim.Grap3_type+"_BER");
    BER = [BER_Graph1(end) BER_Graph2(end) BER_Graph3(end)];
    [xBER,I_BER] = sort(BER);
    Labels_BER =  Labels(I_BER);
    color_BER = color(I_BER);
catch
end

MSE = [MSE_Graph1(end) MSE_Graph2(end) MSE_Graph3(end)];
EVM = [EVM_Graph1(end) EVM_Graph2(end) EVM_Graph3(end)];
Time = [Time_Graph1(end) Time_Graph2(end) Time_Graph3(end)];


%%Organize the matrix in a descend order 
MSE
[xMSE,I_MSE] = sort(MSE);
[xEVM,I_EVM] = sort(EVM);
[xTime, I_Time] = sort(Time);


color = {'#A8D6FA','#C8FAA8','#FAB6A8'};
Labels= {app.Pam_sim.Grap1_type,app.Pam_sim.Grap2_type,app.Pam_sim.Grap3_type};

% Sincronization of the labels and  colors 

Labels_MSE =  Labels(I_MSE);
Labels_EVM =  Labels(I_EVM);
Labels_Time =  Labels(I_Time);


%For graph 1 
Index_color_mse_graph1 = find(contains(Labels_MSE,app.Pam_sim.Grap1_type));
Index_color_evm_graph1 = find(contains(Labels_EVM,app.Pam_sim.Grap1_type));
app.Model1_EVMLabel.FontColor = color{Index_color_evm_graph1};
app.Model1_MSELabel.FontColor = color{Index_color_mse_graph1};

app.Model1_MSELabel.Text = string(MSE_Graph1(end));
app.Model1_EVMLabel.Text = string(EVM_Graph1(end));
imagesc(app.Graph1,abs(Parameters.("Time_Grid_"+app.Pam_sim.Grap1_type)));


%For graph 2
Index_color_mse_graph2 = find(contains(Labels_MSE,app.Pam_sim.Grap2_type));
Index_color_evm_graph2 = find(contains(Labels_EVM,app.Pam_sim.Grap2_type));
app.Model2_EVMLabel.FontColor = color{Index_color_evm_graph2};
app.Model2_MSELabel.FontColor = color{Index_color_mse_graph2};

app.Model2_MSELabel.Text = string(MSE_Graph2(end));
app.Model2_EVMLabel.Text = string(EVM_Graph2(end));
imagesc(app.Graph2,abs(Parameters.("Time_Grid_"+app.Pam_sim.Grap2_type)));


%For graph 3 
Index_color_mse_graph3 = find(contains(Labels_MSE,app.Pam_sim.Grap3_type));
Index_color_evm_graph3 = find(contains(Labels_EVM,app.Pam_sim.Grap3_type));
app.Model3_EVMLabel.FontColor = color{Index_color_evm_graph3};
app.Model3_MSELabel.FontColor = color{Index_color_mse_graph3};

app.Model3_MSELabel.Text = string(MSE_Graph3(end));
app.Model3_EVMLabel.Text = string(EVM_Graph3(end));
imagesc(app.Graph3,abs(Parameters.("Time_Grid_"+app.Pam_sim.Grap3_type)));



% if Parameters.CNNEstimation
%     %///////////////////////////////////////////
%     Pos=Pos+1;
%     subplot(Filas,Columnas,[1,2]);
%     imagesc(abs(Parameters.Time_Grid_CNN));
%     xlabel('OFDM Symbol');
%     ylabel('Subcarrier');
%     %title({'Estimacion Red Neuronal', [' MSE: ', num2str(mean(Parameters.CNN_EVM))]});
%     title({['Estimacion Red Neuronal'],['{\color{',mse_cnn,'}MSE : ', num2str(mean(Parameters.CNN_MSE)), '  \color{',evm_cnn,'} EVM : ' num2str(mean(Parameters.CNN_EVM)) ' % }']})
% 
%     ax = gca;
%     ax.TitleHorizontalAlignment = 'left';
%     %///////////////////////////////////////////
%     subplot(Filas,Columnas,[4,5]);
%     imagesc(abs(Parameters.Time_Grid_Lineal));
%     ylabel('Subcarrier');
%     title({['Estimacion Interpolacion Lineal'],['{\color{',mse_Lineal,'}MSE : ', num2str(mean(Parameters.Lineal_MSE)), '  \color{',evm_Lineal,'} EVM : ' num2str(mean(Parameters.Lineal_EVM)) ' % }']})
%     ax = gca;
%     ax.TitleHorizontalAlignment = 'left';
% 
% end
% if Parameters.EstimacionPractica
%     %///////////////////////////////////////////
%     subplot(Filas,Columnas,[7,8]);
%     imagesc(abs(Parameters.Time_Grid_Practical));
%     ylabel('Subcarrier');
%     title({['Estimacion Practica'],['{\color{',mse_Practical,'}MSE : ', num2str(mean(Parameters.Practical_MSE)), '  \color{',evm_Practical,'} EVM : ' num2str(mean(Parameters.Practical_EVM)) ' % }']})
%     %title({'Estimacion Practica', ['MSE: ', num2str(mean(Parameters.Practical_EVM))]});
% 
%     ax = gca;
%     ax.TitleHorizontalAlignment = 'left';
% end
% 
% 
% 
% 
% 
% ax = get(gca,'Position');
% %// Place axis 2 below the 1st.
% 
% ax2 = axes('Position',[ax(1) ax(2)-.05 ax(3) ax(4)],'Color','none','YTick',[],'YTickLabel',[]);
% %// Adjust limits
% xlim([0 Slot])
% xlabel('Time(ms)')
% if Slot>100
%     interval = 10;
% elseif  Slot>30
%     interval = 5;
% else 
%     interval = 1;
% end
% 
% xticks((0:interval:Slot))
% 
% 
% 
% subplot(Filas,Columnas,[3,6,9]);
% imagesc(abs(Parameters.Time_Grid_Perfect));
% xlabel('OFDM Symbol');
% ylabel('Subcarrier');
% title('Estimacion Perfecta (Ideal)')
% hcb=colorbar;
% hcb.Title.String = "|H|";



end