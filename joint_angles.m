%Author: Seda Bilaloglu 
%Date:061117 
%Description:Calculates the joint angles from the marker data  
 
clc
clear all
close all
 
fullpath = mfilename('fullpath');
[path,name] = fileparts(fullpath);
%import data 
num = xlsread('Marker Data.xlsx'); 
 
%exclude the nan 
num(isnan(num))=0;
 
%filter here
%4th order Butterworth filter at 10 Hz, low pass 
fc=10; 
fs=145; 
n=4;
Wn = fc/(fs/2);
[b,a] = butter(n, Wn, 'low');
 
filteredData(:,1:2)=num(:,1:2);
 
for c=3:18
filteredData(:,c) = filter(b, a, num(:,c));
%filteredSignal = filteredSignal - mean(filteredSignal); % Subtracting the mean to block DC Component
end
 
 
%columns 
 
%3-MET.X1 4-MET.Y1 5-HEEL.X1 6-HEEL.Y1 7-MALLEOL.X1 8-MALLEOL.Y1 9-FIBULA.X1 10-FIBULA.Y1 
%11-FEM.ALT.X1 12-FEM.ALT.Y1 13-FEM.UST.X1 14-FEM.UST.Y1 15-ASIS.X1 16-ASIS.Y1 17-ACR.X1 18-ACR.Y1  
 
%define the rigid bodies here
 
%rigid body parça (ayak);     Metatarsal - Heel  
Met=[filteredData(:,3) filteredData(:,4) ]; 
Heel=[filteredData(:,5) filteredData(:,6) ];
 
%rigid body (tibiya);   L. Malleolus - Head of Fibula  
Mall=[filteredData(:,7) filteredData(:,8) ]; 
Fib=[filteredData(:,9) filteredData(:,10)];
 
%rigid body (femur);  L. femoral condyle - Greater trochanter -??????????
femcond=[filteredData(:,11) filteredData(:,12) ];
Greatertr=[filteredData(:,13) filteredData(:,14) ]; 
 
%rigid body (torso);    Anterior superior iliac spine -  Acromion process
asis=[filteredData(:,15) filteredData(:,16)]; 
Acrproc=[filteredData(:,17) filteredData(:,18) ];
 

%joint anges 
%Ayak bile?i; 1. rigid body - 2. rigid body  
for m=1:length(Met) 

v1=Heel(m,:)-Met(m,:);
v2=Fib(m,:)-Mall(m,:);
ankle_angle(m) = atan2(abs(det([v2;v1])),dot(v2,v1));

end 


%Diz; 2. rigid body - 3. rigid body 
for m=1:length(Mall) 
v1=Mall(m,:)-Fib(m,:);
v2=femcond(m,:)-Greatertr(m,:);
knee_angle(m)= atan2(abs(det([v1;v2])),dot(v1,v2));
end  

%Kalça; 3. rigid body - 4. rigid body
 
for m=1:length(asis) 
v1=asis(m,:)-Acrproc(m,:);
v2=femcond(m,:)-Greatertr(m,:);
hip_angle(m)= atan2(abs(det([v1;v2])),dot(v1,v2));
end

%normalize the angles found
knee_angle=180-( knee_angle*180/pi);
hip_angle=hip_angle*180/pi;
ankle_angle=180-(ankle_angle*180/pi); 

  
%write data in a file, ignore nan

all=[num,knee_angle',hip_angle',ankle_angle',[0;diff(knee_angle)'],[0;diff(hip_angle)'],[0;diff(ankle_angle)'],[0;0;diff(diff(knee_angle))'],[0;0;diff(diff(hip_angle))'],[0;0;diff(diff(ankle_angle))']]; 
 
titles={'frame';'time';'MET_X1'; 'MET_Y1'; 'HEEL_X1'; 'HEEL_Y1';'MALLEOL_X1'; 'MALLEOL_Y1';'FIBULA_X1'; 'FIBULA_Y1'; 
'FEM_ALT_X1'; 'FEM_ALT_Y1'; 'FEM_UST_X1'; 'FEM_UST_Y1'; 'ASIS_X1'; 'ASIS_Y1'; 'ACR_X1'; 'ACR_Y1';  
'knee_angle';'hip_angle';'ankle_angle';'derivative_knee_angle';'derivative_hip_angle';'derivative_ankle_angle';
'acceleration_knee_angle';'acceleration_hip_angle';'dacceleration_erivative_ankle_angle'} ;
 
%write in a table 
T = array2table((all));  
T.Properties.VariableNames= titles; 

cd(path)

writetable(T,'joint_angles.csv')
