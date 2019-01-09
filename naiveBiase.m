clear ;
filename = 'LSVT_voice_rehabilitation.xlsx';
dataSet = xlsread(filename,1);
d=zeros(126,2);
dataSet=[d dataSet];
classification = xlsread(filename,2);

clear d; 

%getting my features : Energy 4thPower  NonlinearEnergy CurveLength 
features=zeros(126,4);
for i=1:126
    energy =0; 
    power=0;
    CurveLength=0; 
    NonlinearEnergy=0;
    for j=3:312
        energy = energy + dataSet(i,j).^2;
        power = power + dataSet(i,j).^4;
        CurveLength=CurveLength+((dataSet(i,j)-dataSet(i,j-1)));
        NonlinearEnergy=NonlinearEnergy+((-dataSet(i,j)*dataSet(i,j-2))+((dataSet(i,j-1)).^2));
    end
    features(i,1)=energy;
    features(i,2)=power;
    features(i,3)=CurveLength;
    features(i,4)=NonlinearEnergy;
end;
 % num 2 seed 4 save acc = 47 sen = 37
num = 2;
%rng function just before cvpartition to set seed of the random number generation.
seed = 4;
rng(seed);

%feature with classification
All=[features classification];
CV=cvpartition(classification,'KFold', num);

clear features;
clear classification energy power CurveLength NonlinearEnergy filename;
Accuracy= zeros(CV.NumTestSets,1);
Senstivity = zeros(CV.NumTestSets,1);
Specifity =zeros(CV.NumTestSets,1);
for o=1:CV.NumTestSets
    
 
    %train and test index
    traindex=CV.training(o);
    testindex=CV.test(o);
    
    %train and test matrix
    train=All(traindex,:);
    test=All(testindex,:);
    
    %index of class1 and class2 in train
    indexClass1=find(train(1:end,5)==1);
    indexClass2=find(train(1:end,5)==2);
    
   %trained of C1 and C2 to further get probability of fi given that they
   %are C1 or C2
    class1=train(indexClass1,:);
    class2=train(indexClass2,:);

    actual=test(:,5);
    predicted=zeros(length(actual),1);

    probabilityC1=length(indexClass1)/length(train);
    probabilityC2=length(indexClass2)/length(train);
    
    meanclass1=mean(class1(:,1:4));
    meanclass2=mean(class2(:,1:4));
    segmaclass1=std(class1(:,1:4));
    segmaclass2=std(class2(:,1:4));

    for i=1:length(test)
        %numofdis1=1;
        %numofdis2=1;
        finalpdf1=1; 
        finalpdf2=1; 
        for j=1:4
            normPdfFeature1=normpdf(test(i,j),meanclass1(1,j),segmaclass1(1,j));
            finalpdf1=finalpdf1*normPdfFeature1;
            normPdfFeature2=normpdf(test(i,j),meanclass2(1,j),segmaclass2(1,j));
            finalpdf2=finalpdf2*normPdfFeature2;
        end
        
        %pfc = probabilty of features given class
        pfc1=finalpdf1*probabilityC1;
        pfc2=finalpdf2*probabilityC2;

        if pfc2>pfc1
           predicted(i,1)=2;
        else
           predicted(i,1)=1;
        end
    end
    
    clear traindex testindex train test indexClass1 indexClass2;
    clear finalpdf1 finalpdf2 numofdis1 numofdis2 normPdfFeature1 normPdfFeature2 ;

%     truePositive=0;
%     trueNegative=0;
%     falsePositive=0; 
%     falseNegative=0;
% 
%     for k = 1:length(predicted)
%         if(predicted(k,:) == actual(k,:) && predicted(k,:) == 2)
%             trueNegative = trueNegative +1;
%         end
%         if(predicted(k,:) == actual(k,:) && predicted(k,:) == 1)
%             truePositive =  truePositive +1;
%         end 
%         if (actual(k,:) == 2 && predicted(k,:) == 1 )
%             falseNegative = falseNegative +1;
%         end
%         if (actual(k,:) == 1 && predicted(k,:) == 2 )
%             falsePositive = falsePositive +1;
%         end
%     end
[confusionMatix, order] = confusionmat(actual,predicted);
 %CONFUSIONMAT OUTPUT
    %%%%%%%%%%%%%%%%%%%%%%
    %          predicted
    %         | 1     0
    %    r  -----------
    %    e  1 | TP   FP
    %    a  0 | FN   TN
    %    l
    %%%%%%%%%%%%%%%%%%%%%%
    %Specifity(o,:) = (trueNegative)/ (trueNegative + falsePositive) ;
    %Senstivity(o,:) = (truePositive) / (truePositive + falseNegative)  ;
    %https://en.wikipedia.org/wiki/Confusion_matrix

    Accuracy(o,:) = (confusionMatix(1,1) + confusionMatix(2,2) ) /(confusionMatix(1,1)+confusionMatix(1,2) +confusionMatix(2,1) + confusionMatix(2,2));
    Senstivity(o,:) = (confusionMatix(1,1))/ (confusionMatix(1,1) + confusionMatix(2,1)) ;
    Specifity(o,:) = (confusionMatix(2,2)) / (confusionMatix(1,2) + confusionMatix(2,2))  ;
    

end

clear i j k o seed ; 
clear truePositive trueNegative falsePositive  falseNegative pcf1 pcf2 order ;

accuracyFinal = sum(Accuracy)/num;
sentivityFinal = sum(Senstivity)/ num;
specifityFinal = sum(Specifity) / num;
