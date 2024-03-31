function [Est] = Transmitter(Parameters)


%Definir el numero de slots
Parameters.portadora.NSlot = Parameters.Indice_Ranura;

% Generar random codeword(s)
Parameters.Numero_CW = Parameters.pdsch.NumCodewords; % Numero de codewords

if Parameters.Transmision_IMG || Parameters.Transmision_Bits
    % Envio de datos en funcion a una entrada externa, imagen, fichero, etc
    Bits_faltantes = length(Parameters.trData) - length(Parameters.txbits);
    if Bits_faltantes >= Parameters.step
        Parameters.data_slot = Parameters.trData(Parameters.block_posicion+1:Parameters.End_pos);
        Parameters.block_posicion = Parameters.End_pos;
        Parameters.End_pos = Parameters.block_posicion + Parameters.step;
    else
        %Enviar los ultimos bits y completar el slot con ceros
        Parameters.Complemento = Parameters.step-Bits_faltantes ;
        data_aux = transpose(zeros(1,Parameters.Complemento));
        Parameters.data_slot = [Parameters.trData(Parameters.block_posicion+1:end);data_aux];
    end
else
    % Se enviaran datos aleatorios perfectos en funcion al numero
    % de frames deseados
    data = cell(1,Parameters.Numero_CW);
    %Bucle generador de datos aleatorios para transmitir en funcion al
    %numero de codewords

    for i = 1:Parameters.Numero_CW
        data{i} = randi([0 1],Parameters.Informacion_Indices_PDSCH.G(i),1);
        Parameters.data_slot  = data{1,1};
    end
end

Parameters.txbits = [Parameters.txbits; Parameters.data_slot];


% Obtener los simbolos Modulados

% Se modulan los bits en el tipo de modulacion definido
Parameters.Simbolos_pdsch = nrPDSCH(Parameters.portadora,Parameters.pdsch,Parameters.data_slot);


%Crear la grilla de recursos con los datos generados y la insercion de
%pilotos

Parameters.Grilla_Subframe = nrResourceGrid(Parameters.portadora,Parameters.pdsch.NumLayers);
Parameters.Grilla_Subframe(Parameters.Indices_Pdsch) = Parameters.Simbolos_pdsch;
Parameters.Grilla_Subframe(Parameters.Indices_dmrs) = Parameters.Simbolos_dmrs;
Parameters.Grilla_Subframe(Parameters.Indices_ptrs) = Parameters.Simbolos_ptrs;


%Ahora se modulara  la grilla de recursos empleando OFDM

Parameters.portadora.NSlot = 0; % Resetear el numero de slots a 0 para la modulacion OFDM
[Parameters.txWaveform,Parameters.waveformInfo] = nrOFDMModulate(Parameters.portadora,Parameters.Grilla_Subframe);
Parameters.txWaveform_sincanal = Parameters.txWaveform;


Est = Parameters;
end