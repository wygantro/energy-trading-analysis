clc;
close all;
clear all;

%% PROSUMER #1: load initial data
load prosumer_1_data.mat;                                         %BystronicManufacturingLLCV1DataFile.csv
C1_p1=BystronicManufacturingLLCV1DataFile;
days=input('days to simulate?')
ts=4*24*days;                                                     %time step=15 min

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

utility_costs=0.071 %input('avoided utiltiy costs (usd/kWh)?');  %usd/kWh

%% PROSUMER #1: INPUTS
time_p1=C1_p1{2:ts,2};                                           %15 min per step
time_length_p1=(linspace(1,length(time_p1),length(time_p1))).';
power_consumption_p1=C1_p1{2:ts,3};                              %kW                        annual energy consumption=1,895,883 kWh/year
production_p1=C1_p1{2:ts,4};                                     %kW                        avoided utility cost=$0.071/kWh
net_power_p1=C1_p1{2:ts,7};                                      %kW
net_energy_p1=cumtrapz(net_power_p1);                            %kWh

%% PROSUMER #1 UTILITY CONSUMPTION
% power consumption

% energy consumption
energy_consumption_p1=cumtrapz(power_consumption_p1);

figure
subplot(2,1,1)
plot(power_consumption_p1)
title ('Utility Power Consumption (P1)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(energy_consumption_p1)
title ('Utility Energy Consumption (P1)')
ylabel ('power (kW)')
xlabel('time')
hold on

%% SOLAR PRODUCTION W/OUT STORAGE AND SELLBACK #1
figure
plot(production_p1)
title ('Solar Power Production (P1)')
ylabel ('power (kW)')
xlabel('time')
hold on

for i=1:length(net_power_p1);
    if net_power_p1(i)>=0;    
       solar_consumption_power_p1(i)=net_power_p1(i);
    else
       solar_consumption_energy_p1(i)=0;
    end
end

solar_consumption_energy_p1=cumtrapz(solar_consumption_power_p1);

figure
subplot(2,1,1)
plot(solar_consumption_power_p1)
title ('Net Solar Power Consumption w/o Storage (P1)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(solar_consumption_energy_p1)
title ('Net Solar Energy w/o Storage (P1)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

%% UNUSED POWER/ENERGY P1 #1

for i=1:length(net_power_p1);
    if net_power_p1(i)<=0;
       storage_power_p1(i)=net_power_p1(i);
    else
       storage_power_p1(i)=0;
    end
end

battery_SOC_energy_p1=cumtrapz(storage_power_p1);

figure
subplot(2,1,1)
plot(storage_power_p1)
title ('Excess Power (P1)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(battery_SOC_energy_p1)
title ('Excess Energy (P1)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

figure
subplot(2,1,1)
plot(net_power_p1)
title ('Net Power Consumption w/Storage (P1)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(net_energy_p1)
title ('Net Energy w/Storage (P1)')
ylabel ('Energy (kW*h)')
xlabel('time')
hold on

%% W/OUT SOLAR vs W/SOLAR, NO STORAGE vs W/SOLAR, W/STORAGE

figure
plot(time_length_p1,energy_consumption_p1);
hold on
plot(solar_consumption_energy_p1');
hold on
plot(time_length_p1,net_energy_p1);
hold on
title ('Utiltiy Energy Consumption (P1)')
ylabel ('Energy (kW*h)')
xlabel('time')
legend('current','w/solar, w/out storage', 'w/solar, w/storage')


%% PROSUMER #1 UTILITY CONSUMPTION COSTS/EMISSIONS
%cost
cost_current_p1=utility_costs*energy_consumption_p1;
cost_solar_p1=utility_costs*solar_consumption_energy_p1;
cost_solar_storage_p1=utility_costs*net_energy_p1;

figure
CP1=[cost_current_p1(length(cost_current_p1)) cost_solar_p1(length(cost_solar_p1)) cost_solar_storage_p1(length(cost_solar_storage_p1))];
c=categorical({'current','w/solar, w/out storage', 'w/solar, w/storage'});
bar(c,CP1)
title('30 day utility cost (P1)')
ylabel('Cost (USD)')

hold on

%emissions
emissions_current_p1=MEF*energy_consumption_p1;
emissions_solar_p1=MEF*solar_consumption_energy_p1;
emissions_solar_storage_p1=MEF*net_energy_p1;

figure
EP1=[emissions_current_p1(length(emissions_current_p1)) emissions_solar_p1(length(emissions_solar_p1)) emissions_solar_storage_p1(length(emissions_solar_storage_p1))];
bar(c,EP1)
title('Emissions (P1)')
ylabel('CO2 Emissions (kg CO2)')
hold on
