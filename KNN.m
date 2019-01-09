clear;
filename = 'LSVT_voice_rehabilitation.xlsx';
dataSet = xlsread(filename,1);
classification = xlsread(filename,2);

d=zeros(126,2);
dataSet =[d dataSet]; 

%my feature matrix
features=zeros(126,4);

clear d;

for i=1:126
     energy =0;  power=0; CurveLength=0;  NonlinearEnergy=0;
     for j=3:312
          energy = energy+dataSet(i,j).^2;
          power = power +dataSet(i,j).^4;
          CurveLength=CurveLength+((dataSet(i,j)-dataSet(i,j-1)));
          NonlinearEnergy=NonlinearEnergy+((-dataSet(i,j)*dataSet(i,j-2))+((dataSet(i,j-1)).^2));
      end
      features(i,1)=energy;
      features(i,2)=power;
      features(i,3)=CurveLength;
      features(i,4)=NonlinearEnergy;
end

%to divide my matrix into 2 categories (train and test)
output = mat2cell(features,[100 26]);

predicted = knnclassify(output{2,1} , output{1,1} , classification(1:100,:));
actual = classification(101:126,:);

[confusionMatix, order] = confusionmat(actual,predicted);

clear energy power CurveLength NonlinearEnergy i j filename;

Accuracy = (confusionMatix(1,1) + confusionMatix(2,2) ) / (confusionMatix(1,1)+confusionMatix(1,2) +confusionMatix(2,1) + confusionMatix(2,2));
Senstivity = (confusionMatix(1,1))/ (confusionMatix(1,1) + confusionMatix(2,1)) ;
Specifity = (confusionMatix(2,2)) / (confusionMatix(1,2) + confusionMatix(2,2))  ;
    





