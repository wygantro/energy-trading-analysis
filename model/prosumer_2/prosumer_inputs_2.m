clc;
close all;
clear all;

%% PROSUMER #2: load initial data
load prosumer_2_data.mat;                                        %WestsideTractorSales-LislePreliminaryProposalV1-DataFile.csv
C1_p2=WestsideTractorSalesLislePreliminaryProposalV1DataFile;
days=input('days to simulate?');
ts=4*24*days;                                                    %time step=15 min

load MarginalEmissionsFactors.mat; 
FRCC=1;
MRO=2;
NPCC=3;
RFC=4;
SERC=5;
SPP=6;
TRE=7;
WECC=8;

region=input('marginal emissions region?')                      

MEF=MarginalEmissionsFactors{region,2}/1000;                          %kg/kWh

utility_costs=0.066 %input('avoided utiltiy costs (usd/kWh)?');  %usd/kWh

%% PROSUMER #2: INPUTS
time_p2=C1_p2{2:ts,2};                                           %15 min per step
time_length_p2=(linspace(1,length(time_p2),length(time_p2))).';
power_consumption_p2=C1_p2{2:ts,3};                              %kW
production_p2=C1_p2{2:ts,4};                                     %kW                         annual energy consumption=549,574 kWh/year
net_power_p2=C1_p2{2:ts,7};                                      %kW                         avoided utility cost=$0.066/kWh
net_energy_p2=cumtrapz(net_power_p2);                            %kWh

%% PROSUMER #2 UTILITY CONSUMPTION
% power consumption

% energy consumption
energy_consumption_p2=cumtrapz(power_consumption_p2);

figure
subplot(2,1,1)
plot(power_consumption_p2)
title ('Utility Power Consumption (P2)')
ylabel ('power (W)')
xlabel('time')

subplot(2,1,2)
plot(energy_consumption_p2)
title ('Utility Energy Consumption (P2)')
ylabel ('power (kW)')
xlabel('time')
hold on

%% SOLAR PRODUCTION W/OUT STORAGE AND SELLBACK #2
figure
plot(production_p2)
title ('Solar Power Production (P2)')
ylabel ('power (kW)')
xlabel('time')
hold on

for i=1:length(net_power_p2);
    if net_power_p2(i)>=0;    
       solar_consumption_power_p2(i)=net_power_p2(i);
    else
       solar_consumption_energy_p2(i)=0;
    end
end

solar_consumption_energy_p2=cumtrapz(solar_consumption_power_p2);

figure
subplot(2,1,1)
plot(solar_consumption_power_p2)
title ('Net Solar Power Consumption w/o Storage (P2)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(solar_consumption_energy_p2)
title ('Net Solar Energy w/o Storage (P2)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

%% UNUSED POWER/ENERGY P1 #2

for i=1:length(net_power_p2);
    if net_power_p2(i)<=0;
       storage_power_p2(i)=net_power_p2(i);
    else
       storage_power_p2(i)=0;
    end
end

storage_energy_p2=cumtrapz(storage_power_p2);

figure
subplot(2,1,1)
plot(storage_power_p2)
title ('Excess Power (P2)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(storage_energy_p2)
title ('Excess Energy (P2)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

%battery_size=3000;                                  % tesla megapack @3000 kWh           %input('size of battery (kWh)?')    
%battery_cost=278;                                   % tesla megapack @$278 per kWh    %input('cost of battery per kWh?');
%total_bat_cost=battery_size*battery_cost;

figure
subplot(2,1,1)
plot(net_power_p2)
title ('Net Power Consumption w/Storage (P2)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(net_energy_p2)
title ('Net Energy w/Storage (P2)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

%% W/OUT SOLAR vs W/SOLAR, NO STORAGE vs W/SOLAR, W/STORAGE

figure
plot(time_length_p2,energy_consumption_p2);
hold on
plot(solar_consumption_energy_p2');
hold on
plot(time_length_p2,net_energy_p2);
hold on
title ('Utiltiy Energy Consumption (P2)')
ylabel ('Energy (kW*h)')
xlabel('time')
legend('current','w/solar, w/out storage', 'w/solar, w/storage')


%% PROSUMER #2 UTILITY CONSUMPTION COSTS/EMISSIONS
%cost
cost_current_p2=utility_costs*energy_consumption_p2;
cost_solar_p2=utility_costs*solar_consumption_energy_p2;
cost_solar_storage_p2=utility_costs*net_energy_p2;

figure
CP2=[cost_current_p2(length(cost_current_p2)) cost_solar_p2(length(cost_solar_p2)) cost_solar_storage_p2(length(cost_solar_storage_p2))];
c=categorical({'current','w/solar, w/out storage', 'w/solar, w/storage'});
bar(c,CP2)
title('30 day utility cost (P2)')
ylabel('Cost (USD)')

hold on

%emissions
emissions_current_p2=MEF*energy_consumption_p2;
emissions_solar_p2=MEF*solar_consumption_energy_p2;
emissions_solar_storage_p2=MEF*net_energy_p2;

figure
EP2=[emissions_current_p2(length(emissions_current_p2)) emissions_solar_p2(length(emissions_solar_p2)) emissions_solar_storage_p2(length(emissions_solar_storage_p2))];
bar(c,EP2)
title('Emissions (P2)')
ylabel('CO2 Emissions (kg CO2)')
hold on
