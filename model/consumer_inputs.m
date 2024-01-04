clc;
close all;
clear all;

%% PROSUMER #1: load initial data
load BystronicManufacturingLLCV1DataFile.mat;
C1=BystronicManufacturingLLCV1DataFile;
days=input('days to simulate?');
ts=4*24*days;                              %time step=15 min

%% PROSUMER #1: INPUTS

time=C1{2:ts,2};                            %15 min per step
time_length=(linspace(1,length(time),length(time))).';
consumption=C1{2:ts,3};                     %kW
production=C1{2:ts,4};                      %kW
net_power=C1{2:ts,7};                       %kW
net_energy=cumtrapz(net_power);             %kWh


figure
plot(consumption)
title ('Power Consumption')
ylabel ('power (kW)')
xlabel('time')
hold on

figure
plot(production)
title ('Solar Power Production')
ylabel ('power (kW)')
xlabel('time')
hold on

figure
plot(net_power)
title ('Net Power')
ylabel ('power (kW)')
xlabel('time')
hold on

figure
plot(net_energy)
title ('Net Energy')
ylabel ('energy (kWh)')
xlabel('time')
hold on





%% CONSUMER 1: OUTPUTS
%consumer 1 costs

utility_rate=0.09;                          %cost per kwh
cost_rate=consumption*utility_rate;         %usd per minute

figure
plot(cost_rate)
title ('Energy Costs')
ylabel ('costs (usd)')
xlabel('time')
hold on

%consumer 1 emissions
CO2_emissions=0.185;                       %kg per kwh (natural gas) https://www.carbonindependent.org/15.html
emissions=net_energy*CO2_emissions;        %CO2 (kg)

figure
plot(emissions)
title ('CO2 Emissions')
ylabel ('mass (kg)')
xlabel('time')
hold on

%consumer 1 
%% simulation
%sim('Model1_consumer.slx');

%figure
%plot(ans.cost)
%title ('Energy Cost')
%ylabel ('USD')
%xlabel('time')
%hold on

%figure
%plot(ans.emissions)
%title ('CO2 Emissions')
%ylabel ('USD')
%xlabel('time')
%hold on


%% consumption sub model

%% production sub model

%% storage sub model

%% financial model


%% cost
%net metering=cumtrapz(net power - power credits)
%net billing= cumtrapz(net power*rate)
%show how net metering would look with a sample that would benefit from the
%offset well... high energy use at different time of the day
