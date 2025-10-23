function [dataArray,xLinear,xLinearStage] = WLI_TakeData(xCenCorrection)
% native stage units are mm
% calculate values in c = mm/ps

    clc;
    close all;
    
    if nargin==0  
       xCenCorrection=0;
        
    end

    %copied in this block:
    lj = labJack;
    lj.initializeLabJack;
    stage = PIMercuryC863Controller;
   
    stage.initializeStage;
    stage.moveStage(10);
    
    N = 2048;
    
 
    %end of block

    
    %N = 1536; % steps of translation stage

    [xLinear,stepSize] = makeLinearXAxis(N);
    
   % lj = labJack;
   % lj.initializeLabJack;
   % stage = PIMercuryC863Controller;
   % stage.initializeStage;
	
    h = figure('units','normalized',...
               'position',[0.25,0.25,0.5,0.5],...
               'name','Voltage');
    ax = axes;
    axis tight;
    %set(ax,'ylim',[-0.2,0.2]);
%     set(ax,'ylim',[-0.5,3]);
    %x = (1:N) * (2*stepSize);
    
    dataArray = nan(N,2);
    %voltageLine1 = line(xLinear,dataArray(:,1),'marker','.','color','r');
    voltageLine1 = line(xLinear,dataArray(:,1),'color','r');
    voltageLine2 = line(xLinear,dataArray(:,2),'color','k');
    xLinearStage = nan(N,1);
    
    %ng = 1.377;
%     ng=0;
    %t = 1.4;
%     t = 0; 
    %xCenCorrection=0.041; % for no glass
    %xCenCorrection=-0.235;  % with glass 
%     stage.moveStageR(-stepSize * N/2 + xCenCorrection + (ng-1)*t/2);
    stage.moveStageR(-stepSize * N/2);
%     stage.moveStageR(-stepSize * N/2 + 1);

%     offset1 = -0.0285;
%     offset2 = -0.0307;
    offset1 = -0.05;
    offset2 = -0.05;
%     gain1 = 5;
%     gain2 = 10;

    gain1 = 1;
    gain2 = 1;

    for i=1:N
        
        xLinearStage(i) = stage.getStagePosition;
       % dataArray(i,1) = (lj.getVoltage(1)-0.00)*5;
       % dataArray(i,2) = (lj.getVoltage(0)+0.0096)*5;
        dataArray(i,1) = (lj.getVoltage(2)-offset2)*gain2;
        dataArray(i,2) = (lj.getVoltage(1)-offset1)*gain1;
        voltageLine1.YData = dataArray(:,1);
        voltageLine2.YData = dataArray(:,2);
        stage.moveStageR(stepSize);
        
        drawnow;
        if strcmp(get(h,'currentCharacter'),char(8))
            break;
        end
    end
    % recenter stage
    stage.moveStage(10);
    
    stage.uninitializeStage;
     
    xLinearStage = 2 * (xLinearStage-xLinearStage(N/2+1));
    
end

function numInmm = convertum2mm(numInum)

    numInmm = numInum/1000;
    
end

function [xLinear,stepSize] = makeLinearXAxis(N)
    
    % given by the WL calibration curve from the website
    lambdaMin = convertum2mm(0.3);
    
    % given by the approximate cutoff of silicon
    % lambdaMax = convertum2mm(1.1);
    
    % sampling period
    dx = lambdaMin/4;
    xMax = N*dx;
    xLinear = -xMax/2:dx:xMax/2-dx;
    %xLinear = 0:dx:xMax/2-dx;
    
    
    % The extra factor of two comes from the necessity for the stage to
    % step by half the desired value due to the double pass in the
    % interferometer
    stepSize = dx/2;
  
    
end
