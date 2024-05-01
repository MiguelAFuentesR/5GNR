
% clear
% clc
%Constellations_plot = uifigure('Name', 'Constellations plot');

if isempty(findall(groot, 'Type', 'figure', 'Name', 'Constellations plot'))
    disp("Plot creado")
    Constellations_plot = uifigure('Name', 'Constellations plot');
else 
    disp("Plot existe")
end
%isequal(Constellations_plot, h2)

% for i=1:3
% if exist(findall(0,'type','figure','name','h'))
%     disp("existo")
% else
%     disp("no existo")
%     h = figure ();
% end
% 
% end
