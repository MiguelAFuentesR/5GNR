C = {'k','b','r','g','y',[.5 .6 .7],[.8 .2 .6]} % Cell array of colros.
x = 0:.01:1;
y =[22 45 35 10 14 08 50 ]
hold on
for ii=1:7
   plot(ii,y(ii),'color',C{ii},'marker','o')
end
legend({'x.^1';'x.^2';'x.^3';'x.^4';'x.^5';'x.^6';'x.^7'})