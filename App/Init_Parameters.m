function [app] = Init_Parameters(app)

%Modulation init 
value = app.ModulationDropDown.Value;
switch value
    case "QPSK"
        app.Pam_sim.Modulation = "QPSK";
    case "16QAM"
        app.Pam_sim.Modulation = "16QAM";
    case "64QAM"
        app.Pam_sim.Modulation = "64QAM";
    case "256QAM"
        app.Pam_sim.Modulation = "256QAM";
end
%Channel init 
value = app.ChannelProfileDropDown.Value;
switch value
    case "TDL-A"
        app.Pam_sim.Channel = "TDL-A";
    case "TDL-B"
        app.Pam_sim.Channel = "TDL-B";
    case "TDL-C"
        app.Pam_sim.Channel = "TDL-C";
    case "TDL-D"
        app.Pam_sim.Channel = "TDL-D";
    case "TDL-E"
        app.Pam_sim.Channel = "TDL-E";

end
%Values of SNR estimated

selection = app.TypeSNRDropDown.Value;
switch selection
    case "SNR Static"
        app.Pam_sim.SNR_STATIC = true;
    case "SNR Interval"
        app.Pam_sim.SNR_STATIC = false;
end


app.Pam_sim.SNR_Init = app.EditField_SNRinit.Value;
app.Pam_sim.SNR_intervalos = app.EditField_SNR_step.Value;
app.Pam_sim.SNR_max = app.Knob_SNR.Value;
%Estimation config

%Values of Estimation selected
app.Pam_sim.CNNEstimation = app.CNNModel1CheckBox.Value;
app.Pam_sim.CNNEstimation_2 = app.CNNModel2CheckBox.Value;
app.Pam_sim.Autoencoder_Estimation = app.AutoencoderCheckBox.Value;
app.Pam_sim.EstimacionPractica = app.PracticalCheckBox.Value;
app.Pam_sim.Denoising_Estimation = app.Denoising1CheckBox.Value;
app.Pam_sim.Denoising_Estimation_resta = app.Denoising2CheckBox.Value;


app.Pam_sim.CNNmodel_1 = app.CNNModel1DropDown.Value;
app.Pam_sim.CNNmodel_2 = app.CNNModel2DropDown.Value;

data = app.DataDropDown.Value;
switch data
    case "Frames"
        app.Pam_sim.Transmision_IMG = false;
        app.Pam_sim.Transmision_Bits = false;
    case "Bits"
  
        app.Pam_sim.Transmision_IMG = false;
        app.Pam_sim.Transmision_Bits = true;
    case "Image"
        app.Pam_sim.Transmision_IMG = true;
        app.Pam_sim.Transmision_Bits = false;
    otherwise
end
value = str2double(app.FramesNumberEditField.Value);

switch app.DataDropDown.Value
    case "Frames"
        app.Pam_sim.Num_Frames = value;
    case "Bits"
        app.Pam_sim.Bits_Deseados = value;
    otherwise
end
value = app.TypeVelocityDropDown.Value;
switch value

    case "Vel Static"
        app.Pam_sim.Vel_sim_Estatic = true;
        app.Label_end_vel.Visible = "off";

        app.VelEndLabel.Visible  = "off";
        app.StepLabel_2.Visible = "off";
        app.Knob_Vel.Visible = "off";
        app.EditField_vel_step.Visible = "off";


    case "Vel Interval"
        app.Pam_sim.Vel_sim_Estatic = false;
        app.Label_end_vel.Visible = "on";

        app.VelEndLabel.Visible  = "on";
        app.StepLabel_2.Visible = "on";
        app.Knob_Vel.Visible = "on";
        app.EditField_vel_step.Visible = "on";
    otherwise

end
% Values of velocity
app.Pam_sim.Vel_init = app.EditField_vel_init.Value;
app.Pam_sim.Vel_step = app.EditField_vel_step.Value;
app.Pam_sim.Vel_end = app.Knob_Vel.Value;


%Save parameters
app.Pam_sim.Save_Variables  = app.ExportParametersCheckBox.Value;

%Phase compensation
app.Pam_sim.Compensacion_Fase = app.CNNPhaseCompensationCheckBox.Value;


%% INITIALIZATION OF GRAPH ELEMENTS 

value = app.GraphTypeDropDown.Value;
switch value
    case "Current Simulation"
        app.SelectFileDropDown.Visible = "off";
        app.SelectFileLabel.Visible = "off";
        app.Parameters = app.Pam_sim;
    case "Load File"

        Files = dir('Outputs/*.mat');
        numfiles = length(Files);
        mydata = cell(1, numfiles);
        for k = 1:numfiles
            mydata{k} = Files(k).name;
        end
        app.SelectFileDropDown.Visible = "on";
        app.SelectFileLabel.Visible = "on";
        app.SelectFileDropDown.Items = mydata;

end


value = app.DropDown_2.Value;
switch value
    case "BER vs SNR"
        app.Pam_sim.Graph_type = "BER";

        app.Unique.Title.String = "Bit Error Rate";
        app.Unique.YLabel.String = "BER";
        app.Unique.XLabel.String = "SNR(dB)";
    case "EVM vs SNR"
        app.Pam_sim.Graph_type = "EVM";

        app.Unique.Title.String = "Error Vector Machine";
        app.Unique.YLabel.String = "EVM(%)";
        app.Unique.XLabel.String = "SNR(dB)";
    case "MSE vs SNR"
        app.Pam_sim.Graph_type = "MSE";
        app.Unique.Title.String = "Mean Square Error";
        app.Unique.YLabel.String = "MSE";
        app.Unique.XLabel.String = "SNR(dB)";
    case "Time vs SNR"
        app.Pam_sim.Graph_type = "Time";
        app.Unique.XLabel.String = "SNR(dB)";
end

app.Pam_sim.Time_Simulation = false;

app.Pam_sim.Grap1_type = app.Grafica1DropDown.Value;
app.Pam_sim.Grap2_type = app.Grafica2DropDown.Value;
app.Pam_sim.Grap3_type = app.Grafica3DropDown.Value;

path_x = '/media/miguel/UNiversidad/Tesis/Codigos_Finales/';
addpath([path_x,'Estimation']);
addpath([path_x,'Functions']);
addpath([path_x,'Generation']);
addpath([path_x,'Graph_Functions']);
addpath([path_x,'Models']);
addpath([path_x,'Outputs']);

end