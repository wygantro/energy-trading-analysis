clc;
close all;
clear all;

%% CONSUMER #1: load initial data
load consumer_1_data.mat;                                              %RehrigPacificCompany-PreliminaryProposalV2-CA-Cash-DataFile.csv
C1_c1=RehrigPacificCompanyPreliminaryProposalV2CACashDataFile;
days=input('days to simulate?');
ts=4*24*days;                                                          %time step=15 min

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

MEF=MarginalEmissionsFactors{region,2}/1000;                                %kg/kWh

utility_costs=0.156 %input('avoided utiltiy costs (usd/kWh)?');        %usd/kWh

%% CONSUMER #1: INPUTS

time_c1=C1_c1{2:ts,2};                                                 %15 min per step
time_length_c1=(linspace(1,length(time_c1),length(time_c1))).';
power_consumption_c1=C1_c1{2:ts,3};                                    %kW                annual energy consumption=29,705,957 kWh/year
production_c1=C1_c1{2:ts,4};                                           %kW                utility cost=$0.156/kWh
net_power_c1=C1_c1{2:ts,7};                                            %kW
net_energy_c1=cumtrapz(net_power_c1);                                  %kWh

%% CONSUMER #1 UTILITY CONSUMPTION
% power consumption

% energy consumption
energy_consumption_c1=cumtrapz(power_consumption_c1);

figure
subplot(2,1,1)
plot(power_consumption_c1)
title ('Utility Power Consumption (C1)')
ylabel ('power (kW)')
xlabel('time')

subplot(2,1,2)
plot(energy_consumption_c1)
title ('Utility Energy Consumption (C1)')
ylabel ('power (kW)')
xlabel('time')
hold on


%% CONSUMER #1 UTILITY CONSUMPTION COSTS/EMISSIONS
%cost
cost_current_c1=utility_costs*energy_consumption_c1;

figure
CC1=[cost_current_c1(length(cost_current_c1))];
c=categorical({'current'});
bar(c,CC1)
title('30 day utility cost (C1)')
ylabel('Cost (USD)')

hold on

%emissions
emissions_current_c1=MEF*energy_consumption_c1;

figure
EC1=[emissions_current_c1(length(emissions_current_c1))];
bar(c,EC1)
title('Emissions (C1)')
ylabel('CO2 Emissions (kg CO2)')
hold on
