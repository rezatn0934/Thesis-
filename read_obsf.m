clc;clear
close all
format long g
tic
data=data_creation;
angEL=[0 60];
angAZ=[0 360];
PD=2;
hmax=1;
prec=.005;
toc

tic
LL = Ot(data,angEL,angAZ,PD,hmax,prec);
toc

for i =1:size(LL,1)
    LL{i,21} = [LL{i,6}]*[LL{i,17}]/2;
    d=zeros(length([LL{i,17}]),1);
    f=LL{i,7};
    for j=1:length([LL{i,7}])
        d(j)=(f(j)*[LL{i,17}])/2;
    end
    LL{i,22}=d;
end
 for i=1:size(LL,1)
    if ~isnan([LL{i,21}])
        figure
        plot([LL{i,22}],'r','LineWidth',2)
        hold on
        plot(find([LL{i,22}]==[LL{i,21}]),[LL{i,21}],'b+','MarkerSize',20)
    end
end
