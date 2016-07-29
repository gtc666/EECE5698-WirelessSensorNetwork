y1 = load('resultThpt(a).txt');
y2 = load('resultThpt(b).txt');
x = 1:20;
%figure(1);
%plot(x,y1);
figure(3);
plot(x,y1,'-ob',x,y2,'-b');
xlabel('pairs','FontSize',13);
ylabel({'Throughput', '(bits/s)'},'FontSize',13);
title('Throughput vs Number of pairs','FontSize',15);
%legend('500Bytes RTS/CTS enabled','Location','southeast');
legend('500Bytes RTS/CTS enabled', '500Bytes RTS/CTS disabled','Location','southeast');