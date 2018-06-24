% Blue LED Control with Nidaq 
% Testing Script for setting up Nidaq-controlled blue light stimulus
% Matt Churgin, Spring 2018

% To test blue light with Nidaq, connect the blue LEDs to Nidaq channel 0
% as described in the CNC manual.  Ensure the solid state relay and power
% supply are wired correctly.
%  Once everything is connect, turn the power supply on and plug the Nidaq
%  in (make sure all Nidaq drivers and matlab plugin are installed).  Run
%  part 1 of this script.  Finally, run part 2 of this script.  The blue
%  LEDs should turn on for 3 seconds and then turn off.  If that happens,
%  the connection is successful.  

%  If the script returns an error, there is
%  likely a problem with finding or connecting to Nidaq.

% Part 1: Initialization

devices=daq.getDevices; 
s=daq.createSession('ni');

% Add the analog output channel
% Input device number: e.g. Dev1, Dev2, etc.
% Input analog output channel number:  e.g. 0 or 1
addAnalogOutputChannel(s,'Dev1',0,'Voltage');

%% Part 2: Test blue light for 3 seconds

outputSingleScan(s,4) %sets specified analog output to 4 volts
pause(3) % wait 3 seconds
outputSingleScan(s,0)  %sets specified analog output to 0 volts