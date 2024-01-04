clc;
close all;
clear all;

%% PROSUMER #2: load initial data
load prosumer_2_data.mat;                                         %WestsideTractorSales-LislePreliminaryProposalV1-DataFile.csv
C1_p2=WestsideTractorSalesLislePreliminaryProposalV1DataFile;
days=input('days to simulate?');
ts=4*24*days;                                                     %time step=15 min

% PROSUMER #2: INPUTS
time_p2=C1_p2{2:ts,2};                                            %15 min per step
time_length_p2=(linspace(1,length(time_p2),length(time_p2))).';
power_consumption_p2=C1_p2{2:ts,3};                               %kW
production_p2=C1_p2{2:ts,4};                                      %kW                         annual energy consumption=549,574 kWh/year
net_power_p2=C1_p2{2:ts,7};                                       %kW                         avoided utility cost=$0.066/kWh
net_energy_p2=cumtrapz(net_power_p2);                             %kWh


%% CONSUMER #1: load initial data
load consumer_1_data.mat;                                              %RehrigPacificCompany-PreliminaryProposalV2-CA-Cash-DataFile.csv
C1_c1=RehrigPacificCompanyPreliminaryProposalV2CACashDataFile;
ts=4*24*days;                                                          %time step=15 min

% CONSUMER #1: INPUTS

time_c1=C1_c1{2:ts,2};                                                 %15 min per step
time_length_c1=(linspace(1,length(time_c1),length(time_c1))).';
power_consumption_c1=C1_c1{2:ts,3};                                    %kW                annual energy consumption=29,705,957 kWh/year
production_c1=C1_c1{2:ts,4};                                           %kW                utility cost=$0.156/kWh
net_power_c1=C1_c1{2:ts,7};                                            %kW
net_energy_c1=cumtrapz(net_power_c1);                                  %kWh

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

MEF=MarginalEmissionsFactors{region,2}/1000;                               %kg/kWh

utility_costs_p2=0.066 %input('avoided utiltiy costs (usd/kWh)?');    %usd/kWh
utility_costs_c1=0.156 %input('avoided utiltiy costs (usd/kWh)?');    %usd/kWh

%% PROSUMER #1 to PROSUMER #2

for i=1:length(net_power_c1);
    if (net_power_p2(i)>=0) && (net_power_c1(i)>=0);    
            P2_power(i)=net_power_p2(i);
            C1_power(i)=net_power_c1(i);
        else if (net_power_p2(i)<=0) && (net_power_c1(i)>=0);
                P2_power(i)=net_power_p2(i);
                C1_power(i)=net_power_c1(i)+net_power_p2(i);
            else if (net_power_p2(i)>=0) && (net_power_c1(i)<=0);
                    P2_power(i)=net_power_p2(i)+net_power_c1(i);
                    C1_power(i)=net_power_c1(i);
                else (net_power_p2(i)<=0) && (net_power_c1(i)<=0);
                            P2_power(i)=net_power_p2(i);
                            C1_power(i)=net_power_c1(i);
                end
         end
    end
end
            
P2_energy_consumption=cumtrapz(P2_power);
C1_energy_consumption=cumtrapz(C1_power);

figure
plot(P2_power)
hold on
plot(C1_power)
hold on
title ('P2 to C1 Power Consumption')
ylabel ('power (kW)')
xlabel('time')
legend('P2 power','C1 power')

figure
plot(P2_energy_consumption)
hold on
plot(C1_energy_consumption)
hold on
title ('P2 to C1 Energy Consumption')
ylabel ('energy (kW*h)')
xlabel('time')
legend('P2 energy','C1 energy')

%% PROSUMER #2 TO CONSUMER #1 UTILITY CONSUMPTION COSTS/EMISSIONS
%cost
cost_p2_c1=utility_costs_p2*P2_energy_consumption;
cost_c1_p2=utility_costs_c1*C1_energy_consumption;
load('cost_current_p2.mat');
load('cost_current_c1.mat');

figure
CP2C1=[cost_current_p2(length(cost_current_p2)) cost_p2_c1(length(cost_p2_c1)); cost_current_c1(length(cost_current_c1)) cost_c1_p2(length(cost_c1_p2))];
c=categorical({'P2','C1'});
bar(c,CP2C1)
title('30 day utility cost')
ylabel('Cost (USD)')
hold on

%emissions
emissions_p2_c1=MEF*P2_energy_consumption;
emissions_c1_p2=MEF*C1_energy_consumption;
load('emissions_current_p2.mat');
load('emissions_current_c1.mat');

figure
EP2C1=[emissions_current_p2(length(emissions_current_p2)) emissions_p2_c1(length(emissions_p2_c1)); emissions_current_c1(length(emissions_current_c1)) emissions_c1_p2(length(emissions_c1_p2))];
bar(c,EP2C1)
title('Emissions')
ylabel('CO2 Emissions (kg CO2)')
hold on
