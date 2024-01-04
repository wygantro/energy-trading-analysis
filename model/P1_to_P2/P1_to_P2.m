clc;
close all;
clear all;

%% PROSUMER #1: load initial data
load prosumer_1_data.mat;                                         %BystronicManufacturingLLCV1DataFile.csv
C1_p1=BystronicManufacturingLLCV1DataFile;
days=input('days to simulate?');
ts=4*24*days;                                                     %time step=15 min

% PROSUMER #1: INPUTS
time_p1=C1_p1{2:ts,2};                                            %15 min per step
time_length_p1=(linspace(1,length(time_p1),length(time_p1))).';
power_consumption_p1=C1_p1{2:ts,3};                               %kW                        annual energy consumption=1,895,883 kWh/year
production_p1=C1_p1{2:ts,4};                                      %kW                        avoided utility cost=$0.071/kWh
net_power_p1=C1_p1{2:ts,7};                                       %kW
net_energy_p1=cumtrapz(net_power_p1);                             %kWh


%% PROSUMER #2: load initial data
load prosumer_2_data.mat;                                         %WestsideTractorSales-LislePreliminaryProposalV1-DataFile.csv
C1_p2=WestsideTractorSalesLislePreliminaryProposalV1DataFile;
ts=4*24*days;                                                     %time step=15 min

% PROSUMER #2: INPUTS
time_p2=C1_p2{2:ts,2};                                            %15 min per step
time_length_p2=(linspace(1,length(time_p2),length(time_p2))).';
power_consumption_p2=C1_p2{2:ts,3};                               %kW
production_p2=C1_p2{2:ts,4};                                      %kW                         annual energy consumption=549,574 kWh/year
net_power_p2=C1_p2{2:ts,7};                                       %kW                         avoided utility cost=$0.066/kWh
net_energy_p2=cumtrapz(net_power_p2);                             %kWh

%% MEF and Cost data
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

utility_costs_p1=0.071 %input('avoided utiltiy costs (usd/kWh)?');  %usd/kWh
utility_costs_p2=0.066 %input('avoided utiltiy costs (usd/kWh)?');  %usd/kWh

%% PROSUMER #1 to PROSUMER #2

for i=1:length(net_power_p2);
    if (net_power_p1(i)>=0) && (net_power_p2(i)>=0);    
            P1_power(i)=net_power_p1(i);
            P2_power(i)=net_power_p2(i);
        else if (net_power_p1(i)<=0) && (net_power_p2(i)>=0);
                P1_power(i)=net_power_p1(i);
                P2_power(i)=net_power_p2(i)+net_power_p1(i);
            else if (net_power_p1(i)>=0) && (net_power_p2(i)<=0);
                    P1_power(i)=net_power_p1(i)+net_power_p2(i);
                    P2_power(i)=net_power_p2(i);
                else (net_power_p1(i)<=0) && (net_power_p2(i)<=0);
                            P1_power(i)=net_power_p1(i);
                            P2_power(i)=net_power_p2(i);
                end
         end
    end
end
            
P1_energy_consumption=cumtrapz(P1_power);
P2_energy_consumption=cumtrapz(P2_power);

figure
plot(P1_power)
hold on
plot(P2_power)
hold on
title ('P1 to P2 Power Consumption')
ylabel ('power (kW)')
xlabel('time')
legend('P1 power','P2 power')

figure
plot(P1_energy_consumption)
hold on
plot(P2_energy_consumption)
hold on
title ('P1 to P2 Energy Consumption')
ylabel ('energy (kW*h)')
xlabel('time')
legend('P1 energy','P2 energy')

%% PROSUMER #1 TO PROSUMER #2 UTILITY CONSUMPTION COSTS/EMISSIONS
%cost
cost_p1_p2=utility_costs_p1*P1_energy_consumption;
cost_p2_p1=utility_costs_p2*P2_energy_consumption;
load('cost_current_p1.mat');
load('cost_current_p2.mat');

figure
CP1P2=[cost_current_p1(length(cost_current_p1)) cost_p1_p2(length(cost_p1_p2)); cost_current_p2(length(cost_current_p2)) cost_p2_p1(length(cost_p2_p1))];
c=categorical({'P1','P2'});
bar(c,CP1P2)
title('30 day utility cost')
ylabel('Cost (USD)')
hold on

%emissions
emissions_p1_p2=MEF*P1_energy_consumption;
emissions_p2_p1=MEF*P2_energy_consumption;
load('emissions_current_p1.mat');
load('emissions_current_p2.mat');

figure
EP1P2=[emissions_current_p1(length(emissions_current_p1)) emissions_p1_p2(length(emissions_p1_p2)); emissions_current_p2(length(emissions_current_p2)) emissions_p2_p1(length(emissions_p2_p1))];
bar(c,EP1P2)
title('Emissions')
ylabel('CO2 Emissions (kg CO2)')
hold on
