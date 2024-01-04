clc;
close all;
clear all;

%% LOAD P1, P2, C1 DATA

%energy_consumption_p1
%net_energy_p1
%load('cost_current_p1.mat');
%load('energy_consumption_p2.mat')
%cost_solar_p2
%cost_solar_p1
%load('emissions_solar_p1');
%load('net_energy_p2.mat')
%load('energy_consumption_c1.mat')

load MarginalEmissionsFactors.mat; 
FRCC=1;
MRO=2;
NPCC=3;
RFC=4;
SERC=5;
SPP=6;
TRE=7;
WECC=8;
region=input('marginal emissions region?');                      

MEF=MarginalEmissionsFactors{region,2}/1000;                                %kg/kWh
load('net_power_p1.mat');
load('net_power_p2.mat');
load('power_consumption_c1.mat');

%load('cost_current_p2.mat');
%load('cost_current_c1.mat');

%load('emissions_current_c1');
%load('emissions_solar_p2');

p1_cost=0.071;  %usd/kWh
p2_cost=0.066;  %usd/kWh
c1_cost=0.156;  %usd/kWh

for i=1:length(net_power_p2);
    if (net_power_p1(i)>=0) && (net_power_p2(i)>=0) && (power_consumption_c1(i)>=0);          %111
        p1_utility_power(i)=net_power_p1(i);
        utility_costs_p1(i)=p1_cost;

        p2_utility_power(i)=net_power_p2(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;
        
    else if (net_power_p1(i)<0) && (net_power_p2(i)<0) && (power_consumption_c1(i)>=0);        %001
        p1_utility_power(i)=net_power_p1(i);
        utility_costs_p1(i)=p1_cost;
        
        p2_utility_power(i)=net_power_p2(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i)+net_power_p2(i);
        utility_costs_c1(i)=p2_cost;
        
    else if (net_power_p1(i)<0) && (net_power_p2(i)>=0) && (power_consumption_c1(i)>=0);        %011
        p1_utility_power(i)=net_power_p1(i);
        utility_costs_p1(i)=p1_cost;
        
        p2_utility_power(i)=net_power_p2(i)+net_power_p1(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;
    
    else if (net_power_p1(i)>=0) && (net_power_p2(i)<0) && (power_consumption_c1(i)<0);         %100
        p1_utility_power(i)=net_power_p1(i)+net_power_p2(i);
        utility_costs_p1(i)=p2_cost;

        p2_utility_power(i)=net_power_p2(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;  
    
    else if (net_power_p1(i)>=0) && (net_power_p2(i)>=0) && (power_consumption_c1(i)>=0);        %110
        p1_utility_power(i)=net_power_p1(i);
        utility_costs_p1(i)=p1_cost;

        p2_utility_power(i)=net_power_p2(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;   
        
    else if (net_power_p1(i)<0) && (net_power_p2(i)>=0) && (power_consumption_c1(i)>=0);         %010
        p1_utility_power(i)=net_power_p1(i);
        utility_costs_p1(i)=p1_cost;
        
        p2_utility_power(i)=net_power_p2(i)+net_power_p1(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;
        
        else                                                                                     %101
        p1_utility_power(i)=net_power_p1(i)+net_power_p2(i);
        utility_costs_p1(i)=p2_cost;

        p2_utility_power(i)=net_power_p2(i);
        utility_costs_p2(i)=p2_cost;
        
        c1_utility_power(i)=power_consumption_c1(i);
        utility_costs_c1(i)=c1_cost;
        
        end
        end
        end
        end
        end
    end
end

%% TOTAL UTILITY POWER, ENERGY, COST, EMISSIONS vs CURRENT

%power (kW)
MEF=MarginalEmissionsFactors{region,2}/1000;                                %kg/kWh
load('power_consumption_p1.mat');
load('power_consumption_p2.mat');

total_utility_power_curr=power_consumption_p1+power_consumption_p2+power_consumption_c1;
for i=1:length(net_power_p2);
    total_utility_power_opt(i)=p1_utility_power(i)+p2_utility_power(i)+c1_utility_power(i);
end

%time_length_p1,
figure
plot(total_utility_power_curr);
hold on
plot(total_utility_power_opt);
hold on
title ('Total Grid Utiltiy Power Consumption')
ylabel ('Power (kW)')
xlabel('time')
legend('current w/solar','P1 to P2 to C1 Optimized')


%energy (kWh)
total_utility_energy_curr=cumtrapz(total_utility_power_curr);
total_utility_energy_opt=cumtrapz(total_utility_power_opt);

figure
plot(total_utility_energy_curr);
hold on
plot(total_utility_energy_opt);
hold on
title ('Total Grid Utiltiy Energy Consumption')
ylabel ('Energy (kWh)')
xlabel('time')
legend('current w/solar','P1 to P2 to C1 Optimized')

%utility cost (usd)
load('cost_solar_p1.mat');
load('cost_solar_p2.mat');
load('cost_current_c1.mat');

total_utility_cost_curr=cost_solar_p1+cost_solar_p2+cost_current_c1.';
p=utility_costs_p1+utility_costs_p2+utility_costs_c1;
total_utility_cost_opt=total_utility_energy_opt.*p;

figure
plot(total_utility_cost_curr);
hold on
plot(total_utility_cost_opt);
hold on
title ('Total Grid Utiltiy Costs Consumption')
ylabel ('USD')
xlabel('time')
legend('current w/solar','P1 to P2 to C1 Optimized')

%emissions (CO2 kg)
total_utility_emissions_curr=total_utility_energy_curr*MEF;
total_utility_emissions_opt=total_utility_energy_opt*MEF;

figure
plot(total_utility_emissions_curr);
hold on
plot(total_utility_emissions_opt);
hold on
title ('Total Grid Utiltiy Emissions')
ylabel ('kg CO2')
xlabel('time')
legend('current w/solar','P1 to P2 to C1 Optimized')

