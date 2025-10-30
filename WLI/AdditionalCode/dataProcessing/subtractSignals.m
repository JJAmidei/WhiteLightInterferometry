function [newData,newxL] = subtractSignals(dataArray,xL,alpha,startidx,plotOn)
    heneData = dataArray(:,2);
    WLData = dataArray(:,1);
    newxL = xL(startidx:end);
    newHene = heneData(startidx:end);
    newWL = WLData(startidx:end) - alpha*heneData(startidx:end);
    newData = cat(2,newWL,newHene);
    
    if plotOn
        figure;
        plot(heneData-mean(heneData))
        hold on
        plot(WLData-mean(WLData))
        figure;
        plot(newData(:,2)-mean(newData(:,2)))
        hold on
        plot(newData(:,1)-mean(newData(:,1)))
    end
    
end