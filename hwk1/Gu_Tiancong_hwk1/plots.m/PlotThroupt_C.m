y1 = load('resultThpt(c_a_100).txt');
y2 = load('resultThpt(c_a_300).txt');
y3 = load('resultThpt(c_a_500).txt');
y4 = load('resultThpt(c_a_1000).txt');
z1 = load('resultThpt(c_b_100).txt');
z2 = load('resultThpt(c_b_300).txt');
z3 = load('resultThpt(c_b_500).txt');
z4 = load('resultThpt(c_b_1000).txt');

x = 1:20;
figure(5);
plot(x,y1,'-ob',x,y2,'-or',x,y3,'-og',x,y4,'-om',x,z1,'-b',x,z2,'-r',x,z3,'-g',x,z4,'-m');
xlabel('pairs','FontSize',13);
ylabel({'Throughput', '(bits/s)'},'FontSize',13);
legend('100Bytes RTS/CTS enabled', '300Bytes RTS/CTS enabled','500Bytes RTS/CTS enabled','1000Bytes RTS/CTS enabled','100Bytes RTS/CTS disabled','300Bytes RTS/CTS disabled','500Bytes RTS/CTS disabled','1000Bytes RTS/CTS disabled','Location','south','Orientation','vertical');
title('Throughput vs Number of pairs','FontSize',15);