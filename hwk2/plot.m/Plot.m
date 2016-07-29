avg_delay = [0.016013987, 0.04282082, 0.09351047666666665, 0.14117032000000002, 0.1610372];
avg_energy = [0.539234, 0.22702983333333338, 0.15128509999999998, 0.1393967766666667, 0.10398844];
x = [1,5,10,15,20];
figure(1);
plot(x,avg_delay);
xlabel('sources','FontSize',13);
ylabel({'average one-way latency', '(ms)'},'FontSize',13);
title('Average one-way latency vs Number of sources','FontSize',15);


figure(2);
plot(x,avg_energy);
xlabel('sources','FontSize',13);
ylabel({'Average dissipated energy', '(J)'},'FontSize',13);
title('Average dissipated energy vs Number of sources','FontSize',15);
